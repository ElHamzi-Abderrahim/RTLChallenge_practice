`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors
    // Clock and reset generation
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns
    localparam CLK_PERIOD = 10; // 100 MHz clock

reg clk;
reg reset;
reg a_i;
wire rising_edge_o;
wire falling_edge_o;

// Expected outputs from golden model
wire exp_rising_edge_o;
wire exp_falling_edge_o;
reg a_i_prev;

int ERR_COUNT = 0;

//DUT instantiation
edge_detector DUT (
    .clk(clk),
    .reset(reset),
    .a_i(a_i),
    .rising_edge_o(rising_edge_o),
    .falling_edge_o(falling_edge_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// stimulus/test sequence
initial begin
    // Initialize signals
    reset = 1;
    a_i = 0;
    a_i_prev = 0;

    // Hold reset for a few cycles
    repeat(3) @(posedge clk);
    reset = 0;

    // Test rising edge detection
    @(posedge clk);
    a_i = #1 1; // Rising edge
    @(posedge clk);
    a_i = #1 1; // No edge
    @(posedge clk);
    a_i = #1 0; // Falling edge
    @(posedge clk);
    a_i = #1 0; // No edge
    @(posedge clk);

    // Test multiple transitions
    a_i = #1 1; // Rising edge
    @(posedge clk);
    a_i = #1 0; // Falling edge
    @(posedge clk);
    a_i = #1 1; // Rising edge
    @(posedge clk);
    a_i = #1 0; // Falling edge
    @(posedge clk);

    // Test with reset assertion
    reset = #1 1;
    a_i = #1 1;
    @(posedge clk);
    reset = #1 0;
    @(posedge clk);

    check_result;
end 

// Golden model for edge detection
always @(posedge clk) begin
    if (reset) begin
        a_i_prev <= 1'b0;
    end else begin
        a_i_prev <= a_i;
    end
end

assign exp_rising_edge_o = a_i & ~a_i_prev;
assign exp_falling_edge_o = ~a_i & a_i_prev;

// Continuous checking
initial begin
    @(posedge clk); // Wait for first clock edge
    forever begin
        @(posedge clk);
        #1; // Small delay to allow outputs to settle

        if(exp_rising_edge_o !== rising_edge_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns rising_edge_o = %b, expected = %b (a_i=%b, a_i_prev=%b)",
                   $time, rising_edge_o, exp_rising_edge_o, a_i, a_i_prev);
        end else begin
            $display("%0tns rising_edge_o = %b, a_i = %b, a_i_prev = %b", $time, rising_edge_o, a_i, a_i_prev);
        end

        if(exp_falling_edge_o !== falling_edge_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns falling_edge_o = %b, expected = %b (a_i=%b, a_i_prev=%b)",
                   $time, falling_edge_o, exp_falling_edge_o, a_i, a_i_prev);
        end else begin
            $display("%0tns falling_edge_o = %b, a_i = %b, a_i_prev = %b", $time, falling_edge_o, a_i, a_i_prev);
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
