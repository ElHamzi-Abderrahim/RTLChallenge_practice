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
wire [3:0] lfsr_o;

// Expected outputs from golden model
reg [3:0] lfsr_ff;
reg [3:0] nxt_lfsr;
wire [3:0] exp_lfsr_o;

int ERR_COUNT = 0;

//DUT instantiation
lfsr DUT (
    .clk(clk),
    .reset(reset),
    .lfsr_o(lfsr_o)
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
    lfsr_ff = 4'hE;

    // Hold reset for a few cycles
    repeat(3) @(posedge clk);
    reset = 0;

    // Let LFSR run for a full cycle (15 states)
    repeat(20) @(posedge clk);

    // Test reset functionality during operation
    reset = 1;
    @(posedge clk);
    reset = 0;

    // Continue for more cycles
    repeat(10) @(posedge clk);

    check_result;
end 

// Golden model for LFSR
always @(posedge clk or posedge reset) begin
    if (reset)
        lfsr_ff <= 4'hE;
    else
        lfsr_ff <= nxt_lfsr;
end

assign nxt_lfsr = {lfsr_ff[2:0], lfsr_ff[1] ^ lfsr_ff[3]};
assign exp_lfsr_o = lfsr_ff;

// Continuous checking
initial begin
    @(posedge clk); // Wait for first clock edge
    forever begin
        @(posedge clk);
        #1; // Small delay to allow outputs to settle

        if(exp_lfsr_o !== lfsr_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns lfsr_o = %b, expected = %b", $time, lfsr_o, exp_lfsr_o);
        end else begin
            $display("%0tns lfsr_o = %b", $time, lfsr_o);
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
