`timescale 1ns / 1ps

//=============================================================
// ROM Model - User must instantiate this in their design
//=============================================================
module rom_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] rdata
);

    localparam ROM_DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [0:ROM_DEPTH-1];

    // Usage checker
    integer access_count = 0;

    // Initialize ROM with quarter-wave sine (scaled)
    integer i;
    real sine_val;
    real max_val;
    initial begin
        max_val = (1 << DATA_WIDTH) - 1;
        for (i = 0; i < ROM_DEPTH; i = i + 1) begin
            sine_val = $sin(3.14159265 * i / (2.0 * ROM_DEPTH)) * max_val;
            mem[i] = sine_val;
        end
    end

    // Combinational read (0-cycle latency)
    always @(*) begin
        if (rd_en) begin
            rdata = mem[addr];
        end else begin
            rdata = {DATA_WIDTH{1'b0}};
        end
    end

    // Track usage on clock edge
    always @(posedge clk) begin
        if (rd_en) begin
            access_count <= access_count + 1;
        end
    end

    // Check if ROM was used at end of simulation
    final begin
        if (access_count == 0) begin
            $error("ROM Model ERROR: ROM was never accessed! Did you instantiate and use rom_model?");
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
    parameter DATA_WIDTH = 8,
    parameter FRAC_BITS  = 4
    //---------------------------------------------------------
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam ROM_DEPTH = (1 << ADDR_WIDTH);
    localparam PHASE_WIDTH = ADDR_WIDTH + FRAC_BITS;

    reg                    clk;
    reg                    rst_n;
    reg                    start;
    reg  [PHASE_WIDTH-1:0] phase;

    wire                   done;
    wire [DATA_WIDTH-1:0]  result;

    integer ERR_COUNT = 0;

    //---------------------------------------------------------
    // Instantiate DUT
    //---------------------------------------------------------
    lut_interpolator #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .phase(phase),
        .done(done),
        .result(result)
    );

    //---------------------------------------------------------
    // ROM Usage Checker - Monitor the internal ROM signals
    //---------------------------------------------------------
    integer rom_read_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rom_read_count <= 0;
        end else if (DUT.u_rom.rd_en) begin
            rom_read_count <= rom_read_count + 1;
        end
    end

    //---------------------------------------------------------
    // Reference ROM (same init pattern as rom_model)
    //---------------------------------------------------------
    reg [DATA_WIDTH-1:0] ref_rom [0:ROM_DEPTH-1];

    integer idx;
    real sine_val;
    real max_val;
    initial begin
        max_val = (1 << DATA_WIDTH) - 1;
        for (idx = 0; idx < ROM_DEPTH; idx = idx + 1) begin
            sine_val = $sin(3.14159265 * idx / (2.0 * ROM_DEPTH)) * max_val;
            ref_rom[idx] = sine_val;
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
    function [DATA_WIDTH-1:0] calc_expected(input [PHASE_WIDTH-1:0] p);
        reg [ADDR_WIDTH-1:0] addr;
        reg [FRAC_BITS-1:0] frac;
        reg [DATA_WIDTH-1:0] y0, y1;
        reg signed [DATA_WIDTH:0] diff;
        reg signed [DATA_WIDTH+FRAC_BITS:0] prod;
        begin
            addr = p[PHASE_WIDTH-1:FRAC_BITS];
            frac = p[FRAC_BITS-1:0];
            y0 = ref_rom[addr];
            y1 = ref_rom[(addr + 1) % ROM_DEPTH];
            diff = {1'b0, y1} - {1'b0, y0};
            prod = diff * $signed({1'b0, frac});
            calc_expected = y0 + prod[DATA_WIDTH+FRAC_BITS-1:FRAC_BITS];
        end
    endfunction

    //---------------------------------------------------------
    // Test Task
    //---------------------------------------------------------
    task run_test(input [PHASE_WIDTH-1:0] test_phase);
        reg [DATA_WIDTH-1:0] expected;
        integer timeout;
        integer read_count_before;
        begin
            expected = calc_expected(test_phase);
            read_count_before = rom_read_count;

            phase = test_phase;
            start = 1;
            @(posedge clk);
            start = 0;

            timeout = 0;
            while (!done && timeout < 100) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            @(posedge clk);

            if (timeout >= 100) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Test TIMEOUT: phase=0x%h", test_phase);
            end else begin
                if (rom_read_count - read_count_before < 2) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("ROM not used enough: expected 2 reads, got %0d",
                           rom_read_count - read_count_before);
                end

                if (result > expected + 1 || result + 1 < expected) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("Result mismatch: phase=0x%h, expected=%0d, got=%0d",
                           test_phase, expected, result);
                end else begin
                    $display("PASS: phase=0x%h, result=%0d (expected=%0d)",
                             test_phase, result, expected);
                end
            end

            repeat(3) @(posedge clk);
        end
    endtask

    //---------------------------------------------------------
    // Test Sequence
    //---------------------------------------------------------
    integer j;
    integer step;
    integer max_phase;

    initial begin
        rst_n = 0;
        start = 0;
        phase = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing LUT Interpolator (ADDR_WIDTH=%0d, DATA_WIDTH=%0d, FRAC_BITS=%0d) ===",
                 ADDR_WIDTH, DATA_WIDTH, FRAC_BITS);

        max_phase = (1 << PHASE_WIDTH);

        run_test(0);
        run_test((1 << FRAC_BITS) - 1);
        run_test(1 << FRAC_BITS);
        run_test((ROM_DEPTH - 1) << FRAC_BITS);
        run_test(max_phase - 1);

        if (max_phase <= 256) begin
            step = 1;
        end else begin
            step = max_phase / 64;
        end

        for (j = 0; j < max_phase; j = j + step) begin
            run_test(j);
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
