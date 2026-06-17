`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 16
);

    localparam TB_SIM_TIMEOUT = 10_000_000;

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   out_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_data;
    wire [7:0]            out_index;

    integer ERR_COUNT = 0;

    // Reference Fibonacci
    reg [DATA_WIDTH-1:0] ref_fib [0:50];

    integer i;
    initial begin
        ref_fib[0] = 0;
        ref_fib[1] = 1;
        for (i = 2; i <= 50; i = i + 1) begin
            ref_fib[i] = ref_fib[i-1] + ref_fib[i-2];
        end
    end

    fib_gen #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .out_ready(out_ready),
        .out_valid(out_valid),
        .out_data(out_data),
        .out_index(out_index)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Check handshake and data
    integer expected_idx;
    reg [DATA_WIDTH-1:0] expected_data;

    task check_output;
        begin
            if (out_index > 50) begin
                // Skip check for overflow region
            end else begin
                expected_data = ref_fib[out_index];
                if (out_data !== expected_data) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("MISMATCH: F(%0d) expected=%0d, got=%0d",
                           out_index, expected_data, out_data);
                end else begin
                    $display("F(%0d) = %0d (correct)", out_index, out_data);
                end
            end
        end
    endtask

    task receive_n_values(input integer n);
        integer count;
        integer timeout;
        begin
            count = 0;
            timeout = 0;
            while (count < n && timeout < 10000) begin
                @(posedge clk);
                if (out_valid && out_ready) begin
                    check_output();
                    count = count + 1;
                    timeout = 0;
                end else begin
                    timeout = timeout + 1;
                end
            end
            if (timeout >= 10000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for out_valid");
            end
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Fibonacci Generator (DATA_WIDTH=%0d) ===", DATA_WIDTH);

        // Test 1: Generate first 10 Fibonacci numbers
        $display("\n--- Test 1: First 10 values ---");
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;
        out_ready <= 1'b1;

        receive_n_values(10);

        // Test 2: Test backpressure (ready goes low)
        $display("\n--- Test 2: Backpressure ---");
        out_ready <= 1'b0;
        repeat(5) @(posedge clk);

        // Data should be stable
        if (!out_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Valid dropped during backpressure");
        end

        out_ready <= 1'b1;
        receive_n_values(5);

        // Test 3: Restart sequence
        $display("\n--- Test 3: Restart ---");
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;

        receive_n_values(5);

        // Test 4: Intermittent ready
        $display("\n--- Test 4: Intermittent Ready ---");
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;

        repeat(10) begin
            out_ready <= 1'b1;
            @(posedge clk);
            if (out_valid && out_ready) check_output();
            out_ready <= 1'b0;
            repeat(2) @(posedge clk);
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
