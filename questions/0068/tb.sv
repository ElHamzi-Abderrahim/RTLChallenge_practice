`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 32,
    parameter INPUT_WIDTH = 5
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg                    clk;
    reg                    rst_n;
    reg                    in_valid;
    reg  [INPUT_WIDTH-1:0] in_n;
    reg                    out_ready;
    wire                   in_ready;
    wire                   out_valid;
    wire [DATA_WIDTH-1:0]  out_factorial;

    integer ERR_COUNT = 0;

    factorial #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_WIDTH(INPUT_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_n(in_n),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_factorial(out_factorial)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reference factorial function
    function automatic [DATA_WIDTH-1:0] ref_factorial;
        input [INPUT_WIDTH-1:0] n;
        reg [DATA_WIDTH-1:0] result;
        integer i;
        begin
            result = 1;
            for (i = 2; i <= n; i = i + 1) begin
                result = result * i;
            end
            ref_factorial = result;
        end
    endfunction

    // Test a single factorial
    task automatic test_factorial(
        input [INPUT_WIDTH-1:0] n
    );
        reg [DATA_WIDTH-1:0] expected;
        integer timeout;
        begin
            expected = ref_factorial(n);

            // Wait for ready
            timeout = 0;
            while (!in_ready && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for in_ready");
                disable test_factorial;
            end

            // Send input
            in_valid <= 1'b1;
            in_n <= n;
            @(posedge clk);
            in_valid <= 1'b0;

            // Wait for output
            out_ready <= 1'b1;
            timeout = 0;
            while (!out_valid && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for out_valid for n=%0d", n);
                disable test_factorial;
            end

            // Check result
            if (out_factorial !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: %0d! expected=%0d, got=%0d",
                       n, expected, out_factorial);
            end else begin
                $display("%0d! = %0d (correct)", n, out_factorial);
            end

            @(posedge clk);
            out_ready <= 1'b0;
        end
    endtask

    initial begin
        rst_n = 0;
        in_valid = 0;
        in_n = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Factorial Calculator ===");
        $display("DATA_WIDTH=%0d, INPUT_WIDTH=%0d\n", DATA_WIDTH, INPUT_WIDTH);

        // Test 1: Edge cases
        $display("--- Test 1: Edge cases ---");
        test_factorial(0);   // 0! = 1
        test_factorial(1);   // 1! = 1

        // Test 2: Small factorials
        $display("\n--- Test 2: Small factorials ---");
        test_factorial(2);   // 2! = 2
        test_factorial(3);   // 3! = 6
        test_factorial(4);   // 4! = 24
        test_factorial(5);   // 5! = 120

        // Test 3: Medium factorials
        $display("\n--- Test 3: Medium factorials ---");
        test_factorial(6);   // 6! = 720
        test_factorial(7);   // 7! = 5040
        test_factorial(8);   // 8! = 40320
        test_factorial(9);   // 9! = 362880
        test_factorial(10);  // 10! = 3628800

        // Test 4: Larger factorials (within 32-bit)
        $display("\n--- Test 4: Larger factorials ---");
        test_factorial(11);  // 11! = 39916800
        test_factorial(12);  // 12! = 479001600

        // Test 5: Back-to-back requests
        $display("\n--- Test 5: Back-to-back requests ---");
        test_factorial(4);
        test_factorial(5);
        test_factorial(6);

        // Test 6: Backpressure test
        $display("\n--- Test 6: Backpressure ---");
        while (!in_ready) @(posedge clk);
        in_valid <= 1'b1;
        in_n <= 7;
        @(posedge clk);
        in_valid <= 1'b0;

        // Don't accept output immediately
        out_ready <= 1'b0;
        repeat(10) @(posedge clk);

        if (!out_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("out_valid should be high when waiting");
        end

        // Now accept
        out_ready <= 1'b1;
        @(posedge clk);
        if (out_factorial !== 5040) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("7! expected=5040, got=%0d", out_factorial);
        end else begin
            $display("7! = 5040 (correct, backpressure test)");
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
