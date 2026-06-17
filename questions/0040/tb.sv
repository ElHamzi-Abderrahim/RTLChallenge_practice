`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter CRC_WIDTH = 8,
    parameter POLYNOMIAL = 8'h07,
    parameter TEST_DATA_1 = 72,
    parameter TEST_DATA_2 = 101,
    parameter TEST_DATA_3 = 108,
    parameter TEST_DATA_4 = 108
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg data_valid;
reg [7:0] data_in;
reg start;
wire [CRC_WIDTH-1:0] crc_out;
wire crc_valid;

int ERR_COUNT = 0;

//DUT instantiation
   crc_calculator #(
      .CRC_WIDTH(CRC_WIDTH),
      .POLYNOMIAL(POLYNOMIAL)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .data_valid(data_valid),
      .data_in(data_in),
      .start(start),
      .crc_out(crc_out),
      .crc_valid(crc_valid)
   );

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Reference CRC-8 calculation function
function [7:0] calc_crc8_byte;
    input [7:0] crc_in;
    input [7:0] data_byte;
    input [7:0] poly;
    reg [7:0] crc;
    integer j;
    begin
        crc = crc_in ^ data_byte;

        for (j = 0; j < 8; j = j + 1) begin
            if (crc[7]) begin
                crc = (crc << 1) ^ poly;
            end else begin
                crc = crc << 1;
            end
        end

        calc_crc8_byte = crc;
    end
endfunction

// Test sequence
initial begin
    // Initialize
    reset = 1;
    data_valid = 0;
    data_in = 8'h00;
    start = 0;

    // Reset sequence
    repeat(5) @(posedge clk);
    reset = 0;
    repeat(2) @(posedge clk);

    // Test 1: Single byte
    test_single_byte(TEST_DATA_1);
    repeat(10) @(posedge clk);

    // Test 2: Four bytes from input vectors
    test_four_bytes(TEST_DATA_1, TEST_DATA_2, TEST_DATA_3, TEST_DATA_4);
    repeat(10) @(posedge clk);

    // Test 3: All zeros
    test_four_bytes(8'h00, 8'h00, 8'h00, 8'h00);
    repeat(10) @(posedge clk);

    // Test 4: Pattern data
    test_four_bytes(8'hAA, 8'h55, 8'hFF, 8'h00);
    repeat(10) @(posedge clk);

    // Test 5: Start signal resets calculation
    test_start_reset();
    repeat(10) @(posedge clk);

    check_result;
end

// Task to test single byte CRC
task test_single_byte;
    input [7:0] test_byte;
    reg [7:0] expected_crc;
    begin
        $display("Testing single byte: 0x%02X", test_byte);

        expected_crc = calc_crc8_byte(8'h00, test_byte, POLYNOMIAL);

        // Start new calculation
        @(posedge clk);
        #1
        start = 1;
        @(posedge clk);
        #1;
        start = 0;

        // Send data byte
        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = test_byte;
        @(posedge clk);
        #1
        data_valid = 0;

        // Wait for CRC to be valid
        repeat(5) @(posedge clk);
        #1;
        // Check result
        if (!crc_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("CRC not valid after data transmission");
        end else if (crc_out !== expected_crc) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("CRC mismatch: got 0x%02X, expected 0x%02X", crc_out, expected_crc);
        end else begin
            $display("  CRC correct: 0x%02X", crc_out);
        end
    end
endtask

// Task to test four bytes CRC
task test_four_bytes;
    input [7:0] byte1;
    input [7:0] byte2;
    input [7:0] byte3;
    input [7:0] byte4;
    reg [7:0] expected_crc;
    begin
        $display("Testing four bytes: 0x%02X 0x%02X 0x%02X 0x%02X", byte1, byte2, byte3, byte4);

        // Calculate expected CRC
        expected_crc = calc_crc8_byte(8'h00, byte1, POLYNOMIAL);
        expected_crc = calc_crc8_byte(expected_crc, byte2, POLYNOMIAL);
        expected_crc = calc_crc8_byte(expected_crc, byte3, POLYNOMIAL);
        expected_crc = calc_crc8_byte(expected_crc, byte4, POLYNOMIAL);

        // Start new calculation
        @(posedge clk);
        #1;
        start = 1;
        @(posedge clk);
        #1;
        start = 0;

        // Send bytes
        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = byte1;
        @(posedge clk);
        #1;
        data_valid = 0;

        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = byte2;
        @(posedge clk);
        #1;
        data_valid = 0;

        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = byte3;
        @(posedge clk);
        #1;
        data_valid = 0;

        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = byte4;
        @(posedge clk);
        #1;
        data_valid = 0;

        // Wait for CRC to be valid
        repeat(5) @(posedge clk);
        #1;
        // Check result
        if (!crc_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("CRC not valid after data transmission");
        end else if (crc_out !== expected_crc) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("CRC mismatch: got 0x%02X, expected 0x%02X", crc_out, expected_crc);
        end else begin
            $display("  CRC correct: 0x%02X", crc_out);
        end
    end
endtask

// Task to test start signal resets CRC
task test_start_reset;
    reg [7:0] expected_crc;
    begin
        $display("Testing start signal resets calculation");

        // Start calculation
        @(posedge clk);
        #1;
        start = 1;
        @(posedge clk);
        #1;
        start = 0;

        // Send first byte
        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = 8'hAB;
        @(posedge clk);
        #1;
        data_valid = 0;

        // Start again (should reset)
        @(posedge clk);
        #1;
        start = 1;
        @(posedge clk);
        #1;
        start = 0;

        // Send different byte
        @(posedge clk);
        #1;
        data_valid = 1;
        data_in = 8'hCD;
        @(posedge clk);
        #1;
        data_valid = 0;

        repeat(5) @(posedge clk);
        #1;    

        // CRC should be for 0xCD only
        expected_crc = calc_crc8_byte(8'h00, 8'hCD, POLYNOMIAL);

        if (crc_out !== expected_crc) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Start signal did not reset CRC: got 0x%02X, expected 0x%02X", crc_out, expected_crc);
        end else begin
            $display("  Start signal correctly resets calculation");
        end
    end
endtask

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
