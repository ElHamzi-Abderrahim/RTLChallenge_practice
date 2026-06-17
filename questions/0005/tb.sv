`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter PATTERN = 4'b1011,
    parameter DATA_STREAM = 64'b1011010110110100001011111100001011101110111010110101101101
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg rst_n;
reg data_in;
wire pattern_detected;

int ERR_COUNT = 0;
int detection_count = 0;
int expected_detections = 0;
int bit_index = 0;
reg [3:0] golden_shift_reg = 0;

//DUT instantiation
   sequence_detector #(
      .PATTERN(PATTERN)
   ) DUT (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(data_in),
      .pattern_detected(pattern_detected)
   );

// Clock generation
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    rst_n = 0;
    data_in = 0;
    detection_count = 0;
    expected_detections = 0;
    bit_index = 63; // Start from MSB
    #25;
    rst_n = 1;

    // Empty/undriven implementation leaves the output unknown (x) -> fail
    repeat(2) @(posedge clk);
    if (pattern_detected !== 1'b0 && pattern_detected !== 1'b1) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("DUT output pattern_detected is unknown (x/z)");
    end

    // Send data stream bit by bit, one bit per clock cycle
    repeat(64) begin
        @(posedge clk);
        data_in = DATA_STREAM[bit_index];
        bit_index = bit_index - 1;
    end

    #40; // Wait a bit more

    check_result;
end

// Golden model - count expected pattern detections
always @(posedge clk) begin
    if (rst_n) begin
        golden_shift_reg <= {golden_shift_reg[2:0], data_in};
        if (golden_shift_reg == PATTERN) begin
            $display("%0tns Golden: Pattern detected at bit %0d", $time, 63-bit_index);
        end
    end
end

// Check pattern detection from DUT
always @(posedge clk) begin
   #1;
  if (pattern_detected != (golden_shift_reg == PATTERN)) begin
      ERR_COUNT = ERR_COUNT + 1;
      $error("%0tns Detection count = %0d, expected = %0d", $time, detection_count, expected_detections);      
   end else if (pattern_detected) begin
      $display("%0tns DUT: Pattern detected at bit %0d", $time, 63-bit_index);
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