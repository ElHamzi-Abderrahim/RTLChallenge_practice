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
reg d_i;
wire q_norst_o;
wire q_syncrst_o;
wire q_asyncrst_o;

// Expected outputs from golden model
reg exp_q_norst_o;
reg exp_q_syncrst_o;
reg exp_q_asyncrst_o;

int ERR_COUNT = 0;

//DUT instantiation
d_flip_flop DUT (
    .clk(clk),
    .reset(reset),
    .d_i(d_i),
    .q_norst_o(q_norst_o),
    .q_syncrst_o(q_syncrst_o),
    .q_asyncrst_o(q_asyncrst_o)
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
    d_i = 0;

    // Hold reset for a few cycles
    repeat(3) @(posedge clk);
    reset = 0;

    // Test sequence
    @(posedge clk);
    d_i = #1 1;
    @(posedge clk);
    d_i = #1 0;
    @(posedge clk);
    d_i = #1 1;
    @(posedge clk);

    // Test with reset assertion
    reset = #1 1;
    @(posedge clk);
    reset = #1 0;
    d_i = #1 1;
    @(posedge clk);
    d_i = #1 0;
    @(posedge clk);

    // More test patterns
    repeat(10) begin
        d_i = #1 $random;
        @(posedge clk);
    end

    // Final check
    repeat(5) @(posedge clk);

    check_result;
end 

// golden solution
always @(posedge clk)
   exp_q_norst_o <= d_i;

// Sync reset
always @(posedge clk)
   if (reset)
     exp_q_syncrst_o <= 1'b0;
   else
     exp_q_syncrst_o <= d_i;

// Async reset
always @(posedge clk or posedge reset)
   if (reset)
     exp_q_asyncrst_o <= 1'b0;
   else
     exp_q_asyncrst_o <= d_i;

// Continuous checking
initial begin
    forever begin
        @(posedge clk);
        #1; // Small delay to allow outputs to settle
        if(exp_q_asyncrst_o !== q_asyncrst_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns q_asyncrst_o = %b, expected = %b", $time, q_asyncrst_o, exp_q_asyncrst_o);
        end else begin
            $display("%0tns q_asyncrst_o = %b, d_i = %b, reset = %b", $time, q_asyncrst_o, d_i, reset);
        end

        if(exp_q_syncrst_o !== q_syncrst_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns q_syncrst_o = %b, expected = %b", $time, q_syncrst_o, exp_q_syncrst_o);
        end else begin
            $display("%0tns q_syncrst_o = %b, d_i = %b, reset = %b", $time, q_syncrst_o, d_i, reset);
        end

        if(exp_q_norst_o !== q_norst_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns q_norst_o = %b, expected = %b", $time, q_norst_o, exp_q_norst_o);
        end else begin
            $display("%0tns q_norst_o = %b, d_i = %b, reset = %b", $time, q_norst_o, d_i, reset);
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
