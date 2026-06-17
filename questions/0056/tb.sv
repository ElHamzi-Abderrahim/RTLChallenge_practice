`timescale 1ns / 1ps

//=============================================================
// SRAM Read/Write Model - User must instantiate this
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

    // Usage checker
    integer access_count = 0;

    // Initialize memory to 0 (all counters start at 0)
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
            $error("SRAM Model ERROR: Memory was never accessed! Did you instantiate and use sram_rw_model?");
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
    localparam NUM_COUNTERS = (1 << ADDR_WIDTH);

    // Operation codes
    localparam OP_NOP   = 2'b00;
    localparam OP_INC   = 2'b01;
    localparam OP_READ  = 2'b10;
    localparam OP_WRITE = 2'b11;

    reg                   clk;
    reg                   rst_n;
    reg                   cmd_valid;
    reg  [1:0]            cmd_op;
    reg  [ADDR_WIDTH-1:0] cmd_addr;
    reg  [DATA_WIDTH-1:0] cmd_wdata;
    wire                  cmd_ready;
    wire                  resp_valid;
    wire [DATA_WIDTH-1:0] resp_data;

    integer ERR_COUNT = 0;

    // Reference model
    reg [DATA_WIDTH-1:0] ref_counters [0:NUM_COUNTERS-1];

    integer idx;
    initial begin
        for (idx = 0; idx < NUM_COUNTERS; idx = idx + 1) begin
            ref_counters[idx] = {DATA_WIDTH{1'b0}};
        end
    end

    // DUT
    counter_manager #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .cmd_valid(cmd_valid),
        .cmd_op(cmd_op),
        .cmd_addr(cmd_addr),
        .cmd_wdata(cmd_wdata),
        .cmd_ready(cmd_ready),
        .resp_valid(resp_valid),
        .resp_data(resp_data)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tasks
    task do_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        integer timeout;
        begin
            @(posedge clk);
            while (!cmd_ready) @(posedge clk);
            cmd_valid <= 1'b1;
            cmd_op    <= OP_WRITE;
            cmd_addr  <= addr;
            cmd_wdata <= data;
            @(posedge clk);
            cmd_valid <= 1'b0;

            timeout = 0;
            while (!cmd_ready && timeout < 50) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            ref_counters[addr] = data;
            $display("WRITE: counter[%0d] = %0d", addr, data);
        end
    endtask

    task do_increment(input [ADDR_WIDTH-1:0] addr);
        integer timeout;
        begin
            @(posedge clk);
            while (!cmd_ready) @(posedge clk);
            cmd_valid <= 1'b1;
            cmd_op    <= OP_INC;
            cmd_addr  <= addr;
            @(posedge clk);
            cmd_valid <= 1'b0;

            timeout = 0;
            while (!cmd_ready && timeout < 50) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            ref_counters[addr] = ref_counters[addr] + 1;
            $display("INCREMENT: counter[%0d] -> %0d", addr, ref_counters[addr]);
        end
    endtask

    task do_read(input [ADDR_WIDTH-1:0] addr);
        integer timeout;
        reg [DATA_WIDTH-1:0] expected;
        begin
            expected = ref_counters[addr];

            @(posedge clk);
            while (!cmd_ready) @(posedge clk);
            cmd_valid <= 1'b1;
            cmd_op    <= OP_READ;
            cmd_addr  <= addr;
            @(posedge clk);
            cmd_valid <= 1'b0;

            timeout = 0;
            while (!resp_valid && timeout < 50) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 50) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("READ TIMEOUT: addr=%0d", addr);
            end else if (resp_data !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("READ MISMATCH: counter[%0d] expected=%0d, got=%0d",
                       addr, expected, resp_data);
            end else begin
                $display("READ: counter[%0d] = %0d (correct)", addr, resp_data);
            end

            while (!cmd_ready) @(posedge clk);
        end
    endtask

    // Test sequence
    initial begin
        rst_n = 0;
        cmd_valid = 0;
        cmd_op = 0;
        cmd_addr = 0;
        cmd_wdata = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Counter Manager (ADDR_WIDTH=%0d, DATA_WIDTH=%0d) ===",
                 ADDR_WIDTH, DATA_WIDTH);

        // Test 1: Write and read back
        $display("\n--- Test 1: Write and Read ---");
        do_write(0, 100);
        do_read(0);
        do_write(5, 50);
        do_read(5);

        // Test 2: Increment
        $display("\n--- Test 2: Increment ---");
        do_increment(0);
        do_read(0);
        do_increment(0);
        do_increment(0);
        do_read(0);

        // Test 3: Multiple counters
        $display("\n--- Test 3: Multiple Counters ---");
        do_write(1, 10);
        do_write(2, 20);
        do_write(3, 30);
        do_increment(1);
        do_increment(2);
        do_increment(2);
        do_increment(3);
        do_increment(3);
        do_increment(3);
        do_read(1);
        do_read(2);
        do_read(3);

        // Test 4: Verify all modified counters
        $display("\n--- Test 4: Final Verification ---");
        do_read(0);
        do_read(1);
        do_read(2);
        do_read(3);
        do_read(5);

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
