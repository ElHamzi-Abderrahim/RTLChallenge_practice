`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter THERMO_WIDTH = 7,
    parameter BINARY_WIDTH = 3
    //---------------------------------------------------------
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg  [THERMO_WIDTH-1:0] thermo_in;
    wire [BINARY_WIDTH-1:0] binary_out;
    wire valid;

    integer ERR_COUNT = 0;

    //---------------------------------------------------------
    // Instantiate DUT
    //---------------------------------------------------------
    thermometer_to_binary #(
        .THERMO_WIDTH(THERMO_WIDTH),
        .BINARY_WIDTH(BINARY_WIDTH)
    ) DUT (
        .thermo_in(thermo_in),
        .binary_out(binary_out),
        .valid(valid)
    );

    //---------------------------------------------------------
    // Reference Model Functions
    //---------------------------------------------------------
    function ref_valid(input [THERMO_WIDTH-1:0] t);
        reg found_zero;
        integer i;
        begin
            found_zero = 0;
            ref_valid = 1;
            // Check LSB to MSB: ones must be contiguous from bit 0
            for (i = 0; i < THERMO_WIDTH; i = i + 1) begin
                if (t[i]) begin
                    if (found_zero) begin
                        ref_valid = 0;
                        i = THERMO_WIDTH; // break
                    end
                end
                else begin
                    found_zero = 1;
                end
            end
        end
    endfunction

    function [BINARY_WIDTH-1:0] ref_bin(input [THERMO_WIDTH-1:0] t);
        integer count;
        integer i;
        begin
            count = 0;
            for (i = 0; i < THERMO_WIDTH; i = i + 1)
                if (t[i]) count = count + 1;
            ref_bin = count;
        end
    endfunction

    //---------------------------------------------------------
    // Core Testing Logic
    //---------------------------------------------------------
    task apply_test(input [THERMO_WIDTH-1:0] t);
        reg r_valid;
        reg [BINARY_WIDTH-1:0] r_bin;
        begin
            thermo_in = t;
            #2;

            r_valid = ref_valid(t);
            r_bin   = ref_bin(t);

            if (valid !== r_valid) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Valid mismatch for input: %b  expected=%0b got=%0b",
                    t, r_valid, valid);
            end
            if (r_valid && (binary_out !== r_bin)) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Binary mismatch for input: %b  expected=%0d got=%0d",
                    t, r_bin, binary_out);
            end
        end
    endtask

    //---------------------------------------------------------
    // Full Sweep Testing
    //---------------------------------------------------------
    integer max_tests;
    integer step;
    integer j;

    initial begin
        // For small THERMO_WIDTH, test all values; for larger, sample
        if (THERMO_WIDTH <= 15) begin
            max_tests = (1 << THERMO_WIDTH);
            step = 1;
        end else begin
            max_tests = 4096;  // Sample 4096 values for very wide inputs
            step = (1 << THERMO_WIDTH) / 4096;
            if (step < 1) step = 1;
        end

        $display("=== Testing %0d patterns (THERMO_WIDTH=%0d, BINARY_WIDTH=%0d) ===",
                 max_tests, THERMO_WIDTH, BINARY_WIDTH);

        // Test sampled or exhaustive patterns
        for (j = 0; j < max_tests; j = j + 1) begin
            apply_test((j * step));
        end

        // Always test valid thermometer patterns explicitly
        test_valid_thermometer_codes();

        check_result();
    end

    //---------------------------------------------------------
    // Test all valid thermometer codes (0 to THERMO_WIDTH ones)
    //---------------------------------------------------------
    task test_valid_thermometer_codes;
        reg [THERMO_WIDTH-1:0] valid_thermo;
        integer k;
        begin
            $display("Testing %0d valid thermometer codes...", THERMO_WIDTH + 1);
            for (k = 0; k <= THERMO_WIDTH; k = k + 1) begin
                // Create valid thermometer: k ones from LSB
                if (k == 0)
                    valid_thermo = {THERMO_WIDTH{1'b0}};
                else
                    valid_thermo = (1 << k) - 1;
                apply_test(valid_thermo);
            end
        end
    endtask

//do not edit below
task check_result;
begin
   if(ERR_COUNT > 0) begin
      $error("Test failed with %0d errors.", ERR_COUNT);
   end else begin
      $display("Test PASS");
   end
   $finish;
end
endtask

string filename;

initial begin
   if ($value$plusargs("VCDFILE=%s",filename)) begin
      $dumpfile(filename);
      $dumpvars(0, DUT);
   end
end

initial begin
    #(TB_SIM_TIMEOUT)
    $display("Simulation TIMEOUT");
    $finish;
end

endmodule
