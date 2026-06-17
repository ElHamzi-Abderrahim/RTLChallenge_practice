`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors

    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns
    localparam CLK_PERIOD = 10; //ns

reg clk = 0;
reg rst = 0;
reg up_down = 1; // 1 for up, 0 for down
wire [3:0] count;
reg [3:0] expected_count;

integer ERR_COUNT = 0;

//DUT instantiation
UpDownCounter DUT(
    .clk(clk),         // Clock input
    .rst(rst),         // Reset input
    .up_down(up_down),    // Up/Down control input
    .count(count) // 4-bit counter output
);

// stimulus/test sequence
initial begin
    // Initialize inputs
    rst = 1;
    up_down = 1; // Start with counting up
    # (2*CLK_PERIOD);
    rst = 0;
    # (3*CLK_PERIOD);
    up_down = 0; // Switch to counting down
    # (3*CLK_PERIOD);
    up_down = 1; // Switch back to counting up
    # (3*CLK_PERIOD);
    check_result;
end 

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

// Golden solution
always @(posedge clk, posedge rst ) begin
   if(rst) begin
      expected_count <= 4'b0000;
   end else begin
      if (up_down) begin
         if (expected_count == 4'b1111) begin
            expected_count <= 4'b1111; // Saturate at max value
         end else begin
            expected_count <= expected_count + 1;
         end
      end else begin
         if (expected_count == 4'b0000) begin
            expected_count <= 4'b0000; // Saturate at min value
         end else begin
            expected_count <= expected_count - 1;
         end
      end
   end
end

// Check DUT output against expected value
always @(posedge clk) begin
   #1; // small delay to allow DUT output to stabilize
   if (count !== expected_count) begin
         $error("Mismatch at time %0t: expected %0d, got %0d", $time, expected_count, count);
         ERR_COUNT = ERR_COUNT + 1;
   end else begin
         $display("Match at time %0t: count = %0d", $time, count);
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
