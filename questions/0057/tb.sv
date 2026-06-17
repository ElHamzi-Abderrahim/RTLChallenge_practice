`timescale 1ns / 1ps

//=============================================================
// SRAM Model
//=============================================================
module sram_rw_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  req,
    input  wire                  wr,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] wdata,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg                   rvalid
);

    localparam MEM_DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    reg [ADDR_WIDTH-1:0] addr_d;
    reg                  rd_en_d;

    integer access_count = 0;

    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end
    end

    always @(posedge clk) begin
        if (req && wr) begin
            mem[addr] <= wdata;
        end
        addr_d   <= addr;
        rd_en_d  <= req && !wr;
        rvalid   <= rd_en_d;
        if (rd_en_d) begin
            rdata <= mem[addr_d];
        end
        if (req) begin
            access_count <= access_count + 1;
        end
    end

    final begin
        if (access_count == 0) begin
            $error("SRAM Model ERROR: Memory was never accessed!");
        end
    end

endmodule

//=============================================================
// Testbench
//=============================================================
module tb #(
    parameter BIN_ADDR_WIDTH = 4,
    parameter COUNT_WIDTH    = 8
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam NUM_BINS = (1 << BIN_ADDR_WIDTH);

    reg                      clk;
    reg                      rst_n;
    reg                      clear;
    reg                      data_valid;
    reg  [BIN_ADDR_WIDTH-1:0] data_in;
    reg                      read_req;
    reg  [BIN_ADDR_WIDTH-1:0] read_addr;
    wire                     ready;
    wire                     read_valid;
    wire [COUNT_WIDTH-1:0]   read_data;

    integer ERR_COUNT = 0;

    // Reference model
    reg [COUNT_WIDTH-1:0] ref_bins [0:NUM_BINS-1];

    integer idx;
    initial begin
        for (idx = 0; idx < NUM_BINS; idx = idx + 1) begin
            ref_bins[idx] = {COUNT_WIDTH{1'b0}};
        end
    end

    histogram_calc #(
        .BIN_ADDR_WIDTH(BIN_ADDR_WIDTH),
        .COUNT_WIDTH(COUNT_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear),
        .data_valid(data_valid),
        .data_in(data_in),
        .read_req(read_req),
        .read_addr(read_addr),
        .ready(ready),
        .read_valid(read_valid),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task add_sample(input [BIN_ADDR_WIDTH-1:0] val);
        begin
            @(posedge clk);
            while (!ready) @(posedge clk);
            data_valid <= 1'b1;
            data_in    <= val;
            @(posedge clk);
            data_valid <= 1'b0;
            while (!ready) @(posedge clk);

            if (ref_bins[val] != {COUNT_WIDTH{1'b1}}) begin
                ref_bins[val] = ref_bins[val] + 1;
            end
            $display("Added sample: bin[%0d]++, now=%0d", val, ref_bins[val]);
        end
    endtask

    task read_bin(input [BIN_ADDR_WIDTH-1:0] addr);
        integer timeout;
        begin
            @(posedge clk);
            while (!ready) @(posedge clk);
            read_req  <= 1'b1;
            read_addr <= addr;
            @(posedge clk);
            read_req <= 1'b0;

            timeout = 0;
            while (!read_valid && timeout < 50) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 50) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("READ TIMEOUT: bin[%0d]", addr);
            end else if (read_data !== ref_bins[addr]) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: bin[%0d] expected=%0d, got=%0d",
                       addr, ref_bins[addr], read_data);
            end else begin
                $display("READ: bin[%0d] = %0d (correct)", addr, read_data);
            end

            while (!ready) @(posedge clk);
        end
    endtask

    task do_clear;
        integer i;
        begin
            @(posedge clk);
            while (!ready) @(posedge clk);
            clear <= 1'b1;
            @(posedge clk);
            clear <= 1'b0;
            while (!ready) @(posedge clk);

            for (i = 0; i < NUM_BINS; i = i + 1) begin
                ref_bins[i] = 0;
            end
            $display("CLEAR: all bins reset to 0");
        end
    endtask

    initial begin
        rst_n = 0;
        clear = 0;
        data_valid = 0;
        data_in = 0;
        read_req = 0;
        read_addr = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Histogram Calculator ===");

        // Test 1: Add samples
        $display("\n--- Test 1: Add Samples ---");
        add_sample(3);
        add_sample(1);
        add_sample(3);
        add_sample(3);
        add_sample(2);
        add_sample(1);

        // Test 2: Read bins
        $display("\n--- Test 2: Read Bins ---");
        read_bin(0);
        read_bin(1);
        read_bin(2);
        read_bin(3);

        // Test 3: Clear and verify
        $display("\n--- Test 3: Clear ---");
        do_clear();
        read_bin(0);
        read_bin(1);
        read_bin(2);
        read_bin(3);

        // Test 4: Add more samples after clear
        $display("\n--- Test 4: After Clear ---");
        add_sample(0);
        add_sample(0);
        add_sample(5);
        read_bin(0);
        read_bin(5);

        check_result();
    end

    task check_result;
    begin
        if (ERR_COUNT > 0) begin
            $error("Test failed with %0d errors.", ERR_COUNT);
        end else begin
            $display("Test PASS");
        end
        $finish;
    end
    endtask

    string filename;
    initial begin
        if ($value$plusargs("VCDFILE=%s", filename)) begin
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
