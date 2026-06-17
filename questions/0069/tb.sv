`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 16
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_data;
    reg                   in_last;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire                  out_is_palindrome;

    integer ERR_COUNT = 0;

    palindrome_check #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_SIZE(MAX_SIZE)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_valid(in_valid),
        .in_data(in_data),
        .in_last(in_last),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_is_palindrome(out_is_palindrome)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test data storage
    reg [DATA_WIDTH-1:0] test_data [0:MAX_SIZE-1];
    integer test_size;

    // Check if test_data is palindrome (reference)
    function automatic is_palindrome_ref;
        integer i;
        begin
            is_palindrome_ref = 1;
            for (i = 0; i < test_size / 2; i = i + 1) begin
                if (test_data[i] != test_data[test_size - 1 - i]) begin
                    is_palindrome_ref = 0;
                end
            end
        end
    endfunction

    // Send sequence and check result
    task automatic test_sequence(input reg expected);
        integer i;
        integer timeout;
        begin
            // Print sequence
            $write("  Sequence: [");
            for (i = 0; i < test_size; i = i + 1) begin
                $write("%0d", test_data[i]);
                if (i < test_size - 1) $write(", ");
            end
            $display("]");

            // Start
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            // Send data
            for (i = 0; i < test_size; i = i + 1) begin
                timeout = 0;
                while (!in_ready && timeout < 1000) begin
                    @(posedge clk);
                    timeout = timeout + 1;
                end

                if (timeout >= 1000) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("TIMEOUT waiting for in_ready");
                    disable test_sequence;
                end

                in_valid <= 1'b1;
                in_data  <= test_data[i];
                in_last  <= (i == test_size - 1);
                @(posedge clk);
                in_valid <= 1'b0;
                in_last  <= 1'b0;
            end

            // Wait for result
            out_ready <= 1'b1;
            timeout = 0;
            while (!out_valid && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for out_valid");
                disable test_sequence;
            end

            // Check result
            if (out_is_palindrome !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: expected=%0d, got=%0d", expected, out_is_palindrome);
            end else begin
                $display("  Result: %s (correct)", expected ? "PALINDROME" : "NOT PALINDROME");
            end

            @(posedge clk);
            out_ready <= 1'b0;
            $display("");
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        in_valid = 0;
        in_data = 0;
        in_last = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Palindrome Checker ===");
        $display("DATA_WIDTH=%0d, MAX_SIZE=%0d\n", DATA_WIDTH, MAX_SIZE);

        // Test 1: Odd-length palindrome
        $display("--- Test 1: Odd-length palindrome ---");
        test_size = 5;
        test_data[0] = 1; test_data[1] = 2; test_data[2] = 3;
        test_data[3] = 2; test_data[4] = 1;
        test_sequence(1);

        // Test 2: Even-length palindrome
        $display("--- Test 2: Even-length palindrome ---");
        test_size = 4;
        test_data[0] = 10; test_data[1] = 20;
        test_data[2] = 20; test_data[3] = 10;
        test_sequence(1);

        // Test 3: Not a palindrome
        $display("--- Test 3: Not a palindrome ---");
        test_size = 5;
        test_data[0] = 1; test_data[1] = 2; test_data[2] = 3;
        test_data[3] = 4; test_data[4] = 5;
        test_sequence(0);

        // Test 4: Single element (always palindrome)
        $display("--- Test 4: Single element ---");
        test_size = 1;
        test_data[0] = 42;
        test_sequence(1);

        // Test 5: Two same elements
        $display("--- Test 5: Two same elements ---");
        test_size = 2;
        test_data[0] = 7; test_data[1] = 7;
        test_sequence(1);

        // Test 6: Two different elements
        $display("--- Test 6: Two different elements ---");
        test_size = 2;
        test_data[0] = 7; test_data[1] = 8;
        test_sequence(0);

        // Test 7: All same values
        $display("--- Test 7: All same values ---");
        test_size = 6;
        test_data[0] = 5; test_data[1] = 5; test_data[2] = 5;
        test_data[3] = 5; test_data[4] = 5; test_data[5] = 5;
        test_sequence(1);

        // Test 8: Almost palindrome (off by one)
        $display("--- Test 8: Almost palindrome ---");
        test_size = 5;
        test_data[0] = 1; test_data[1] = 2; test_data[2] = 3;
        test_data[3] = 2; test_data[4] = 2;  // Last should be 1
        test_sequence(0);

        // Test 9: Longer palindrome
        $display("--- Test 9: Longer palindrome ---");
        test_size = 8;
        test_data[0] = 1; test_data[1] = 2; test_data[2] = 3; test_data[3] = 4;
        test_data[4] = 4; test_data[5] = 3; test_data[6] = 2; test_data[7] = 1;
        test_sequence(1);

        // Test 10: Backpressure test
        $display("--- Test 10: Backpressure test ---");
        test_size = 3;
        test_data[0] = 9; test_data[1] = 5; test_data[2] = 9;

        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;

        // Send data
        begin
            integer i, timeout;
            for (i = 0; i < test_size; i = i + 1) begin
                while (!in_ready) @(posedge clk);
                in_valid <= 1'b1;
                in_data  <= test_data[i];
                in_last  <= (i == test_size - 1);
                @(posedge clk);
                in_valid <= 1'b0;
                in_last  <= 1'b0;
            end
        end

        // Don't accept result immediately
        out_ready <= 1'b0;
        repeat(5) @(posedge clk);

        if (!out_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("out_valid should be high");
        end

        out_ready <= 1'b1;
        @(posedge clk);
        if (out_is_palindrome !== 1) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Expected palindrome=1, got=%0d", out_is_palindrome);
        end else begin
            $display("  [9, 5, 9] -> PALINDROME (correct, backpressure test)");
        end
        @(posedge clk);

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
