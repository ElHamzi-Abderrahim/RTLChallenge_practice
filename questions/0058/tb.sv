`timescale 1ns / 1ps

//=============================================================
// SRAM Model
//=============================================================
module sram_rw_model #(
    parameter ADDR_WIDTH = 8,
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
            mem[i] = (i * 17 + 5) & ((1 << DATA_WIDTH) - 1);
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
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MEM_DEPTH = (1 << ADDR_WIDTH);

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg  [ADDR_WIDTH-1:0] src_addr;
    reg  [ADDR_WIDTH-1:0] dst_addr;
    reg  [ADDR_WIDTH-1:0] length;
    wire                  busy;
    wire                  done;

    integer ERR_COUNT = 0;

    // Reference memory
    reg [DATA_WIDTH-1:0] ref_mem [0:MEM_DEPTH-1];

    integer idx;
    initial begin
        for (idx = 0; idx < MEM_DEPTH; idx = idx + 1) begin
            ref_mem[idx] = (idx * 17 + 5) & ((1 << DATA_WIDTH) - 1);
        end
    end

    mem_copy_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .length(length),
        .busy(busy),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task do_copy(input [ADDR_WIDTH-1:0] src, input [ADDR_WIDTH-1:0] dst, input [ADDR_WIDTH-1:0] len);
        integer timeout;
        integer i;
        begin
            @(posedge clk);
            while (busy) @(posedge clk);

            src_addr <= src;
            dst_addr <= dst;
            length   <= len;
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
                $error("COPY TIMEOUT: src=0x%h, dst=0x%h, len=%0d", src, dst, len);
            end else begin
                // Update reference model
                for (i = 0; i < len; i = i + 1) begin
                    ref_mem[dst + i] = ref_mem[src + i];
                end
                $display("COPY: src=0x%h, dst=0x%h, len=%0d completed", src, dst, len);
            end

            @(posedge clk);
        end
    endtask

    task verify_region(input [ADDR_WIDTH-1:0] addr, input [ADDR_WIDTH-1:0] len);
        integer i;
        reg [DATA_WIDTH-1:0] actual;
        begin
            for (i = 0; i < len; i = i + 1) begin
                actual = DUT.u_sram.mem[addr + i];
                if (actual !== ref_mem[addr + i]) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("VERIFY FAILED: mem[0x%h] expected=0x%h, got=0x%h",
                           addr + i, ref_mem[addr + i], actual);
                end
            end
            if (ERR_COUNT == 0) begin
                $display("VERIFY: region 0x%h-0x%h OK", addr, addr + len - 1);
            end
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        src_addr = 0;
        dst_addr = 0;
        length = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Memory Copy Controller ===");

        // Test 1: Simple copy
        $display("\n--- Test 1: Simple Copy ---");
        do_copy(8'h00, 8'h10, 4);
        verify_region(8'h10, 4);

        // Test 2: Longer copy
        $display("\n--- Test 2: Longer Copy ---");
        do_copy(8'h20, 8'h40, 8);
        verify_region(8'h40, 8);

        // Test 3: Single word copy
        $display("\n--- Test 3: Single Word ---");
        do_copy(8'h05, 8'h60, 1);
        verify_region(8'h60, 1);

        // Test 4: Zero length (edge case)
        $display("\n--- Test 4: Zero Length ---");
        do_copy(8'h00, 8'h70, 0);

        // Test 5: Another copy to verify state reset
        $display("\n--- Test 5: Another Copy ---");
        do_copy(8'h30, 8'h80, 6);
        verify_region(8'h80, 6);

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
