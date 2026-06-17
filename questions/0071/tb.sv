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
    wire [7:0]            out_idx1;
    wire [7:0]            out_idx2;

    integer ERR_COUNT = 0;

    two_sum #(
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
        .out_idx1(out_idx1),
        .out_idx2(out_idx2)
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
        input integer exp_idx1,
        input integer exp_idx2
    );
        integer i, timeout;
        begin
            // Print test case
            $write("  Array: [");
            for (i = 0; i < test_size; i = i + 1) begin
                $write("%0d", test_arr[i]);
                if (i < test_size - 1) $write(", ");
            end
            $display("], Target: %0d", test_target);

            // Start
            target <= test_target;
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            // Send array
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

            // Wait for result
            out_ready <= 1'b1;
            timeout = 0;
            while (!out_valid && timeout < 10000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 10000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for result");
                disable run_test;
            end

            // Check result
            if (out_found !== exp_found) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: expected found=%0d, got=%0d", exp_found, out_found);
            end else if (exp_found && (out_idx1 !== exp_idx1 || out_idx2 !== exp_idx2)) begin
                // Check if the indices give correct sum
                if (test_arr[out_idx1] + test_arr[out_idx2] == test_target && out_idx1 < out_idx2) begin
                    $display("  Found: idx1=%0d, idx2=%0d (valid alternative)", out_idx1, out_idx2);
                end else begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("MISMATCH: expected idx1=%0d, idx2=%0d, got idx1=%0d, idx2=%0d",
                           exp_idx1, exp_idx2, out_idx1, out_idx2);
                end
            end else begin
                if (exp_found)
                    $display("  Found: idx1=%0d, idx2=%0d (correct)", out_idx1, out_idx2);
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

        $display("=== Testing Two Sum Finder ===");
        $display("DATA_WIDTH=%0d, MAX_SIZE=%0d\n", DATA_WIDTH, MAX_SIZE);

        // Test 1: Basic case
        $display("--- Test 1: Basic case ---");
        test_size = 4; test_target = 9;
        test_arr[0] = 2; test_arr[1] = 7; test_arr[2] = 11; test_arr[3] = 15;
        run_test(1, 0, 1);

        // Test 2: Last pair
        $display("--- Test 2: Last pair ---");
        test_size = 4; test_target = 26;
        test_arr[0] = 2; test_arr[1] = 7; test_arr[2] = 11; test_arr[3] = 15;
        run_test(1, 2, 3);

        // Test 3: Not found
        $display("--- Test 3: Not found ---");
        test_size = 4; test_target = 100;
        test_arr[0] = 2; test_arr[1] = 7; test_arr[2] = 11; test_arr[3] = 15;
        run_test(0, 0, 0);

        // Test 4: Two elements
        $display("--- Test 4: Two elements ---");
        test_size = 2; test_target = 6;
        test_arr[0] = 4; test_arr[1] = 2;
        run_test(1, 0, 1);

        // Test 5: Duplicate values
        $display("--- Test 5: Duplicate values ---");
        test_size = 4; test_target = 6;
        test_arr[0] = 3; test_arr[1] = 3; test_arr[2] = 5; test_arr[3] = 1;
        run_test(1, 0, 1);

        // Test 6: Larger array
        $display("--- Test 6: Larger array ---");
        test_size = 8; test_target = 15;
        test_arr[0] = 1; test_arr[1] = 2; test_arr[2] = 3; test_arr[3] = 4;
        test_arr[4] = 5; test_arr[5] = 6; test_arr[6] = 7; test_arr[7] = 8;
        run_test(1, 6, 7);

        // Test 7: Zero in array
        $display("--- Test 7: Zero in array ---");
        test_size = 4; test_target = 5;
        test_arr[0] = 0; test_arr[1] = 5; test_arr[2] = 3; test_arr[3] = 2;
        run_test(1, 0, 1);

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
