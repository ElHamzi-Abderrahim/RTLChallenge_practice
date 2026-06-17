`timescale 1us / 1ns

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter CLK_FREQ = 1000000,    // 1 MHz for fast simulation
    parameter BAUD_RATE = 115200,    // Standard baud rate: ~8.68 clocks/bit
    parameter TEST_DATA_1 = 85,      // 0x55
    parameter TEST_DATA_2 = 170,     // 0xAA
    parameter TEST_DATA_3 = 255      // 0xFF
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30000; // 30ms timeout in microseconds
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;
wire tx_out;
wire tx_busy;

int ERR_COUNT = 0;

//DUT instantiation
   uart_transmitter #(
      .CLK_FREQ(CLK_FREQ),
      .BAUD_RATE(BAUD_RATE)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .tx_start(tx_start),
      .tx_data(tx_data),
      .tx_out(tx_out),
      .tx_busy(tx_busy)
   );

// Clock generation - 1 MHz = 1us period
initial begin
    clk = 0;
    forever #0.5 clk = ~clk; // 0.5us per half-period = 1us full period
end

// Test sequence
initial begin
    // Initialize
    reset = 1;
    tx_start = 0;
    tx_data = 8'h00;

    $display("==============================================");
    $display("UART Transmitter Test");
    $display("CLK_FREQ = %0d Hz, BAUD_RATE = %0d", CLK_FREQ, BAUD_RATE);
    $display("CLKS_PER_BIT = %0d", CLKS_PER_BIT);
    $display("==============================================\n");

    // Reset sequence
    repeat(5) @(posedge clk);
    reset = 0;
    repeat(2) @(posedge clk);

    // Test data patterns from input vectors
    test_transmission(TEST_DATA_1);
    repeat(20) @(posedge clk);

    test_transmission(TEST_DATA_2);
    repeat(20) @(posedge clk);

    test_transmission(TEST_DATA_3);
    repeat(20) @(posedge clk);

    check_result;
end

// Task to test a single transmission
task test_transmission(input [7:0] data);
    reg [9:0] expected_frame;
    int bit_num;
    int start_time;

    begin
        $display("\n========================================");
        $display("[%0tus] Testing transmission of 0x%02X (%08b)", $time, data, data);
        $display("========================================");

        // Build expected frame: {stop, data[7:0], start}
        expected_frame = {1'b1, data, 1'b0};

        // Check initial idle state
        if (tx_out !== 1'b1) begin
            ERR_COUNT++;
            $error("[%0tus] TX line should be idle (high) before transmission", $time);
        end

        if (tx_busy !== 1'b0) begin
            ERR_COUNT++;
            $error("[%0tus] TX should not be busy before transmission", $time);
        end

        // Start transmission
        tx_data = data;
        tx_start = 0;  // Ensure it starts low
        @(posedge clk);
        tx_start = 1;
        $display("[%0tus] Asserting tx_start", $time);
        @(posedge clk);
        tx_start = 0;  // Drop immediately after one cycle

        // Wait for tx_busy to assert
        @(posedge clk);
        #1;
        start_time = $time;
        if (tx_busy !== 1'b1) begin
            ERR_COUNT++;
            $error("[%0tus] tx_busy should be asserted after tx_start", $time);
        end else begin
            $display("[%0tus] tx_busy asserted - transmission started", $time);
        end

        // Check each bit: start + 8 data bits + stop = 10 bits total
        for (bit_num = 0; bit_num < 10; bit_num = bit_num + 1) begin
            // Wait for the middle of the bit period to sample
            repeat(CLKS_PER_BIT/2) @(posedge clk);
            #1;
            // Check bit value
            if (tx_out !== expected_frame[bit_num]) begin
                ERR_COUNT++;
                $error("[%0tus] Bit %0d: expected %b, got %b",
                       $time, bit_num, expected_frame[bit_num], tx_out);
            end else begin
                if (bit_num == 0)
                    $display("[%0tus]   Start bit: %b (correct)", $time, tx_out);
                else if (bit_num == 9)
                    $display("[%0tus]   Stop bit:  %b (correct)", $time, tx_out);
                else
                    $display("[%0tus]   Data[%0d]:   %b (correct)", $time, bit_num-1, tx_out);
            end

            // Wait for the rest of the bit period
            repeat(CLKS_PER_BIT - CLKS_PER_BIT/2) @(posedge clk);
        end

        // After loop ends, transmission is complete
        // Wait small delay to check signals
        #1;

        // Check that transmission completed - tx_busy should be low
        if (tx_busy !== 1'b0) begin
            ERR_COUNT++;
            $error("[%0tus] TX should not be busy after transmission complete", $time);
        end else begin
            $display("[%0tus] tx_busy deasserted - transmission complete (duration: %0tus)",
                     $time, $time - start_time);
        end

        if (tx_out !== 1'b1) begin
            ERR_COUNT++;
            $error("[%0tus] TX line should return to idle (high) after transmission", $time);
        end else begin
            $display("[%0tus] tx_out returned to idle state (1)", $time);
        end

        $display("Transmission test completed\n");
    end
endtask

// Note: The design should ignore tx_start when tx_busy is asserted
// This is a design requirement, not something we actively test here
// as it would require checking internal state changes

//do not edit below
task check_result;
begin
   if(ERR_COUNT > 0) begin
      $display("[%0tus] ======================================", $time);
      $display("[%0tus] Test FAILED with %0d errors", $time, ERR_COUNT);
      $display("[%0tus] ======================================", $time);
   end else begin
      $display("[%0tus] ======================================", $time);
      $display("[%0tus] Test PASS - All tests completed successfully!", $time);
      $display("[%0tus] ======================================", $time);
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
    $display("[%0tus] Simulation TIMEOUT - test took too long!", $time);
    $finish;
end

endmodule
