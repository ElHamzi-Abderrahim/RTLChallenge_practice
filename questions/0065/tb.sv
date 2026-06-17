`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
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
    wire [DATA_WIDTH-1:0] out_data;
    wire                  out_last;

    integer ERR_COUNT = 0;

    seq_reverse #(
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
        .out_data(out_data),
        .out_last(out_last)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Storage for test
    reg [DATA_WIDTH-1:0] input_arr [0:MAX_SIZE-1];
    reg [DATA_WIDTH-1:0] expected_arr [0:MAX_SIZE-1];
    reg [DATA_WIDTH-1:0] output_arr [0:MAX_SIZE-1];
    integer input_size;

    // Generate expected (reversed) array
    task automatic gen_expected;
        integer i;
        begin
            for (i = 0; i < input_size; i = i + 1) begin
                expected_arr[i] = input_arr[input_size - 1 - i];
            end
        end
    endtask

    // Send array to DUT
    task automatic send_array;
        integer i;
        integer timeout;
        begin
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            for (i = 0; i < input_size; i = i + 1) begin
                // Wait for ready
                timeout = 0;
                while (in_ready !== 1'b1 && timeout < 1000) begin
                    @(posedge clk);
                    timeout = timeout + 1;
                end

                if (timeout >= 1000) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("TIMEOUT waiting for in_ready");
                    disable send_array;
                end

                in_valid <= 1'b1;
                in_data  <= input_arr[i];
                in_last  <= (i == input_size - 1);
                @(posedge clk);
                in_valid <= 1'b0;
                in_last  <= 1'b0;
            end
        end
    endtask

    // Receive reversed array
    task automatic receive_array;
        integer i;
        integer timeout;
        begin
            out_ready <= 1'b1;
            i = 0;

            while (i < input_size) begin
                timeout = 0;
                while (out_valid !== 1'b1 && timeout < 1000) begin
                    @(posedge clk);
                    timeout = timeout + 1;
                end

                if (timeout >= 1000) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("TIMEOUT waiting for out_valid");
                    disable receive_array;
                end

                if (out_valid && out_ready) begin
                    output_arr[i] = out_data;

                    // Check out_last
                    if (i == input_size - 1 && !out_last) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("out_last not asserted on last element");
                    end
                    if (i < input_size - 1 && out_last) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("out_last asserted too early at index %0d", i);
                    end

                    i = i + 1;
                end
                @(posedge clk);
            end

            out_ready <= 1'b0;
        end
    endtask

    // Compare arrays
    task automatic compare_arrays;
        integer i;
        reg mismatch;
        begin
            mismatch = 0;
            for (i = 0; i < input_size; i = i + 1) begin
                if (output_arr[i] !== expected_arr[i]) begin
                    mismatch = 1;
                    ERR_COUNT = ERR_COUNT + 1;
                    $error("MISMATCH at index %0d: expected=%0d, got=%0d",
                           i, expected_arr[i], output_arr[i]);
                end
            end
            if (!mismatch) begin
                $display("Reverse correct!");
            end
        end
    endtask

    // Print array
    task automatic print_array(input string name, input integer size);
        integer i;
        begin
            $write("%s: [", name);
            for (i = 0; i < size; i = i + 1) begin
                if (name == "Input")
                    $write("%0d", input_arr[i]);
                else if (name == "Expected")
                    $write("%0d", expected_arr[i]);
                else
                    $write("%0d", output_arr[i]);
                if (i < size - 1) $write(", ");
            end
            $display("]");
        end
    endtask

    // Run one test
    task automatic run_test;
        begin
            gen_expected();
            print_array("Input", input_size);
            print_array("Expected", input_size);

            send_array();
            receive_array();

            print_array("Output", input_size);
            compare_arrays();
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

        $display("=== Testing Sequence Reverser ===");
        $display("DATA_WIDTH=%0d, MAX_SIZE=%0d\n", DATA_WIDTH, MAX_SIZE);

        // Test 1: Basic sequence
        $display("--- Test 1: Basic sequence ---");
        input_size = 5;
        input_arr[0] = 1; input_arr[1] = 2; input_arr[2] = 3;
        input_arr[3] = 4; input_arr[4] = 5;
        run_test();

        // Test 2: Single element
        $display("--- Test 2: Single element ---");
        input_size = 1;
        input_arr[0] = 42;
        run_test();

        // Test 3: Two elements
        $display("--- Test 3: Two elements ---");
        input_size = 2;
        input_arr[0] = 10; input_arr[1] = 20;
        run_test();

        // Test 4: Palindrome (same forward and backward)
        $display("--- Test 4: Palindrome ---");
        input_size = 5;
        input_arr[0] = 1; input_arr[1] = 2; input_arr[2] = 3;
        input_arr[3] = 2; input_arr[4] = 1;
        run_test();

        // Test 5: Max size
        $display("--- Test 5: Maximum size ---");
        input_size = MAX_SIZE;
        input_arr[0] = 8; input_arr[1] = 7; input_arr[2] = 6; input_arr[3] = 5;
        input_arr[4] = 4; input_arr[5] = 3; input_arr[6] = 2; input_arr[7] = 1;
        run_test();

        // Test 6: Various values
        $display("--- Test 6: Various values ---");
        input_size = 4;
        input_arr[0] = 100; input_arr[1] = 50; input_arr[2] = 200; input_arr[3] = 25;
        run_test();

        // Test 7: Backpressure during output
        $display("--- Test 7: Backpressure test ---");
        input_size = 3;
        input_arr[0] = 11; input_arr[1] = 22; input_arr[2] = 33;
        gen_expected();
        print_array("Input", input_size);

        send_array();

        // Receive with intermittent ready
        begin
            integer i;
            i = 0;
            while (i < input_size) begin
                out_ready <= 1'b1;
                @(posedge clk);
                if (out_valid) begin
                    output_arr[i] = out_data;
                    i = i + 1;
                end
                out_ready <= 1'b0;
                repeat(2) @(posedge clk);
            end
        end

        print_array("Output", input_size);
        compare_arrays();

        // Test 8: Back-to-back sequences
        $display("\n--- Test 8: Back-to-back sequences ---");
        input_size = 3;
        input_arr[0] = 'hAA; input_arr[1] = 'hBB; input_arr[2] = 'hCC;
        run_test();

        input_size = 4;
        input_arr[0] = 'h11; input_arr[1] = 'h22; input_arr[2] = 'h33; input_arr[3] = 'h44;
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
