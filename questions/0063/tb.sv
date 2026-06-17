`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 16
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg                   clk;
    reg                   rst_n;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_num;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire                  out_is_prime;

    integer ERR_COUNT = 0;

    prime_check #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_num(in_num),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_is_prime(out_is_prime)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reference prime check function
    function automatic is_prime_ref;
        input [DATA_WIDTH-1:0] n;
        integer d;  // wide enough that d*d does not overflow/truncate
        begin
            if (n <= 1) begin
                is_prime_ref = 0;
            end else if (n <= 3) begin
                is_prime_ref = 1;
            end else if (n[0] == 0) begin
                is_prime_ref = 0;
            end else begin
                is_prime_ref = 1;
                d = 3;
                while (d * d <= n) begin
                    if (n % d == 0) begin
                        is_prime_ref = 0;
                        d = n;  // Exit loop
                    end else begin
                        d = d + 2;
                    end
                end
            end
        end
    endfunction

    // Test a single number
    task automatic test_prime(
        input [DATA_WIDTH-1:0] num
    );
        reg expected;
        integer timeout;
        begin
            expected = is_prime_ref(num);

            // Wait for ready
            timeout = 0;
            while (!in_ready && timeout < 10000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 10000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for in_ready");
                disable test_prime;
            end

            // Send input
            in_valid <= 1'b1;
            in_num <= num;
            @(posedge clk);
            in_valid <= 1'b0;

            // Wait for output
            out_ready <= 1'b1;
            timeout = 0;
            while (!out_valid && timeout < 10000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 10000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for out_valid for num=%0d", num);
                disable test_prime;
            end

            // Check result
            if (out_is_prime !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: is_prime(%0d) expected=%0d, got=%0d",
                       num, expected, out_is_prime);
            end else begin
                $display("is_prime(%0d) = %0d (correct)", num, out_is_prime);
            end

            @(posedge clk);
            out_ready <= 1'b0;
        end
    endtask

    initial begin
        rst_n = 0;
        in_valid = 0;
        in_num = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Prime Number Checker (DATA_WIDTH=%0d) ===", DATA_WIDTH);

        // Test 1: Edge cases
        $display("\n--- Test 1: Edge cases ---");
        test_prime(0);   // Not prime
        test_prime(1);   // Not prime
        test_prime(2);   // Prime
        test_prime(3);   // Prime

        // Test 2: Small primes
        $display("\n--- Test 2: Small primes ---");
        test_prime(5);
        test_prime(7);
        test_prime(11);
        test_prime(13);
        test_prime(17);
        test_prime(19);
        test_prime(23);

        // Test 3: Small non-primes
        $display("\n--- Test 3: Small non-primes ---");
        test_prime(4);
        test_prime(6);
        test_prime(8);
        test_prime(9);
        test_prime(10);
        test_prime(12);
        test_prime(15);

        // Test 4: Larger primes
        $display("\n--- Test 4: Larger primes ---");
        test_prime(97);
        test_prime(101);
        test_prime(127);
        test_prime(131);

        // Test 5: Larger non-primes
        $display("\n--- Test 5: Larger non-primes ---");
        test_prime(100);
        test_prime(121);  // 11*11
        test_prime(143);  // 11*13
        test_prime(169);  // 13*13

        // Test 6: Powers of 2 (not prime except 2)
        $display("\n--- Test 6: Powers of 2 ---");
        test_prime(4);
        test_prime(8);
        test_prime(16);
        test_prime(32);
        test_prime(64);

        // Test 7: Backpressure test
        $display("\n--- Test 7: Backpressure ---");
        while (!in_ready) @(posedge clk);
        in_valid <= 1'b1;
        in_num <= 29;  // Prime
        @(posedge clk);
        in_valid <= 1'b0;

        out_ready <= 1'b0;
        repeat(10) @(posedge clk);

        if (!out_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("out_valid should be high when waiting");
        end

        out_ready <= 1'b1;
        @(posedge clk);
        if (out_is_prime !== 1) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("is_prime(29) expected=1, got=%0d", out_is_prime);
        end else begin
            $display("is_prime(29) = 1 (correct, backpressure test)");
        end
        @(posedge clk);
        out_ready <= 1'b0;

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
