`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter WIDTH = 4,
    parameter RESET_CYCLES = 3,
    parameter TEST_CYCLES = 20
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg enable;
wire [WIDTH-1:0] gray_count;
wire [WIDTH-1:0] binary_count;

integer ERR_COUNT = 0;
integer cycle_count = 0;

//DUT instantiation
   gray_counter #(
      .WIDTH(WIDTH)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .enable(enable),
      .gray_count(gray_count),
      .binary_count(binary_count)
   );

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    enable = 0;

    // Reset sequence
    repeat(RESET_CYCLES) @(posedge clk);
    reset = 0;

    // Wait one cycle to observe reset value before enabling
    @(posedge clk);
    #1;
    enable = 1;

    // Run test cycles
    repeat(TEST_CYCLES) @(posedge clk);

    check_result; //must call this task to end the simulation
end

// Expected values - computed dynamically based on WIDTH
localparam MAX_COUNT = (1 << WIDTH);

function [WIDTH-1:0] expected_binary_val;
    input integer cycle;
    begin
        expected_binary_val = cycle % MAX_COUNT;
    end
endfunction

function [WIDTH-1:0] expected_gray_val;
    input integer cycle;
    reg [WIDTH-1:0] bin_val;
    begin
        bin_val = cycle % MAX_COUNT;
        expected_gray_val = bin_to_gray(bin_val);
    end
endfunction

// Function to convert binary to Gray code for verification
function [WIDTH-1:0] bin_to_gray;
    input [WIDTH-1:0] binary;
    integer i;
    begin
        bin_to_gray[WIDTH-1] = binary[WIDTH-1];
        for (i = WIDTH-2; i >= 0; i = i - 1) begin
            bin_to_gray[i] = binary[i+1] ^ binary[i];
        end
    end
endfunction

// Verification logic
reg [WIDTH-1:0] prev_gray_val;
always @(posedge clk) begin
    if (reset) begin
        cycle_count <= 0;
        prev_gray_val <= {WIDTH{1'b0}};
    end else if (enable) begin
        // Increment cycle counter first
        cycle_count <= cycle_count + 1;

        // Check binary count after a small delay - expect the value AFTER increment
        #1;
        if (binary_count !== expected_binary_val(cycle_count)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Binary count incorrect: got=%b, expected=%b, cycle=%0d",
                   $time, binary_count, expected_binary_val(cycle_count), cycle_count);
        end

        // Check Gray code
        if (gray_count !== expected_gray_val(cycle_count)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Gray count incorrect: got=%b, expected=%b, cycle=%0d",
                   $time, gray_count, expected_gray_val(cycle_count), cycle_count);
        end

        // Verify Gray code property: only one bit should change
        if (cycle_count > 0) begin
            integer bit_changes;
            reg [WIDTH-1:0] xor_result;
            xor_result = gray_count ^ prev_gray_val;
            bit_changes = $countones(xor_result);

            if (bit_changes != 1) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns Gray code violation: %0d bits changed from %b to %b",
                       $time, bit_changes, prev_gray_val, gray_count);
            end
        end

        // Verify binary to Gray conversion
        if (gray_count !== bin_to_gray(binary_count)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Binary to Gray conversion error: binary=%b, gray=%b, expected_gray=%b",
                   $time, binary_count, gray_count, bin_to_gray(binary_count));
        end

        $display("%0tns Cycle=%0d: Binary=%b, Gray=%b", $time, cycle_count, binary_count, gray_count);
        prev_gray_val <= gray_count;
    end
end

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