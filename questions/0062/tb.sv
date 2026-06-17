`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 16
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg                   clk;
    reg                   rst_n;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_a;
    reg  [DATA_WIDTH-1:0] in_b;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_gcd;

    integer ERR_COUNT = 0;

    gcd_calc #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_a(in_a),
        .in_b(in_b),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_gcd(out_gcd)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reference GCD function
    function automatic [DATA_WIDTH-1:0] ref_gcd;
        input [DATA_WIDTH-1:0] a;
        input [DATA_WIDTH-1:0] b;
        reg [DATA_WIDTH-1:0] temp;
        begin
            while (b != 0) begin
                temp = b;
                b = a % b;
                a = temp;
            end
            ref_gcd = a;
        end
    endfunction

    // Send input and receive output
    task automatic test_gcd(
        input [DATA_WIDTH-1:0] a,
        input [DATA_WIDTH-1:0] b
    );
        reg [DATA_WIDTH-1:0] expected;
        integer timeout;
        begin
            expected = ref_gcd(a, b);

            // Wait for ready
            timeout = 0;
            while (!in_ready && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for in_ready");
                disable test_gcd;
            end

            // Send input
            in_valid <= 1'b1;
            in_a <= a;
            in_b <= b;
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
                $error("TIMEOUT waiting for out_valid");
                disable test_gcd;
            end

            // Check result
            if (out_gcd !== expected) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: GCD(%0d, %0d) expected=%0d, got=%0d",
                       a, b, expected, out_gcd);
            end else begin
                $display("GCD(%0d, %0d) = %0d (correct)", a, b, out_gcd);
            end

            @(posedge clk);
            out_ready <= 1'b0;
        end
    endtask

    initial begin
        rst_n = 0;
        in_valid = 0;
        in_a = 0;
        in_b = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing GCD Calculator (DATA_WIDTH=%0d) ===", DATA_WIDTH);

        // Test 1: Basic cases
        $display("\n--- Test 1: Basic cases ---");
        test_gcd(48, 18);      // GCD = 6
        test_gcd(252, 105);    // GCD = 21
        test_gcd(100, 25);     // GCD = 25
        test_gcd(17, 13);      // Coprime, GCD = 1

        // Test 2: Edge cases with zeros
        $display("\n--- Test 2: Edge cases ---");
        test_gcd(0, 0);        // GCD = 0
        test_gcd(0, 42);       // GCD = 42
        test_gcd(42, 0);       // GCD = 42
        test_gcd(1, 1);        // GCD = 1

        // Test 3: Same numbers
        $display("\n--- Test 3: Same numbers ---");
        test_gcd(100, 100);    // GCD = 100
        test_gcd(255, 255);    // GCD = 255

        // Test 4: One divides the other
        $display("\n--- Test 4: Divisibility ---");
        test_gcd(100, 10);     // GCD = 10
        test_gcd(12, 144);     // GCD = 12
        test_gcd(7, 49);       // GCD = 7

        // Test 5: Larger numbers
        $display("\n--- Test 5: Larger numbers ---");
        test_gcd(1071, 462);   // GCD = 21
        test_gcd(3456, 1234);  // GCD = 2

        // Test 6: Backpressure test
        $display("\n--- Test 6: Backpressure ---");
        // Send input
        while (!in_ready) @(posedge clk);
        in_valid <= 1'b1;
        in_a <= 120;
        in_b <= 45;
        @(posedge clk);
        in_valid <= 1'b0;

        // Don't assert ready immediately
        out_ready <= 1'b0;
        repeat(10) @(posedge clk);

        // Now check valid is still asserted
        if (!out_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("out_valid should be high when waiting");
        end

        // Accept result
        out_ready <= 1'b1;
        @(posedge clk);
        if (out_gcd !== 15) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("GCD(120, 45) expected=15, got=%0d", out_gcd);
        end else begin
            $display("GCD(120, 45) = 15 (correct, backpressure test)");
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
