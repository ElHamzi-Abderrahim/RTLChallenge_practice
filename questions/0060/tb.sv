`timescale 1ns / 1ps

//=============================================================
// SRAM Model with Read/Write
//=============================================================
module sram_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rd_en,
    input  wire                  wr_en,
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
        // Write
        if (wr_en) begin
            mem[addr] <= wdata;
        end

        // Read with 1-cycle latency
        addr_d  <= addr;
        rd_en_d <= rd_en;
        rvalid  <= rd_en_d;
        if (rd_en_d) begin
            rdata <= mem[addr_d];
        end

        if (rd_en || wr_en) begin
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
    parameter DATA_WIDTH = 8
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam NUM_REGS = (1 << ADDR_WIDTH);

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg  [ADDR_WIDTH-1:0] count;
    reg                   write_en;
    reg  [ADDR_WIDTH-1:0] write_addr;
    reg  [DATA_WIDTH-1:0] write_data;
    wire                  busy;
    wire                  done;
    wire [DATA_WIDTH-1:0] max_val;
    wire [ADDR_WIDTH-1:0] max_idx;

    integer ERR_COUNT = 0;

    // Reference model
    reg [DATA_WIDTH-1:0] ref_regs [0:NUM_REGS-1];

    integer idx;
    initial begin
        for (idx = 0; idx < NUM_REGS; idx = idx + 1) begin
            ref_regs[idx] = {DATA_WIDTH{1'b0}};
        end
    end

    regfile_max #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .count(count),
        .write_en(write_en),
        .write_addr(write_addr),
        .write_data(write_data),
        .busy(busy),
        .done(done),
        .max_val(max_val),
        .max_idx(max_idx)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task write_reg(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            while (busy) @(posedge clk);
            write_en   <= 1'b1;
            write_addr <= addr;
            write_data <= data;
            @(posedge clk);
            write_en <= 1'b0;
            ref_regs[addr] = data;
            $display("WRITE: reg[%0d] = %0d", addr, data);
        end
    endtask

    task find_max(input [ADDR_WIDTH-1:0] cnt);
        integer timeout;
        integer i;
        reg [DATA_WIDTH-1:0] exp_max;
        reg [ADDR_WIDTH-1:0] exp_idx;
        begin
            // Calculate expected
            exp_max = 0;
            exp_idx = 0;
            for (i = 0; i < cnt; i = i + 1) begin
                if (ref_regs[i] > exp_max) begin
                    exp_max = ref_regs[i];
                    exp_idx = i;
                end
            end

            @(posedge clk);
            while (busy) @(posedge clk);

            count <= cnt;
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            timeout = 0;
            while (!done && timeout < 5000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 5000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("FIND_MAX TIMEOUT: count=%0d", cnt);
            end else begin
                if (max_val !== exp_max || max_idx !== exp_idx) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("MAX MISMATCH: expected val=%0d idx=%0d, got val=%0d idx=%0d",
                           exp_max, exp_idx, max_val, max_idx);
                end else begin
                    $display("FIND_MAX: count=%0d -> max=%0d at idx=%0d (correct)",
                             cnt, max_val, max_idx);
                end
            end

            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        count = 0;
        write_en = 0;
        write_addr = 0;
        write_data = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Register File Max Finder ===");

        // Write some values
        $display("\n--- Setup: Write values ---");
        write_reg(0, 50);
        write_reg(1, 30);
        write_reg(2, 90);
        write_reg(3, 20);
        write_reg(4, 70);
        write_reg(5, 10);

        // Test 1: Find max in first 4 registers
        $display("\n--- Test 1: Max in 4 registers ---");
        find_max(4);

        // Test 2: Find max in first 6 registers
        $display("\n--- Test 2: Max in 6 registers ---");
        find_max(6);

        // Test 3: Find max in all written registers
        $display("\n--- Test 3: Update and find max ---");
        write_reg(3, 100);  // New max
        find_max(6);

        // Test 4: Single register
        $display("\n--- Test 4: Single register ---");
        find_max(1);

        // Test 5: Zero count
        $display("\n--- Test 5: Zero count ---");
        find_max(0);

        // Test 6: Tie handling (first occurrence wins)
        $display("\n--- Test 6: Tie handling ---");
        write_reg(0, 100);  // Same as reg[3]
        find_max(6);        // Should return idx=0 (first occurrence)

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
