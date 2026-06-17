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
    wire                  out_is_peak;
    wire [DATA_WIDTH-1:0] out_value;
    wire [7:0]            out_index;

    integer ERR_COUNT = 0;

    peak_detect #(
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
        .out_is_peak(out_is_peak),
        .out_value(out_value),
        .out_index(out_index)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] test_arr [0:MAX_SIZE-1];
    integer test_size;

    reg [DATA_WIDTH-1:0] out_values [0:MAX_SIZE-1];
    reg [7:0] out_indices [0:MAX_SIZE-1];
    reg out_peaks [0:MAX_SIZE-1];
    integer num_outputs;

    task automatic run_test;
        integer i, timeout;
        integer exp_outputs;
        begin
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

            fork
                // Sender
                begin
                    for (i = 0; i < test_size; i = i + 1) begin
                        in_valid <= 1'b1;
                        in_data  <= test_arr[i];
                        in_last  <= (i == test_size - 1);
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
                    timeout = 0;
                    while (timeout < 1000) begin
                        @(posedge clk);
                        if (out_valid && out_ready) begin
                            out_values[num_outputs] = out_value;
                            out_indices[num_outputs] = out_index;
                            out_peaks[num_outputs] = out_is_peak;
                            num_outputs = num_outputs + 1;
                            timeout = 0;
                        end else begin
                            timeout = timeout + 1;
                        end
                    end
                end
            join

            out_ready <= 1'b0;

            // Display results
            $write("  Peaks: ");
            begin
                integer found_peaks;
                found_peaks = 0;
                for (i = 0; i < num_outputs; i = i + 1) begin
                    if (out_peaks[i]) begin
                        $write("%0d@%0d ", out_values[i], out_indices[i]);
                        found_peaks = found_peaks + 1;
                    end
                end
                if (found_peaks == 0) $write("(none)");
            end
            $display("");

            // Verify peaks
            exp_outputs = (test_size >= 3) ? test_size - 2 : 0;
            if (num_outputs != exp_outputs) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Output count mismatch: expected %0d, got %0d", exp_outputs, num_outputs);
            end else begin
                for (i = 0; i < num_outputs; i = i + 1) begin
                    // Check index
                    if (out_indices[i] != i + 1) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("Index mismatch at output %0d", i);
                    end
                    // Check value
                    if (out_values[i] != test_arr[i + 1]) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("Value mismatch at output %0d", i);
                    end
                    // Check peak detection
                    begin
                        reg is_peak;
                        is_peak = (test_arr[i + 1] > test_arr[i]) && (test_arr[i + 1] > test_arr[i + 2]);
                        if (out_peaks[i] != is_peak) begin
                            ERR_COUNT = ERR_COUNT + 1;
                            $error("Peak detection error at index %0d", i + 1);
                        end
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
        in_last = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Peak Detector (DATA_WIDTH=%0d) ===\n", DATA_WIDTH);

        // Test 1: Multiple peaks
        $display("--- Test 1: Multiple peaks ---");
        test_size = 7;
        test_arr[0] = 1; test_arr[1] = 5; test_arr[2] = 2;
        test_arr[3] = 8; test_arr[4] = 3; test_arr[5] = 7;
        test_arr[6] = 4;
        run_test();

        // Test 2: No peaks (ascending)
        $display("--- Test 2: Ascending (no peaks) ---");
        test_size = 5;
        test_arr[0] = 1; test_arr[1] = 2; test_arr[2] = 3;
        test_arr[3] = 4; test_arr[4] = 5;
        run_test();

        // Test 3: No peaks (descending)
        $display("--- Test 3: Descending (no peaks) ---");
        test_size = 5;
        test_arr[0] = 5; test_arr[1] = 4; test_arr[2] = 3;
        test_arr[3] = 2; test_arr[4] = 1;
        run_test();

        // Test 4: Single peak in middle
        $display("--- Test 4: Single peak ---");
        test_size = 5;
        test_arr[0] = 1; test_arr[1] = 2; test_arr[2] = 5;
        test_arr[3] = 3; test_arr[4] = 1;
        run_test();

        // Test 5: Minimum size (3 elements)
        $display("--- Test 5: Three elements ---");
        test_size = 3;
        test_arr[0] = 1; test_arr[1] = 5; test_arr[2] = 2;
        run_test();

        // Test 6: Plateau (equal values - not peaks)
        $display("--- Test 6: Plateau ---");
        test_size = 5;
        test_arr[0] = 1; test_arr[1] = 5; test_arr[2] = 5;
        test_arr[3] = 5; test_arr[4] = 1;
        run_test();

        // Test 7: Alternating
        $display("--- Test 7: Alternating ---");
        test_size = 7;
        test_arr[0] = 1; test_arr[1] = 9; test_arr[2] = 1;
        test_arr[3] = 9; test_arr[4] = 1; test_arr[5] = 9;
        test_arr[6] = 1;
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
