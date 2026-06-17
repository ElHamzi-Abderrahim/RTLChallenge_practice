`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH  = 8,
    parameter PARITY_TYPE = 0
    //---------------------------------------------------------
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg  [DATA_WIDTH-1:0] data_in;
    reg                   mode;
    reg                   parity_in;
    wire                  parity_out;
    wire                  error;

    integer ERR_COUNT = 0;

    //---------------------------------------------------------
    // Instantiate DUT
    //---------------------------------------------------------
    parity_gen_check #(
        .DATA_WIDTH(DATA_WIDTH),
        .PARITY_TYPE(PARITY_TYPE)
    ) DUT (
        .data_in(data_in),
        .mode(mode),
        .parity_in(parity_in),
        .parity_out(parity_out),
        .error(error)
    );

    //---------------------------------------------------------
    // Reference Model Functions
    //---------------------------------------------------------
    function ref_parity_gen(input [DATA_WIDTH-1:0] d);
        reg xor_result;
        integer i;
        begin
            xor_result = 0;
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                xor_result = xor_result ^ d[i];
            end
            // Even parity: return xor_result
            // Odd parity: return ~xor_result
            ref_parity_gen = (PARITY_TYPE == 0) ? xor_result : ~xor_result;
        end
    endfunction

    function ref_parity_check(input [DATA_WIDTH-1:0] d, input p_in);
        reg xor_result;
        integer i;
        begin
            xor_result = 0;
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                xor_result = xor_result ^ d[i];
            end
            xor_result = xor_result ^ p_in;
            // Even parity: error if xor_result != 0
            // Odd parity: error if xor_result != 1
            ref_parity_check = (PARITY_TYPE == 0) ? xor_result : ~xor_result;
        end
    endfunction

    //---------------------------------------------------------
    // Core Testing Logic
    //---------------------------------------------------------
    task test_generate(input [DATA_WIDTH-1:0] d);
        reg expected_parity;
        begin
            data_in = d;
            mode = 0;
            parity_in = 0;
            #2;
            expected_parity = ref_parity_gen(d);
            if (parity_out !== expected_parity) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Generate mismatch: data=%b, expected_parity=%b, got=%b",
                       d, expected_parity, parity_out);
            end
        end
    endtask

    task test_check(input [DATA_WIDTH-1:0] d, input p_in);
        reg expected_error;
        begin
            data_in = d;
            mode = 1;
            parity_in = p_in;
            #2;
            expected_error = ref_parity_check(d, p_in);
            if (error !== expected_error) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Check mismatch: data=%b, parity_in=%b, expected_error=%b, got=%b",
                       d, p_in, expected_error, error);
            end
        end
    endtask

    //---------------------------------------------------------
    // Test Sequence
    //---------------------------------------------------------
    integer max_tests;
    integer step;
    integer j;

    initial begin
        if (DATA_WIDTH <= 12) begin
            max_tests = (1 << DATA_WIDTH);
            step = 1;
        end else begin
            max_tests = 4096;
            step = (1 << DATA_WIDTH) / 4096;
            if (step < 1) step = 1;
        end

        $display("=== Testing %0d patterns (DATA_WIDTH=%0d, PARITY_TYPE=%0d) ===",
                 max_tests, DATA_WIDTH, PARITY_TYPE);

        // Test generate mode
        $display("Testing generate mode...");
        for (j = 0; j < max_tests; j = j + 1) begin
            test_generate(j * step);
        end

        // Test check mode with correct parity
        $display("Testing check mode with correct parity...");
        for (j = 0; j < max_tests; j = j + 1) begin
            test_check(j * step, ref_parity_gen(j * step));
        end

        // Test check mode with incorrect parity
        $display("Testing check mode with incorrect parity...");
        for (j = 0; j < max_tests; j = j + 1) begin
            test_check(j * step, ~ref_parity_gen(j * step));
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
