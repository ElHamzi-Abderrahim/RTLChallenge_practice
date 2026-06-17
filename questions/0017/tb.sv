`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors - No parameters for this module
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
wire empty_o;
reg [3:0] parallel_i;
wire serial_o;
wire valid_o;

// Expected outputs
reg expected_empty;
reg expected_serial;
reg expected_valid;

int ERR_COUNT = 0;

//DUT instantiation
parallel_to_serial DUT (
    .clk(clk),
    .reset(reset),
    .empty_o(empty_o),
    .parallel_i(parallel_i),
    .serial_o(serial_o),
    .valid_o(valid_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Golden model
reg [3:0] shift_ff_golden;
reg [3:0] nxt_shift_golden;
reg [2:0] count_ff_golden;
reg [2:0] nxt_count_golden;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        shift_ff_golden <= 4'h0;
        count_ff_golden <= 3'h0;
    end else begin
        shift_ff_golden <= nxt_shift_golden;
        count_ff_golden <= nxt_count_golden;
    end
end

always @(*) begin
    // Golden model logic
    expected_empty = (count_ff_golden == 3'h0);
    nxt_shift_golden = expected_empty ? parallel_i : {1'b0, shift_ff_golden[3:1]};
    expected_serial = shift_ff_golden[0];
    nxt_count_golden = (count_ff_golden == 3'h4) ? 3'h0 : count_ff_golden + 3'h1;
    expected_valid = |count_ff_golden;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    parallel_i = 4'h0;
    #20;

    reset = 0;
    #10;

    // Test 1: Load parallel data 1010 (0xA)
    parallel_i = 4'hA; // 1010
    #10; // Should load when empty

    // Let it shift out serially
    #50;

    // Test 2: Load parallel data 0101 (0x5)
    parallel_i = 4'h5; // 0101
    #10; // Should load when empty

    // Let it shift out serially
    #50;

    // Test 3: Load parallel data 1111 (0xF)
    parallel_i = 4'hF; // 1111
    #10; // Should load when empty

    // Let it shift out serially
    #50;

    check_result;
end

// Continuous checking
always @(posedge clk) begin
    #1; // Small delay to allow outputs to settle
    if(expected_empty !== empty_o || expected_serial !== serial_o || expected_valid !== valid_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns empty_o=%b (exp=%b), serial_o=%b (exp=%b), valid_o=%b (exp=%b), parallel_i=%h",
               $time, empty_o, expected_empty, serial_o, expected_serial, valid_o, expected_valid, parallel_i);
    end else begin
        $display("%0tns empty_o=%b, serial_o=%b, valid_o=%b, parallel_i=%h", $time, empty_o, serial_o, valid_o, parallel_i);
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