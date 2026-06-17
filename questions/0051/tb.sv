`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter WIDTH = 4
    //---------------------------------------------------------
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg  [WIDTH-1:0] gray_in;
    wire [WIDTH-1:0] binary_out;

    integer ERR_COUNT = 0;

    //---------------------------------------------------------
    // Instantiate DUT
    //---------------------------------------------------------
    gray_to_binary #(
        .WIDTH(WIDTH)
    ) DUT (
        .gray_in(gray_in),
        .binary_out(binary_out)
    );

    //---------------------------------------------------------
    // Reference Model Function
    //---------------------------------------------------------
    function [WIDTH-1:0] ref_gray_to_bin(input [WIDTH-1:0] g);
        integer i;
        begin
            ref_gray_to_bin[WIDTH-1] = g[WIDTH-1];
            for (i = WIDTH-2; i >= 0; i = i - 1) begin
                ref_gray_to_bin[i] = ref_gray_to_bin[i+1] ^ g[i];
            end
        end
    endfunction

    //---------------------------------------------------------
    // Core Testing Logic
    //---------------------------------------------------------
    task apply_test(input [WIDTH-1:0] g);
        reg [WIDTH-1:0] expected;
        begin
            gray_in = g;
            #2;
            expected = ref_gray_to_bin(g);
            if (binary_out !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Mismatch: gray_in=%b, expected=%b, got=%b",
                       g, expected, binary_out);
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
        if (WIDTH <= 16) begin
            max_tests = (1 << WIDTH);
            step = 1;
        end else begin
            max_tests = 4096;
            step = (1 << WIDTH) / 4096;
            if (step < 1) step = 1;
        end

        $display("=== Testing %0d patterns (WIDTH=%0d) ===", max_tests, WIDTH);

        for (j = 0; j < max_tests; j = j + 1) begin
            apply_test(j * step);
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
