`timescale 1ns / 1ps

//=============================================================
// SRAM Read/Write Model - User must instantiate this in their design
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

    // Usage checker
    integer access_count = 0;

    // Initialize memory
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = (i * 17 + 5) & ((1 << DATA_WIDTH) - 1);
        end
    end

    // Memory behavior
    always @(posedge clk) begin
        // Write: immediate
        if (req && wr) begin
            mem[addr] <= wdata;
        end

        // Read: 1-cycle latency
        addr_d   <= addr;
        rd_en_d  <= req && !wr;
        rvalid   <= rd_en_d;
        if (rd_en_d) begin
            rdata <= mem[addr_d];
        end

        // Track usage
        if (req) begin
            access_count <= access_count + 1;
        end
    end

    // Check if memory was used at end of simulation
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
    //---------------------------------------------------------
    // Input Vectors
    parameter NUM_MASTERS = 4,
    parameter ADDR_WIDTH  = 8,
    parameter DATA_WIDTH  = 8
    //---------------------------------------------------------
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MEM_DEPTH = (1 << ADDR_WIDTH);

    reg                               clk;
    reg                               rst_n;

    // Master request interface
    reg  [NUM_MASTERS-1:0]            req;
    reg  [NUM_MASTERS-1:0]            req_wr;
    reg  [NUM_MASTERS*ADDR_WIDTH-1:0] req_addr;
    reg  [NUM_MASTERS*DATA_WIDTH-1:0] req_wdata;

    // Master grant interface
    wire [NUM_MASTERS-1:0]            gnt;
    wire [NUM_MASTERS*DATA_WIDTH-1:0] gnt_rdata;
    wire [NUM_MASTERS-1:0]            gnt_rvalid;

    integer ERR_COUNT = 0;

    //---------------------------------------------------------
    // Instantiate DUT
    //---------------------------------------------------------
    mem_arbiter #(
        .NUM_MASTERS(NUM_MASTERS),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .req_wr(req_wr),
        .req_addr(req_addr),
        .req_wdata(req_wdata),
        .gnt(gnt),
        .gnt_rdata(gnt_rdata),
        .gnt_rvalid(gnt_rvalid)
    );

    //---------------------------------------------------------
    // Memory Usage Checker - Monitor the internal SRAM
    //---------------------------------------------------------
    integer mem_access_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_access_count <= 0;
        end else if (DUT.u_sram.req) begin
            mem_access_count <= mem_access_count + 1;
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
    // Helper Tasks
    //---------------------------------------------------------
    task clear_requests;
        integer i;
        begin
            req = {NUM_MASTERS{1'b0}};
            req_wr = {NUM_MASTERS{1'b0}};
            req_addr = {(NUM_MASTERS*ADDR_WIDTH){1'b0}};
            req_wdata = {(NUM_MASTERS*DATA_WIDTH){1'b0}};
        end
    endtask

    task set_request(input integer master, input wr, input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] wdata);
        begin
            req[master] = 1'b1;
            req_wr[master] = wr;
            req_addr[master*ADDR_WIDTH +: ADDR_WIDTH] = addr;
            req_wdata[master*DATA_WIDTH +: DATA_WIDTH] = wdata;
        end
    endtask

    task wait_for_grant(input integer master, input integer max_cycles);
        integer cycles;
        begin
            cycles = 0;
            while (!gnt[master] && cycles < max_cycles) begin
                @(posedge clk);
                cycles = cycles + 1;
            end
            if (cycles >= max_cycles) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Grant timeout for master %0d", master);
            end
        end
    endtask

    task wait_for_rvalid(input integer master, input integer max_cycles);
        integer cycles;
        begin
            cycles = 0;
            while (!gnt_rvalid[master] && cycles < max_cycles) begin
                @(posedge clk);
                cycles = cycles + 1;
            end
            if (cycles >= max_cycles) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Read valid timeout for master %0d", master);
            end
        end
    endtask

    //---------------------------------------------------------
    // Test Sequence
    //---------------------------------------------------------
    reg [DATA_WIDTH-1:0] read_data;
    integer access_before;

    initial begin
        rst_n = 0;
        clear_requests();

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Memory Arbiter (NUM_MASTERS=%0d, ADDR_WIDTH=%0d, DATA_WIDTH=%0d) ===",
                 NUM_MASTERS, ADDR_WIDTH, DATA_WIDTH);

        //-----------------------------------------------
        // Test 1: Single master write
        //-----------------------------------------------
        $display("Test 1: Single master write");
        access_before = mem_access_count;
        set_request(0, 1, 8'h10, 8'hAB);
        wait_for_grant(0, 10);
        @(posedge clk);
        clear_requests();
        repeat(3) @(posedge clk);

        if (mem_access_count <= access_before) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Memory not accessed for write");
        end
        if (DUT.u_sram.mem[8'h10] !== 8'hAB) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Write failed: expected 0xAB at addr 0x10");
        end else begin
            $display("  PASS: Write 0xAB to addr 0x10");
        end

        //-----------------------------------------------
        // Test 2: Single master read
        //-----------------------------------------------
        $display("Test 2: Single master read");
        access_before = mem_access_count;
        set_request(0, 0, 8'h10, 8'h00);
        wait_for_grant(0, 10);
        wait_for_rvalid(0, 10);
        read_data = gnt_rdata[0*DATA_WIDTH +: DATA_WIDTH];
        @(posedge clk);
        clear_requests();
        repeat(3) @(posedge clk);

        if (mem_access_count <= access_before) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Memory not accessed for read");
        end
        if (read_data !== 8'hAB) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Read failed: expected 0xAB, got 0x%h", read_data);
        end else begin
            $display("  PASS: Read 0xAB from addr 0x10");
        end

        //-----------------------------------------------
        // Test 3: Priority arbitration
        //-----------------------------------------------
        $display("Test 3: Priority arbitration with simultaneous requests");
        clear_requests();
        set_request(0, 1, 8'h20, 8'h00);
        set_request(1, 1, 8'h21, 8'h11);
        if (NUM_MASTERS > 2) set_request(2, 1, 8'h22, 8'h22);
        if (NUM_MASTERS > 3) set_request(3, 1, 8'h23, 8'h33);

        wait_for_grant(0, 10);
        if (gnt[0] !== 1'b1) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Priority violation: Master 0 should be granted first");
        end
        $display("  Master 0 granted first (correct priority)");
        req[0] = 1'b0;
        @(posedge clk);

        wait_for_grant(1, 10);
        $display("  Master 1 granted second");
        req[1] = 1'b0;
        @(posedge clk);

        if (NUM_MASTERS > 2) begin
            wait_for_grant(2, 10);
            $display("  Master 2 granted third");
            req[2] = 1'b0;
            @(posedge clk);
        end

        if (NUM_MASTERS > 3) begin
            wait_for_grant(3, 10);
            $display("  Master 3 granted fourth");
            req[3] = 1'b0;
        end

        clear_requests();
        repeat(5) @(posedge clk);

        if (DUT.u_sram.mem[8'h20] !== 8'h00 ||
            DUT.u_sram.mem[8'h21] !== 8'h11 ||
            (NUM_MASTERS > 2 && DUT.u_sram.mem[8'h22] !== 8'h22)) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Priority writes not completed correctly");
        end else begin
            $display("  PASS: All priority writes completed");
        end

        //-----------------------------------------------
        // Test 4: Mixed read/write
        //-----------------------------------------------
        $display("Test 4: Mixed read/write operations");
        clear_requests();
        set_request(0, 0, 8'h21, 8'h00);
        set_request(1, 1, 8'h30, 8'hCC);

        wait_for_grant(0, 10);
        wait_for_rvalid(0, 10);
        read_data = gnt_rdata[0*DATA_WIDTH +: DATA_WIDTH];
        req[0] = 1'b0;
        @(posedge clk);

        wait_for_grant(1, 10);
        req[1] = 1'b0;
        @(posedge clk);

        clear_requests();
        repeat(5) @(posedge clk);

        if (read_data !== 8'h11) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Mixed test read failed: expected 0x11, got 0x%h", read_data);
        end
        if (DUT.u_sram.mem[8'h30] !== 8'hCC) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Mixed test write failed");
        end else begin
            $display("  PASS: Mixed read/write completed");
        end

        //-----------------------------------------------
        // Test 5: Memory access verification
        //-----------------------------------------------
        $display("Test 5: Memory access verification");
        if (mem_access_count < 6) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Insufficient memory accesses: got %0d, expected >= 6", mem_access_count);
        end else begin
            $display("  PASS: Memory accessed %0d times", mem_access_count);
        end

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
