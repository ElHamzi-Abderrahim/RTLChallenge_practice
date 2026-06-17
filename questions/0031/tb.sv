`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter WIDTH = 4,
    parameter RESET_CYCLES = 2,
    parameter TEST_CYCLES = 10
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg enable;
wire [WIDTH-1:0] count_out;

int ERR_COUNT = 0;
int cycle_count = 0;

//DUT instantiation
   johnson_counter #(
      .WIDTH(WIDTH)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .enable(enable),
      .count_out(count_out)
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
    enable = 1;

    // Run test cycles
    repeat(TEST_CYCLES) @(posedge clk);

    check_result; //must call this task to end the simulation
end

// Golden model - tracks previous state to compute expected current value
reg [WIDTH-1:0] prev_state;

// golden solution
always @(posedge clk) begin
    if (reset) begin
        cycle_count <= 0;
        prev_state <= {WIDTH{1'b0}};
    end else if (enable) begin
        reg [WIDTH-1:0] expected;
        // Expected is Johnson counter advance of previous state
        expected = {prev_state[WIDTH-2:0], ~prev_state[WIDTH-1]};
        #1;
        // Skip cycle 0 check (DUT outputs reset value on first enabled clock)
        // Start comparing from cycle 1 onwards
        if (cycle_count > 0) begin
            if(count_out !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns Count_out = %0b, expected = %0b, cycle = %0d", $time, count_out, expected, cycle_count);
            end else begin
                $display("%0tns Count_out = %0b, cycle = %0d", $time, count_out, cycle_count);
            end
        end else begin
            $display("%0tns Count_out = %0b, cycle = %0d (first cycle after reset)", $time, count_out, cycle_count);
        end
        prev_state <= count_out;  // Store current output for next cycle
        cycle_count <= cycle_count + 1;
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