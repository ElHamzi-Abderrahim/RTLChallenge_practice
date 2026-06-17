`timescale 1ns / 1ps

//=============================================================
// SRAM Model - User must instantiate this in their design
//=============================================================
module sram_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg                   rvalid
);

    localparam MEM_DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    reg [ADDR_WIDTH-1:0] addr_d;
    reg                  rd_en_d;

    // Usage checker
    integer access_count = 0;

    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = (i * 37 + 17) & ((1 << DATA_WIDTH) - 1);
        end
    end

    always @(posedge clk) begin
        addr_d  <= addr;
        rd_en_d <= rd_en;
        rvalid  <= rd_en_d;
        if (rd_en_d) begin
            rdata <= mem[addr_d];
        end
        // Track usage
        if (rd_en) begin
            access_count <= access_count + 1;
        end
    end

    // Check if memory was used at end of simulation
    final begin
        if (access_count == 0) begin
            $error("SRAM Model ERROR: Memory was never accessed! Did you instantiate and use sram_model?");
        end
    end

endmodule

//=============================================================
// Testbench
//=============================================================
module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
    //---------------------------------------------------------
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MEM_DEPTH = (1 << ADDR_WIDTH);

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg  [ADDR_WIDTH-1:0] num_reads;

    wire                  done;
    wire [DATA_WIDTH-1:0] checksum;

    integer ERR_COUNT = 0;

    //---------------------------------------------------------
    // Instantiate DUT
    //---------------------------------------------------------
    mem_read_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .num_reads(num_reads),
        .done(done),
        .checksum(checksum)
    );

    //---------------------------------------------------------
    // Memory Usage Checker - Monitor the internal SRAM signals
    //---------------------------------------------------------
    integer mem_read_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_read_count <= 0;
        end else if (DUT.u_sram.rd_en) begin
            mem_read_count <= mem_read_count + 1;
        end
    end

    //---------------------------------------------------------
    // Reference memory (same init pattern as sram_model)
    //---------------------------------------------------------
    reg [DATA_WIDTH-1:0] ref_mem [0:MEM_DEPTH-1];

    integer idx;
    initial begin
        for (idx = 0; idx < MEM_DEPTH; idx = idx + 1) begin
            ref_mem[idx] = (idx * 37 + 17) & ((1 << DATA_WIDTH) - 1);
        end
    end

    //---------------------------------------------------------
    // Clock Generation
    //---------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //---------------------------------------------------------
    // Reference Model
    //---------------------------------------------------------
    function [DATA_WIDTH-1:0] calc_expected_checksum(input [ADDR_WIDTH-1:0] n);
        reg [DATA_WIDTH-1:0] result;
        integer i;
        begin
            result = {DATA_WIDTH{1'b0}};
            for (i = 0; i < n; i = i + 1) begin
                result = result ^ ref_mem[i];
            end
            calc_expected_checksum = result;
        end
    endfunction

    //---------------------------------------------------------
    // Test Task
    //---------------------------------------------------------
    task run_test(input [ADDR_WIDTH-1:0] n_reads);
        reg [DATA_WIDTH-1:0] expected;
        integer timeout;
        integer read_count_before;
        begin
            expected = calc_expected_checksum(n_reads);
            read_count_before = mem_read_count;

            num_reads = n_reads;
            start = 1;
            @(posedge clk);
            start = 0;

            timeout = 0;
            while (!done && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            @(posedge clk);

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Test TIMEOUT: num_reads=%0d", n_reads);
            end else begin
                if (mem_read_count - read_count_before < n_reads) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("Memory not used enough: expected %0d reads, got %0d",
                           n_reads, mem_read_count - read_count_before);
                end

                if (checksum !== expected) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("Checksum mismatch: num_reads=%0d, expected=0x%h, got=0x%h",
                           n_reads, expected, checksum);
                end else begin
                    $display("PASS: num_reads=%0d, checksum=0x%h", n_reads, checksum);
                end
            end

            repeat(5) @(posedge clk);
        end
    endtask

    //---------------------------------------------------------
    // Test Sequence
    //---------------------------------------------------------
    initial begin
        rst_n = 0;
        start = 0;
        num_reads = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Memory Read Controller (ADDR_WIDTH=%0d, DATA_WIDTH=%0d) ===",
                 ADDR_WIDTH, DATA_WIDTH);

        run_test(1);
        run_test(2);
        run_test(3);
        run_test(4);
        run_test(MEM_DEPTH / 2);
        run_test(MEM_DEPTH - 1);

        check_result();
    end

    //---------------------------------------------------------
    // do not edit below
    //---------------------------------------------------------
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
