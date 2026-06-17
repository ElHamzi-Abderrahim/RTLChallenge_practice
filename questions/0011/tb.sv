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
wire [7:0] cnt_o;

// Expected outputs from golden model
reg [7:0] exp_cnt_o;

int ERR_COUNT = 0;

//DUT instantiation
odd_counter DUT (
    .clk(clk),
    .reset(reset),
    .cnt_o(cnt_o)
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
    exp_cnt_o = 8'h01;

    // Hold reset for a few cycles
    repeat(3) @(posedge clk);
    reset = 0;

    // Let counter run for several cycles
    repeat(20) @(posedge clk);

    // Test reset functionality
    reset = 1;
    @(posedge clk);
    exp_cnt_o = 8'h01; // Reset value
    @(posedge clk);
    reset = 0;

    // Continue counting
    repeat(10) @(posedge clk);

    check_result;
end 

// Golden model for odd counter
always @(posedge clk or posedge reset) begin
    if (reset)
        exp_cnt_o <= 8'h01;
    else
        exp_cnt_o <= exp_cnt_o + 8'h02;
end

// Continuous checking
initial begin
    @(posedge clk); // Wait for first clock edge
    forever begin
        @(posedge clk);
        #1; // Small delay to allow outputs to settle

        if(exp_cnt_o !== cnt_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns cnt_o = %h, expected = %h", $time, cnt_o, exp_cnt_o);
        end else begin
            $display("%0tns cnt_o = %h", $time, cnt_o);
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
