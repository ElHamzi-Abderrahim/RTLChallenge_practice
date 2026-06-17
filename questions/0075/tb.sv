`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MAX_INPUT = 64;
    localparam MAX_OUTPUT = 32;

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_data;
    reg                   in_last;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_value;
    wire [7:0]            out_count;
    wire                  out_last;

    integer ERR_COUNT = 0;

    rle_encoder #(
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
        .out_value(out_value),
        .out_count(out_count),
        .out_last(out_last)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] input_arr [0:MAX_INPUT-1];
    integer input_size;

    reg [DATA_WIDTH-1:0] exp_value [0:MAX_OUTPUT-1];
    reg [7:0] exp_count [0:MAX_OUTPUT-1];
    integer exp_runs;

    reg [DATA_WIDTH-1:0] out_values [0:MAX_OUTPUT-1];
    reg [7:0] out_counts [0:MAX_OUTPUT-1];
    integer actual_runs;

    // Generate expected output
    task automatic gen_expected;
        integer i;
        begin
            exp_runs = 0;
            if (input_size == 0) disable gen_expected;

            exp_value[0] = input_arr[0];
            exp_count[0] = 1;
            exp_runs = 1;

            for (i = 1; i < input_size; i = i + 1) begin
                if (input_arr[i] == exp_value[exp_runs-1] && exp_count[exp_runs-1] < 255) begin
                    exp_count[exp_runs-1] = exp_count[exp_runs-1] + 1;
                end else begin
                    exp_value[exp_runs] = input_arr[i];
                    exp_count[exp_runs] = 1;
                    exp_runs = exp_runs + 1;
                end
            end
        end
    endtask

    task automatic run_test;
        integer i, timeout;
        begin
            gen_expected();

            $write("  Input: [");
            for (i = 0; i < input_size; i = i + 1) begin
                $write("%0d", input_arr[i]);
                if (i < input_size - 1) $write(", ");
            end
            $display("]");

            // Start
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            actual_runs = 0;

            // Send input and receive output concurrently
            fork
                // Sender
                begin
                    for (i = 0; i < input_size; i = i + 1) begin
                        in_valid <= 1'b1;
                        in_data  <= input_arr[i];
                        in_last  <= (i == input_size - 1);
                        @(posedge clk);
                        timeout = 0;
                        while (!in_ready && timeout < 1000) begin
                            @(posedge clk);
                            timeout = timeout + 1;
                        end
                        in_valid <= 1'b0;
                        in_last  <= 1'b0;
                    end
                end

                // Receiver
                begin
                    out_ready <= 1'b1;
                    timeout = 0;
                    while (timeout < 10000) begin
                        @(posedge clk);
                        if (out_valid && out_ready) begin
                            out_values[actual_runs] = out_value;
                            out_counts[actual_runs] = out_count;
                            actual_runs = actual_runs + 1;
                            timeout = 0;
                            if (out_last) timeout = 10000;
                        end else begin
                            timeout = timeout + 1;
                        end
                    end
                    out_ready <= 1'b0;
                end
            join

            // Check results
            $write("  Output: ");
            for (i = 0; i < actual_runs; i = i + 1) begin
                $write("(%0d,%0d)", out_values[i], out_counts[i]);
                if (i < actual_runs - 1) $write(", ");
            end
            $display("");

            if (actual_runs != exp_runs) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Run count mismatch: expected %0d, got %0d", exp_runs, actual_runs);
            end else begin
                for (i = 0; i < exp_runs; i = i + 1) begin
                    if (out_values[i] !== exp_value[i] || out_counts[i] !== exp_count[i]) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("Run %0d mismatch: expected (%0d,%0d), got (%0d,%0d)",
                               i, exp_value[i], exp_count[i], out_values[i], out_counts[i]);
                    end
                end
                if (ERR_COUNT == 0) $display("  (correct)");
            end
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

        $display("=== Testing Run Length Encoder (DATA_WIDTH=%0d) ===\n", DATA_WIDTH);

        // Test 1: Basic runs
        $display("--- Test 1: Basic runs ---");
        input_size = 9;
        input_arr[0] = 1; input_arr[1] = 1; input_arr[2] = 1;
        input_arr[3] = 2; input_arr[4] = 2;
        input_arr[5] = 3; input_arr[6] = 3; input_arr[7] = 3; input_arr[8] = 3;
        run_test();

        // Test 2: Single values
        $display("--- Test 2: All different ---");
        input_size = 5;
        input_arr[0] = 1; input_arr[1] = 2; input_arr[2] = 3;
        input_arr[3] = 4; input_arr[4] = 5;
        run_test();

        // Test 3: All same
        $display("--- Test 3: All same ---");
        input_size = 6;
        input_arr[0] = 7; input_arr[1] = 7; input_arr[2] = 7;
        input_arr[3] = 7; input_arr[4] = 7; input_arr[5] = 7;
        run_test();

        // Test 4: Single element
        $display("--- Test 4: Single element ---");
        input_size = 1;
        input_arr[0] = 42;
        run_test();

        // Test 5: Alternating
        $display("--- Test 5: Alternating ---");
        input_size = 6;
        input_arr[0] = 1; input_arr[1] = 2; input_arr[2] = 1;
        input_arr[3] = 2; input_arr[4] = 1; input_arr[5] = 2;
        run_test();

        // Test 6: Back and forth
        $display("--- Test 6: Returning runs ---");
        input_size = 7;
        input_arr[0] = 5; input_arr[1] = 5;
        input_arr[2] = 3; input_arr[3] = 3; input_arr[4] = 3;
        input_arr[5] = 5; input_arr[6] = 5;
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
