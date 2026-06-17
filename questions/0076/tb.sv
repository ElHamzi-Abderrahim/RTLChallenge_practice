`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8
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
    wire signed [DATA_WIDTH:0] out_diff;

    integer ERR_COUNT = 0;

    diff_calc #(
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
        .out_diff(out_diff)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] test_arr [0:31];
    integer test_size;
    reg signed [DATA_WIDTH:0] exp_diff [0:31];
    reg signed [DATA_WIDTH:0] out_diffs [0:31];
    integer num_outputs;

    task automatic gen_expected;
        integer i;
        begin
            for (i = 1; i < test_size; i = i + 1) begin
                exp_diff[i-1] = $signed({1'b0, test_arr[i]}) - $signed({1'b0, test_arr[i-1]});
            end
        end
    endtask

    task automatic run_test;
        integer i, timeout;
        begin
            gen_expected();

            $write("  Input: [");
            for (i = 0; i < test_size; i = i + 1) begin
                $write("%0d", test_arr[i]);
                if (i < test_size - 1) $write(", ");
            end
            $display("]");

            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            num_outputs = 0;
            out_ready <= 1'b1;

            for (i = 0; i < test_size; i = i + 1) begin
                timeout = 0;
                while (!in_ready && timeout < 1000) begin
                    @(posedge clk);
                    if (out_valid && out_ready) begin
                        out_diffs[num_outputs] = out_diff;
                        num_outputs = num_outputs + 1;
                    end
                    timeout = timeout + 1;
                end

                in_valid <= 1'b1;
                in_data  <= test_arr[i];
                @(posedge clk);
                in_valid <= 1'b0;

                // Collect any output
                if (out_valid && out_ready) begin
                    out_diffs[num_outputs] = out_diff;
                    num_outputs = num_outputs + 1;
                end
            end

            // Collect remaining outputs
            timeout = 0;
            while (timeout < 100) begin
                @(posedge clk);
                if (out_valid && out_ready) begin
                    out_diffs[num_outputs] = out_diff;
                    num_outputs = num_outputs + 1;
                    timeout = 0;
                end else begin
                    timeout = timeout + 1;
                end
            end
            out_ready <= 1'b0;

            // Check
            $write("  Output: [");
            for (i = 0; i < num_outputs; i = i + 1) begin
                $write("%0d", out_diffs[i]);
                if (i < num_outputs - 1) $write(", ");
            end
            $display("]");

            if (num_outputs != test_size - 1) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Output count mismatch: expected %0d, got %0d", test_size - 1, num_outputs);
            end else begin
                for (i = 0; i < num_outputs; i = i + 1) begin
                    if (out_diffs[i] !== exp_diff[i]) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("Diff[%0d] mismatch: expected %0d, got %0d", i, exp_diff[i], out_diffs[i]);
                    end
                end
                $display("  (correct)");
            end
            $display("");
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

        $display("=== Testing Difference Calculator (DATA_WIDTH=%0d) ===\n", DATA_WIDTH);

        // Test 1: Basic
        $display("--- Test 1: Basic ---");
        test_size = 5;
        test_arr[0] = 5; test_arr[1] = 8; test_arr[2] = 3;
        test_arr[3] = 10; test_arr[4] = 7;
        run_test();

        // Test 2: Increasing
        $display("--- Test 2: Increasing ---");
        test_size = 5;
        test_arr[0] = 10; test_arr[1] = 20; test_arr[2] = 30;
        test_arr[3] = 40; test_arr[4] = 50;
        run_test();

        // Test 3: Decreasing
        $display("--- Test 3: Decreasing ---");
        test_size = 5;
        test_arr[0] = 50; test_arr[1] = 40; test_arr[2] = 30;
        test_arr[3] = 20; test_arr[4] = 10;
        run_test();

        // Test 4: Same values
        $display("--- Test 4: Same values ---");
        test_size = 4;
        test_arr[0] = 25; test_arr[1] = 25; test_arr[2] = 25; test_arr[3] = 25;
        run_test();

        // Test 5: Two values
        $display("--- Test 5: Two values ---");
        test_size = 2;
        test_arr[0] = 100; test_arr[1] = 30;
        run_test();

        // Test 6: Alternating
        $display("--- Test 6: Alternating ---");
        test_size = 6;
        test_arr[0] = 0; test_arr[1] = 100; test_arr[2] = 0;
        test_arr[3] = 100; test_arr[4] = 0; test_arr[5] = 100;
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
