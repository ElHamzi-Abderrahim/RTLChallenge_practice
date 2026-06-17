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
    reg  [DATA_WIDTH-1:0] target;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire                  out_found;
    wire [7:0]            out_index;

    integer ERR_COUNT = 0;

    binary_search #(
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_SIZE(MAX_SIZE)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_valid(in_valid),
        .in_data(in_data),
        .in_last(in_last),
        .target(target),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_found(out_found),
        .out_index(out_index)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] test_arr [0:MAX_SIZE-1];
    integer test_size;
    reg [DATA_WIDTH-1:0] test_target;

    task automatic run_test(
        input reg exp_found,
        input integer exp_index
    );
        integer i, timeout;
        begin
            $write("  Array: [");
            for (i = 0; i < test_size; i = i + 1) begin
                $write("%0d", test_arr[i]);
                if (i < test_size - 1) $write(", ");
            end
            $display("], Target: %0d", test_target);

            target <= test_target;
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

            if (out_found !== exp_found) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("found mismatch: expected %0d, got %0d", exp_found, out_found);
            end else if (exp_found && out_index !== exp_index) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("index mismatch: expected %0d, got %0d", exp_index, out_index);
            end else begin
                if (exp_found)
                    $display("  Found at index %0d (correct)", out_index);
                else
                    $display("  Not found (correct)");
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
        target = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Binary Search ===");
        $display("DATA_WIDTH=%0d, MAX_SIZE=%0d\n", DATA_WIDTH, MAX_SIZE);

        // Test 1: Find in middle
        $display("--- Test 1: Find in middle ---");
        test_size = 8; test_target = 23;
        test_arr[0] = 2; test_arr[1] = 5; test_arr[2] = 8; test_arr[3] = 12;
        test_arr[4] = 16; test_arr[5] = 23; test_arr[6] = 38; test_arr[7] = 56;
        run_test(1, 5);

        // Test 2: Find at start
        $display("--- Test 2: Find at start ---");
        test_size = 5; test_target = 10;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 50;
        run_test(1, 0);

        // Test 3: Find at end
        $display("--- Test 3: Find at end ---");
        test_size = 5; test_target = 50;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 50;
        run_test(1, 4);

        // Test 4: Not found (too small)
        $display("--- Test 4: Not found (too small) ---");
        test_size = 5; test_target = 5;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 50;
        run_test(0, 0);

        // Test 5: Not found (too large)
        $display("--- Test 5: Not found (too large) ---");
        test_size = 5; test_target = 100;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 50;
        run_test(0, 0);

        // Test 6: Not found (in gap)
        $display("--- Test 6: Not found (in gap) ---");
        test_size = 5; test_target = 25;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 50;
        run_test(0, 0);

        // Test 7: Single element found
        $display("--- Test 7: Single element found ---");
        test_size = 1; test_target = 42;
        test_arr[0] = 42;
        run_test(1, 0);

        // Test 8: Single element not found
        $display("--- Test 8: Single element not found ---");
        test_size = 1; test_target = 100;
        test_arr[0] = 42;
        run_test(0, 0);

        // Test 9: Two elements
        $display("--- Test 9: Two elements ---");
        test_size = 2; test_target = 20;
        test_arr[0] = 10; test_arr[1] = 20;
        run_test(1, 1);

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
