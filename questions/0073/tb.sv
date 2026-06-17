`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MAX_SIZE = 32;

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_data;
    reg                   in_last;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_min;
    wire [DATA_WIDTH-1:0] out_max;

    integer ERR_COUNT = 0;

    min_max #(
        .DATA_WIDTH(DATA_WIDTH)
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
        .out_min(out_min),
        .out_max(out_max)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] test_arr [0:MAX_SIZE-1];
    integer test_size;

    task automatic run_test(
        input [DATA_WIDTH-1:0] exp_min,
        input [DATA_WIDTH-1:0] exp_max
    );
        integer i, timeout;
        begin
            $write("  Array: [");
            for (i = 0; i < test_size; i = i + 1) begin
                $write("%0d", test_arr[i]);
                if (i < test_size - 1) $write(", ");
            end
            $display("]");

            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (i = 0; i < test_size; i = i + 1) begin
                timeout = 0;
                while (!in_ready && timeout < 1000) begin
                    @(posedge clk);
                    timeout = timeout + 1;
                end
                in_valid <= 1'b1;
                in_data  <= test_arr[i];
                in_last  <= (i == test_size - 1);
                @(posedge clk);
                in_valid <= 1'b0;
                in_last  <= 1'b0;
            end

            out_ready <= 1'b1;
            timeout = 0;
            while (!out_valid && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT");
                disable run_test;
            end

            if (out_min !== exp_min || out_max !== exp_max) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: expected min=%0d, max=%0d, got min=%0d, max=%0d",
                       exp_min, exp_max, out_min, out_max);
            end else begin
                $display("  Result: min=%0d, max=%0d (correct)", out_min, out_max);
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

        $display("=== Testing Min-Max Finder (DATA_WIDTH=%0d) ===\n", DATA_WIDTH);

        // Test 1: Basic case
        $display("--- Test 1: Basic case ---");
        test_size = 6;
        test_arr[0] = 5; test_arr[1] = 2; test_arr[2] = 8;
        test_arr[3] = 1; test_arr[4] = 9; test_arr[5] = 3;
        run_test(1, 9);

        // Test 2: Single element
        $display("--- Test 2: Single element ---");
        test_size = 1;
        test_arr[0] = 42;
        run_test(42, 42);

        // Test 3: Two elements
        $display("--- Test 3: Two elements ---");
        test_size = 2;
        test_arr[0] = 10; test_arr[1] = 20;
        run_test(10, 20);

        // Test 4: Sorted ascending
        $display("--- Test 4: Sorted ascending ---");
        test_size = 5;
        test_arr[0] = 1; test_arr[1] = 2; test_arr[2] = 3;
        test_arr[3] = 4; test_arr[4] = 5;
        run_test(1, 5);

        // Test 5: Sorted descending
        $display("--- Test 5: Sorted descending ---");
        test_size = 5;
        test_arr[0] = 5; test_arr[1] = 4; test_arr[2] = 3;
        test_arr[3] = 2; test_arr[4] = 1;
        run_test(1, 5);

        // Test 6: All same
        $display("--- Test 6: All same ---");
        test_size = 4;
        test_arr[0] = 7; test_arr[1] = 7; test_arr[2] = 7; test_arr[3] = 7;
        run_test(7, 7);

        // Test 7: Min at end
        $display("--- Test 7: Min at end ---");
        test_size = 5;
        test_arr[0] = 50; test_arr[1] = 40; test_arr[2] = 30;
        test_arr[3] = 20; test_arr[4] = 10;
        run_test(10, 50);

        // Test 8: Max at end
        $display("--- Test 8: Max at end ---");
        test_size = 5;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 100;
        run_test(10, 100);

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
