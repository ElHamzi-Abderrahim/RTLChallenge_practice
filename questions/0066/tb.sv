`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 16
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_data;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_sum;

    integer ERR_COUNT = 0;

    running_sum #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_valid(in_valid),
        .in_data(in_data),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_sum(out_sum)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Send value and check output
    task automatic send_and_check(
        input [DATA_WIDTH-1:0] value,
        input [DATA_WIDTH-1:0] expected_sum
    );
        integer timeout;
        begin
            // Wait for ready
            timeout = 0;
            while (!in_ready && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for in_ready");
                disable send_and_check;
            end

            // Send input
            in_valid <= 1'b1;
            in_data  <= value;
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
                disable send_and_check;
            end

            // Check result
            if (out_sum !== expected_sum) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: input=%0d, expected_sum=%0d, got=%0d",
                       value, expected_sum, out_sum);
            end else begin
                $display("Input %0d -> Sum %0d (correct)", value, out_sum);
            end

            @(posedge clk);
        end
    endtask

    // Pulse start signal
    task automatic do_start;
        begin
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        in_valid = 0;
        in_data = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Running Sum Calculator (DATA_WIDTH=%0d) ===", DATA_WIDTH);

        // Test 1: Basic sequence
        $display("\n--- Test 1: Basic sequence ---");
        do_start();
        send_and_check(5, 5);
        send_and_check(3, 8);
        send_and_check(7, 15);
        send_and_check(2, 17);

        // Test 2: Reset with start
        $display("\n--- Test 2: Reset and new sequence ---");
        do_start();
        send_and_check(10, 10);
        send_and_check(20, 30);
        send_and_check(30, 60);

        // Test 3: Single value
        $display("\n--- Test 3: Single value ---");
        do_start();
        send_and_check(42, 42);

        // Test 4: Zeros
        $display("\n--- Test 4: With zeros ---");
        do_start();
        send_and_check(5, 5);
        send_and_check(0, 5);
        send_and_check(0, 5);
        send_and_check(10, 15);

        // Test 5: Larger values
        $display("\n--- Test 5: Larger values ---");
        do_start();
        send_and_check(100, 100);
        send_and_check(200, 300);
        send_and_check(500, 800);
        send_and_check(1000, 1800);

        // Test 6: Backpressure test
        $display("\n--- Test 6: Backpressure ---");
        do_start();

        // Send first value
        while (!in_ready) @(posedge clk);
        in_valid <= 1'b1;
        in_data  <= 25;
        @(posedge clk);
        in_valid <= 1'b0;

        // Don't accept output immediately
        out_ready <= 1'b0;
        repeat(5) @(posedge clk);

        if (!out_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("out_valid should be high");
        end

        // Now accept
        out_ready <= 1'b1;
        @(posedge clk);
        if (out_sum !== 25) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Expected sum=25, got=%0d", out_sum);
        end else begin
            $display("Backpressure test: Sum=25 (correct)");
        end

        // Continue with more values
        send_and_check(15, 40);
        send_and_check(10, 50);

        // Test 7: Continuous stream
        $display("\n--- Test 7: Continuous stream ---");
        do_start();
        out_ready <= 1'b1;

        begin
            integer i;
            reg [DATA_WIDTH-1:0] expected;
            expected = 0;

            for (i = 1; i <= 10; i = i + 1) begin
                expected = expected + i;
                send_and_check(i, expected);
            end
        end

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
