`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DIVIDE_FACTOR = 4,
    parameter RESET_CYCLES = 3,
    parameter TEST_CYCLES = 20
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk_in;
reg reset;
reg enable;
wire clk_out;

int ERR_COUNT = 0;
int input_cycle_count = 0;
int output_toggle_count = 0;
reg prev_clk_out = 0;

//DUT instantiation
   clock_divider #(
      .DIVIDE_FACTOR(DIVIDE_FACTOR)
   ) DUT (
      .clk_in(clk_in),
      .reset(reset),
      .enable(enable),
      .clk_out(clk_out)
   );

// Clock generation
initial begin
    clk_in = 0;
    forever #5 clk_in = ~clk_in;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    enable = 0;

    // Reset sequence
    repeat(RESET_CYCLES) @(posedge clk_in);
    reset = 0;
    enable = 1;

    // Run test cycles
    repeat(TEST_CYCLES) @(posedge clk_in);

    check_result; //must call this task to end the simulation
end

// Monitor output transitions
always @(posedge clk_in) begin
    if (reset) begin
        input_cycle_count <= 0;
        output_toggle_count <= 0;
        prev_clk_out <= 0;
    end else if (enable) begin
        input_cycle_count <= input_cycle_count + 1;

        // Check for output transitions
        if (clk_out !== prev_clk_out) begin
            output_toggle_count <= output_toggle_count + 1;
            $display("%0tns Output toggled at input cycle %0d, toggle count = %0d", $time, input_cycle_count, output_toggle_count + 1);
        end
        prev_clk_out <= clk_out;

        // Check reset behavior
        if (reset && clk_out !== 1'b0) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Output should be 0 during reset, got %b", $time, clk_out);
        end

        // Check enable behavior
        if (!enable && clk_out !== 1'b0) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Output should be 0 when disabled, got %b", $time, clk_out);
        end
    end
end

// Verify division ratio at end of test
always @(posedge clk_in) begin
    if (input_cycle_count == TEST_CYCLES && enable && !reset) begin
        // For a divide-by-N counter, we expect approximately 2*TEST_CYCLES/N toggles
        int expected_toggles = (2 * TEST_CYCLES) / DIVIDE_FACTOR;
        int tolerance = 2; // Allow some tolerance

        if (output_toggle_count < (expected_toggles - tolerance) ||
            output_toggle_count > (expected_toggles + tolerance)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Incorrect division ratio: got %0d toggles, expected ~%0d", output_toggle_count, expected_toggles);
        end
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