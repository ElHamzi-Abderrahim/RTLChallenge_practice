`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MAX_SIZE = 32;

    reg                   clk;
    reg                   rst_n;
    reg                   in_a_valid;
    reg  [DATA_WIDTH-1:0] in_a_data;
    reg                   in_a_last;
    reg                   in_b_valid;
    reg  [DATA_WIDTH-1:0] in_b_data;
    reg                   in_b_last;
    reg                   out_ready;
    wire                  in_a_ready;
    wire                  in_b_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_data;
    wire                  out_last;

    integer ERR_COUNT = 0;

    merge_sorted #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .in_a_valid(in_a_valid),
        .in_a_data(in_a_data),
        .in_a_last(in_a_last),
        .in_b_valid(in_b_valid),
        .in_b_data(in_b_data),
        .in_b_last(in_b_last),
        .out_ready(out_ready),
        .in_a_ready(in_a_ready),
        .in_b_ready(in_b_ready),
        .out_valid(out_valid),
        .out_data(out_data),
        .out_last(out_last)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test data
    reg [DATA_WIDTH-1:0] stream_a [0:MAX_SIZE-1];
    reg [DATA_WIDTH-1:0] stream_b [0:MAX_SIZE-1];
    reg [DATA_WIDTH-1:0] expected [0:MAX_SIZE*2-1];
    reg [DATA_WIDTH-1:0] output_arr [0:MAX_SIZE*2-1];
    integer size_a, size_b, size_out;

    // Generate expected merged output
    task automatic gen_expected;
        integer i, j, k;
        begin
            i = 0; j = 0; k = 0;
            while (i < size_a && j < size_b) begin
                if (stream_a[i] <= stream_b[j]) begin
                    expected[k] = stream_a[i];
                    i = i + 1;
                end else begin
                    expected[k] = stream_b[j];
                    j = j + 1;
                end
                k = k + 1;
            end
            while (i < size_a) begin
                expected[k] = stream_a[i];
                i = i + 1;
                k = k + 1;
            end
            while (j < size_b) begin
                expected[k] = stream_b[j];
                j = j + 1;
                k = k + 1;
            end
            size_out = k;
        end
    endtask

    // Print array
    task automatic print_array(input string name, input integer size, input integer which);
        integer i;
        begin
            $write("  %s: [", name);
            for (i = 0; i < size; i = i + 1) begin
                if (which == 0)
                    $write("%0d", stream_a[i]);
                else if (which == 1)
                    $write("%0d", stream_b[i]);
                else if (which == 2)
                    $write("%0d", expected[i]);
                else
                    $write("%0d", output_arr[i]);
                if (i < size - 1) $write(", ");
            end
            $display("]");
        end
    endtask

    // Sender tasks (run in parallel using fork)
    integer a_idx, b_idx;
    reg a_sending_done, b_sending_done;

    task automatic send_stream_a;
        begin
            a_idx = 0;
            a_sending_done = 0;
            while (a_idx < size_a) begin
                in_a_valid <= 1'b1;
                in_a_data  <= stream_a[a_idx];
                in_a_last  <= (a_idx == size_a - 1);
                @(posedge clk);
                if (in_a_ready) a_idx = a_idx + 1;
            end
            in_a_valid <= 1'b0;
            in_a_last  <= 1'b0;
            a_sending_done = 1;
        end
    endtask

    task automatic send_stream_b;
        begin
            b_idx = 0;
            b_sending_done = 0;
            while (b_idx < size_b) begin
                in_b_valid <= 1'b1;
                in_b_data  <= stream_b[b_idx];
                in_b_last  <= (b_idx == size_b - 1);
                @(posedge clk);
                if (in_b_ready) b_idx = b_idx + 1;
            end
            in_b_valid <= 1'b0;
            in_b_last  <= 1'b0;
            b_sending_done = 1;
        end
    endtask

    // Receive merged output
    task automatic receive_output;
        integer i;
        integer timeout;
        reg done;
        begin
            out_ready <= 1'b1;
            i = 0;
            timeout = 0;
            done = 0;

            while (timeout < 10000 && !done) begin
                @(posedge clk);
                if (out_valid && out_ready) begin
                    output_arr[i] = out_data;
                    timeout = 0;

                    if (out_last) begin
                        i = i + 1;
                        done = 1;
                    end else begin
                        i = i + 1;
                    end
                end else begin
                    timeout = timeout + 1;
                end
            end

            if (timeout >= 10000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT receiving output");
            end

            if (i != size_out) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Wrong output count: expected %0d, got %0d", size_out, i);
            end

            out_ready <= 1'b0;
        end
    endtask

    // Compare results
    task automatic compare_results;
        integer i;
        reg mismatch;
        begin
            mismatch = 0;
            for (i = 0; i < size_out; i = i + 1) begin
                if (output_arr[i] !== expected[i]) begin
                    mismatch = 1;
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("MISMATCH at index %0d: expected=%0d, got=%0d",
                           i, expected[i], output_arr[i]);
                end
            end
            if (!mismatch) begin
                $display("  Merge correct!");
            end
        end
    endtask

    // Run a test
    task automatic run_test;
        begin
            gen_expected();
            print_array("Stream A", size_a, 0);
            print_array("Stream B", size_b, 1);
            print_array("Expected", size_out, 2);

            fork
                send_stream_a();
                send_stream_b();
                receive_output();
            join

            print_array("Output", size_out, 3);
            compare_results();
            $display("");

            // Reset for next test
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 0;
        in_a_valid = 0;
        in_a_data = 0;
        in_a_last = 0;
        in_b_valid = 0;
        in_b_data = 0;
        in_b_last = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Merge Sorted Streams (DATA_WIDTH=%0d) ===\n", DATA_WIDTH);

        // Test 1: Basic merge
        $display("--- Test 1: Basic merge ---");
        size_a = 4; size_b = 3;
        stream_a[0] = 1; stream_a[1] = 3; stream_a[2] = 5; stream_a[3] = 7;
        stream_b[0] = 2; stream_b[1] = 4; stream_b[2] = 6;
        run_test();

        // Reset between tests
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Test 2: One stream longer
        $display("--- Test 2: One stream longer ---");
        size_a = 2; size_b = 5;
        stream_a[0] = 3; stream_a[1] = 6;
        stream_b[0] = 1; stream_b[1] = 2; stream_b[2] = 4; stream_b[3] = 5; stream_b[4] = 7;
        run_test();

        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Test 3: Interleaved values
        $display("--- Test 3: Interleaved ---");
        size_a = 4; size_b = 4;
        stream_a[0] = 1; stream_a[1] = 3; stream_a[2] = 5; stream_a[3] = 7;
        stream_b[0] = 2; stream_b[1] = 4; stream_b[2] = 6; stream_b[3] = 8;
        run_test();

        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Test 4: All from A first
        $display("--- Test 4: A values smaller ---");
        size_a = 3; size_b = 3;
        stream_a[0] = 1; stream_a[1] = 2; stream_a[2] = 3;
        stream_b[0] = 10; stream_b[1] = 20; stream_b[2] = 30;
        run_test();

        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Test 5: Single elements
        $display("--- Test 5: Single elements ---");
        size_a = 1; size_b = 1;
        stream_a[0] = 5;
        stream_b[0] = 3;
        run_test();

        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        // Test 6: Duplicates
        $display("--- Test 6: With duplicates ---");
        size_a = 3; size_b = 3;
        stream_a[0] = 1; stream_a[1] = 3; stream_a[2] = 5;
        stream_b[0] = 1; stream_b[1] = 3; stream_b[2] = 5;
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
