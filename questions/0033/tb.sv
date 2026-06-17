`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter TEST_DATA_COUNT = 12
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg wr_clk, rd_clk;
reg wr_rst_n, rd_rst_n;
reg wr_en, rd_en;
reg [DATA_WIDTH-1:0] wr_data;
wire [DATA_WIDTH-1:0] rd_data;
wire wr_full, rd_empty;

integer ERR_COUNT = 0;
integer wr_count = 0;
integer rd_count = 0;

//DUT instantiation
   async_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
   ) DUT (
      .wr_clk(wr_clk),
      .wr_rst_n(wr_rst_n),
      .wr_en(wr_en),
      .wr_data(wr_data),
      .wr_full(wr_full),
      .rd_clk(rd_clk),
      .rd_rst_n(rd_rst_n),
      .rd_en(rd_en),
      .rd_data(rd_data),
      .rd_empty(rd_empty)
   );

// Clock generation - different frequencies
initial begin
    wr_clk = 0;
    forever #7 wr_clk = ~wr_clk;  // ~71 MHz
end

initial begin
    rd_clk = 0;
    forever #11 rd_clk = ~rd_clk; // ~45 MHz
end

// Test data array
reg [DATA_WIDTH-1:0] test_data [0:TEST_DATA_COUNT-1];
reg [DATA_WIDTH-1:0] received_data [0:TEST_DATA_COUNT-1];

// Initialize test data
initial begin
    integer i;
    for (i = 0; i < TEST_DATA_COUNT; i = i + 1) begin
        test_data[i] = $random() & ((1 << DATA_WIDTH) - 1);
    end
end

// Write process
initial begin
    integer i;
    // Initialize
    wr_rst_n = 0;
    wr_en = 0;
    wr_data = 0;

    // Reset
    repeat(5) @(posedge wr_clk);
    wr_rst_n = 1;
    repeat(2) @(posedge wr_clk);

    // Write test data
    i = 0;
    while (i < TEST_DATA_COUNT) begin
        @(posedge wr_clk);
        if (!wr_full) begin
            wr_en = 1;
            wr_data = test_data[i];
            wr_count = wr_count + 1;
            $display("%0tns Write: data=0x%02x, count=%0d", $time, wr_data, wr_count);
            i = i + 1;
        end else begin
            wr_en = 0;
            $display("%0tns Write blocked - FIFO full", $time);
        end
        @(posedge wr_clk);
        wr_en = 0;

        // Random delay
        repeat($urandom_range(1,3)) @(posedge wr_clk);
    end
end

// Read process
initial begin
    // Initialize
    rd_rst_n = 0;
    rd_en = 0;

    // Reset
    repeat(5) @(posedge rd_clk);
    rd_rst_n = 1;
    repeat(5) @(posedge rd_clk);

    // Read test data
    while (rd_count < TEST_DATA_COUNT) begin
        @(posedge rd_clk);
        if (!rd_empty) begin
            rd_en = 1;
            #1; // Small delay to allow combinational logic to settle
            received_data[rd_count] = rd_data;
            $display("%0tns Read: data=0x%02x, count=%0d", $time, rd_data, rd_count);
            rd_count++;
            @(posedge rd_clk);
            rd_en = 0;
        end else begin
            rd_en = 0;
            $display("%0tns Read blocked - FIFO empty", $time);
        end

        // Random delay
        repeat($urandom_range(1,4)) @(posedge rd_clk);
    end

    // Wait a bit more
    repeat(10) @(posedge rd_clk);
    check_result;
end

// Verify data integrity
task check_result;
    integer i;
begin
    // Check if all data was received correctly
    for (i = 0; i < TEST_DATA_COUNT; i = i + 1) begin
        if (received_data[i] !== test_data[i]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv:139: Data mismatch at index %0d: sent=0x%02x, received=0x%02x",
                   i, test_data[i], received_data[i]);
        end
    end

    // Check final FIFO state
    if (!rd_empty) begin
        ERR_COUNT = ERR_COUNT + 1;
        $display("ERROR: tb.sv FIFO should be empty after reading all data");
    end

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
    $error("Simulation TIMEOUT - DUT did not complete");
    $finish;
end

endmodule