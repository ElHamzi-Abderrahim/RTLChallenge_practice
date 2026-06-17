`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 9
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
    wire [DATA_WIDTH-1:0] out_median;

    integer ERR_COUNT = 0;

    median_calc #(
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
        .out_median(out_median)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] test_arr [0:MAX_SIZE-1];
    reg [DATA_WIDTH-1:0] sorted_arr [0:MAX_SIZE-1];
    integer test_size;

    // Sort for reference
    task automatic sort_arr;
        integer i, j;
        reg [DATA_WIDTH-1:0] temp;
        begin
            for (i = 0; i < test_size; i = i + 1) begin
                sorted_arr[i] = test_arr[i];
            end
            for (i = 0; i < test_size - 1; i = i + 1) begin
                for (j = 0; j < test_size - 1 - i; j = j + 1) begin
                    if (sorted_arr[j] > sorted_arr[j+1]) begin
                        temp = sorted_arr[j];
                        sorted_arr[j] = sorted_arr[j+1];
                        sorted_arr[j+1] = temp;
                    end
                end
            end
        end
    endtask

    task automatic run_test;
        integer i, timeout;
        reg [DATA_WIDTH-1:0] exp_median;
        begin
            sort_arr();
            exp_median = sorted_arr[test_size >> 1];

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
            while (!out_valid && timeout < 10000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 10000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT");
                disable run_test;
            end

            if (out_median !== exp_median) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: expected median=%0d, got=%0d", exp_median, out_median);
            end else begin
                $display("  Median: %0d (correct)", out_median);
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

        $display("=== Testing Median Calculator ===");
        $display("DATA_WIDTH=%0d, MAX_SIZE=%0d\n", DATA_WIDTH, MAX_SIZE);

        // Test 1: Odd count
        $display("--- Test 1: 7 elements ---");
        test_size = 7;
        test_arr[0] = 3; test_arr[1] = 1; test_arr[2] = 4;
        test_arr[3] = 1; test_arr[4] = 5; test_arr[5] = 9;
        test_arr[6] = 2;
        run_test();

        // Test 2: 3 elements
        $display("--- Test 2: 3 elements ---");
        test_size = 3;
        test_arr[0] = 5; test_arr[1] = 2; test_arr[2] = 8;
        run_test();

        // Test 3: Single element
        $display("--- Test 3: Single element ---");
        test_size = 1;
        test_arr[0] = 42;
        run_test();

        // Test 4: Already sorted
        $display("--- Test 4: Already sorted ---");
        test_size = 5;
        test_arr[0] = 1; test_arr[1] = 2; test_arr[2] = 3;
        test_arr[3] = 4; test_arr[4] = 5;
        run_test();

        // Test 5: Reverse sorted
        $display("--- Test 5: Reverse sorted ---");
        test_size = 5;
        test_arr[0] = 5; test_arr[1] = 4; test_arr[2] = 3;
        test_arr[3] = 2; test_arr[4] = 1;
        run_test();

        // Test 6: All same
        $display("--- Test 6: All same ---");
        test_size = 5;
        test_arr[0] = 7; test_arr[1] = 7; test_arr[2] = 7;
        test_arr[3] = 7; test_arr[4] = 7;
        run_test();

        // Test 7: Max size
        $display("--- Test 7: Max size ---");
        test_size = MAX_SIZE;
        test_arr[0] = 9; test_arr[1] = 1; test_arr[2] = 8;
        test_arr[3] = 2; test_arr[4] = 7; test_arr[5] = 3;
        test_arr[6] = 6; test_arr[7] = 4; test_arr[8] = 5;
        run_test();

        // Test 8: Duplicates
        $display("--- Test 8: With duplicates ---");
        test_size = 7;
        test_arr[0] = 5; test_arr[1] = 3; test_arr[2] = 5;
        test_arr[3] = 1; test_arr[4] = 5; test_arr[5] = 2;
        test_arr[6] = 5;
        run_test();

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
