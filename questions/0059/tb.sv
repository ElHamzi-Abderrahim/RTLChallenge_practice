`timescale 1ns / 1ps

//=============================================================
// SRAM Model
//=============================================================
module sram_rw_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
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
            mem[i] = i * 10;  // Simple pattern: 0, 10, 20, 30, ...
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
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MEM_DEPTH = (1 << ADDR_WIDTH);

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg  [ADDR_WIDTH-1:0] src_addr;
    reg  [ADDR_WIDTH-1:0] count;
    reg  [ADDR_WIDTH-1:0] dst_addr;
    wire                  busy;
    wire                  done;
    wire [DATA_WIDTH-1:0] result;

    integer ERR_COUNT = 0;

    // Reference memory
    reg [DATA_WIDTH-1:0] ref_mem [0:MEM_DEPTH-1];

    integer idx;
    initial begin
        for (idx = 0; idx < MEM_DEPTH; idx = idx + 1) begin
            ref_mem[idx] = idx * 10;
        end
    end

    scratchpad_acc #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .src_addr(src_addr),
        .count(count),
        .dst_addr(dst_addr),
        .busy(busy),
        .done(done),
        .result(result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task do_accumulate(input [ADDR_WIDTH-1:0] src, input [ADDR_WIDTH-1:0] cnt, input [ADDR_WIDTH-1:0] dst);
        integer timeout;
        integer i;
        reg [DATA_WIDTH-1:0] expected;
        begin
            // Calculate expected sum
            expected = 0;
            for (i = 0; i < cnt; i = i + 1) begin
                expected = expected + ref_mem[src + i];
            end

            @(posedge clk);
            while (busy) @(posedge clk);

            src_addr <= src;
            count    <= cnt;
            dst_addr <= dst;
            start    <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            timeout = 0;
            while (!done && timeout < 5000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 5000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("ACCUMULATE TIMEOUT: src=%0d, count=%0d, dst=%0d", src, cnt, dst);
            end else begin
                if (result !== expected) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("RESULT MISMATCH: expected=%0d, got=%0d", expected, result);
                end else begin
                    $display("ACCUMULATE: src=%0d, count=%0d -> sum=%0d (correct)", src, cnt, result);
                end

                // Verify memory write
                if (DUT.u_sram.mem[dst] !== expected) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("MEMORY WRITE FAILED: mem[%0d] expected=%0d, got=%0d",
                           dst, expected, DUT.u_sram.mem[dst]);
                end

                // Update reference model
                ref_mem[dst] = expected;
            end

            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        src_addr = 0;
        count = 0;
        dst_addr = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Scratchpad Accumulator ===");
        $display("Memory initialized: mem[i] = i * 10");

        // Test 1: Sum of first 4 values (0+10+20+30=60)
        $display("\n--- Test 1: Sum 4 values ---");
        do_accumulate(0, 4, 15);

        // Test 2: Sum of next 3 values (40+50+60=150)
        $display("\n--- Test 2: Sum 3 values ---");
        do_accumulate(4, 3, 14);

        // Test 3: Single value
        $display("\n--- Test 3: Single value ---");
        do_accumulate(5, 1, 13);

        // Test 4: Zero count (edge case)
        $display("\n--- Test 4: Zero count ---");
        do_accumulate(0, 0, 12);

        // Test 5: Larger sum
        $display("\n--- Test 5: Sum 8 values ---");
        do_accumulate(0, 8, 11);

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
