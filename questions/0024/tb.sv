`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter BINARY_WIDTH = 8,
    parameter BCD_DIGITS = 3,
    parameter BCD_WIDTH = 12
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg start;
reg [BINARY_WIDTH-1:0] binary_in;
wire [BCD_WIDTH-1:0] bcd_out;
wire valid;

integer ERR_COUNT = 0;

//DUT instantiation
   binary_to_bcd #(
      .BINARY_WIDTH(BINARY_WIDTH),
      .BCD_DIGITS(BCD_DIGITS),
      .BCD_WIDTH(BCD_WIDTH)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .start(start),
      .binary_in(binary_in),
      .bcd_out(bcd_out),
      .valid(valid)
   );

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test vectors - using separate arrays instead of struct
reg [BINARY_WIDTH-1:0] test_binary_vals [0:9];
reg [BCD_WIDTH-1:0] test_expected_bcd [0:9];

// Reference function to convert binary to BCD
function [BCD_WIDTH-1:0] ref_binary_to_bcd;
    input [BINARY_WIDTH-1:0] binary_val;
    integer decimal_val;
    integer i;
    reg [BCD_WIDTH-1:0] result;
    begin
        decimal_val = binary_val;
        result = {BCD_WIDTH{1'b0}};

        // Extract each BCD digit
        for (i = 0; i < BCD_DIGITS; i = i + 1) begin
            result[i*4 +: 4] = decimal_val % 10;
            decimal_val = decimal_val / 10;
        end

        ref_binary_to_bcd = result;
    end
endfunction

// Initialize test vectors - use values that fit within BINARY_WIDTH
// and calculate expected BCD dynamically
initial begin
    // Use values that scale with BINARY_WIDTH
    test_binary_vals[0] = 0;
    test_binary_vals[1] = 1;
    test_binary_vals[2] = 9;
    test_binary_vals[3] = 10;
    test_binary_vals[4] = 15;
    // For remaining tests, use values relative to max value
    test_binary_vals[5] = (2**BINARY_WIDTH) / 4;      // 25% of max
    test_binary_vals[6] = (2**BINARY_WIDTH) / 2;      // 50% of max
    test_binary_vals[7] = (2**BINARY_WIDTH) * 3 / 4;  // 75% of max
    test_binary_vals[8] = (2**BINARY_WIDTH) - 2;      // max - 1
    test_binary_vals[9] = (2**BINARY_WIDTH) - 1;      // max value

    // Calculate expected BCD using reference function
    test_expected_bcd[0] = ref_binary_to_bcd(test_binary_vals[0]);
    test_expected_bcd[1] = ref_binary_to_bcd(test_binary_vals[1]);
    test_expected_bcd[2] = ref_binary_to_bcd(test_binary_vals[2]);
    test_expected_bcd[3] = ref_binary_to_bcd(test_binary_vals[3]);
    test_expected_bcd[4] = ref_binary_to_bcd(test_binary_vals[4]);
    test_expected_bcd[5] = ref_binary_to_bcd(test_binary_vals[5]);
    test_expected_bcd[6] = ref_binary_to_bcd(test_binary_vals[6]);
    test_expected_bcd[7] = ref_binary_to_bcd(test_binary_vals[7]);
    test_expected_bcd[8] = ref_binary_to_bcd(test_binary_vals[8]);
    test_expected_bcd[9] = ref_binary_to_bcd(test_binary_vals[9]);
end

// Test sequence
initial begin
    integer i;
    // Initialize
    reset = 1;
    start = 0;
    binary_in = 0;

    // Reset sequence
    repeat(5) @(posedge clk);
    reset = 0;
    repeat(2) @(posedge clk);

    // Test all vectors
    for (i = 0; i < 10; i = i + 1) begin
        test_conversion(test_binary_vals[i], test_expected_bcd[i], i);
        repeat(5) @(posedge clk); // Gap between tests
    end

    // Test edge cases
    test_boundary_values();

    // Test multiple conversions
    test_back_to_back_conversions();

    check_result;
end

// Task to test a single conversion
task test_conversion;
    input [BINARY_WIDTH-1:0] test_binary_val;
    input [BCD_WIDTH-1:0] test_expected_bcd;
    input integer test_idx;
    integer timeout_count;
    integer decimal_from_bcd;
    begin
        $display("Testing: Test %0d (binary: %0d, expected BCD: 0x%03X)",
                 test_idx, test_binary_val, test_expected_bcd);

        // Setup input
        binary_in = test_binary_val;

        // Start conversion
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for completion with timeout
        timeout_count = 0;
        while (!valid && timeout_count < 100) begin
            @(posedge clk);
            timeout_count = timeout_count + 1;
        end

        if (timeout_count >= 100) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv Conversion timeout for test %0d", test_idx);
        end else begin
            // Check result
            if (!valid) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv Valid flag not asserted for test %0d", test_idx);
            end

            if (bcd_out !== test_expected_bcd) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv BCD mismatch for test %0d: got 0x%03X, expected 0x%03X",
                       test_idx, bcd_out, test_expected_bcd);
            end else begin
                $display("  - Correct BCD: 0x%03X", bcd_out);
            end

            // Verify individual BCD digits and reconstruct decimal value
            decimal_from_bcd = 0;
            begin
                integer digit_idx;
                integer multiplier;
                reg [3:0] digit_val;
                reg digit_valid;
                digit_valid = 1;
                multiplier = 1;
                for (digit_idx = 0; digit_idx < BCD_DIGITS; digit_idx = digit_idx + 1) begin
                    digit_val = bcd_out[digit_idx*4 +: 4];
                    if (digit_val > 9) begin
                        digit_valid = 0;
                    end
                    decimal_from_bcd = decimal_from_bcd + digit_val * multiplier;
                    multiplier = multiplier * 10;
                end
                if (!digit_valid) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $display("ERROR: tb.sv Invalid BCD digit detected (each should be 0-9)");
                end
            end

            // Verify the BCD represents the correct decimal value
            if (decimal_from_bcd !== test_binary_val) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv BCD decimal value %0d doesn't match binary input %0d",
                       decimal_from_bcd, test_binary_val);
            end
        end
    end
endtask

// Task to test boundary values
task test_boundary_values;
    integer max_binary;
    integer max_bcd_decimal;
    reg [BINARY_WIDTH-1:0] test_val;
    reg [BCD_WIDTH-1:0] expected_val;
    begin
        $display("Testing boundary values");

        // Test maximum value for 3 BCD digits (999)
        // Note: This might be larger than our 8-bit binary input can represent
        max_binary = (2**BINARY_WIDTH) - 1;
        max_bcd_decimal = (10**BCD_DIGITS) - 1;

        $display("  Max binary input: %0d, Max BCD decimal: %0d", max_binary, max_bcd_decimal);

        if (max_binary <= max_bcd_decimal) begin
            // Test maximum binary value
            test_val = max_binary;
            expected_val = ref_binary_to_bcd(max_binary);
            test_conversion(test_val, expected_val, 999);
        end

        $display("  - Boundary value testing completed");
    end
endtask

// Task to test back-to-back conversions
task test_back_to_back_conversions;
    reg [BCD_WIDTH-1:0] first_result;
    reg [BCD_WIDTH-1:0] second_result;
    begin
        $display("Testing back-to-back conversions");

        // First conversion
        binary_in = 8'd42;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for completion
        wait(valid);
        first_result = bcd_out;

        // Immediate second conversion
        binary_in = 8'd87;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait for completion
        wait(valid);
        second_result = bcd_out;

        // Verify results
        if (first_result !== ref_binary_to_bcd(8'd42)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv First back-to-back conversion incorrect");
        end

        if (second_result !== ref_binary_to_bcd(8'd87)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv Second back-to-back conversion incorrect");
        end else begin
            $display("  - Back-to-back conversions working");
        end
    end
endtask


//do not edit below
task check_result;
begin
   if(ERR_COUNT > 0) begin
      $display("Test failed with %0d errors.", ERR_COUNT);
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
