`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8,
    parameter KERNEL_SIZE = 3
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam MAX_SIZE = 32;
    localparam OUT_WIDTH = DATA_WIDTH * 2 + $clog2(KERNEL_SIZE);

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   kernel_valid;
    reg  [DATA_WIDTH-1:0] kernel_data;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_data;
    reg                   in_last;
    reg                   out_ready;
    wire                  kernel_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire [OUT_WIDTH-1:0]  out_data;
    wire                  out_last;

    integer ERR_COUNT = 0;

    conv_1d #(
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .kernel_valid(kernel_valid),
        .kernel_data(kernel_data),
        .in_valid(in_valid),
        .in_data(in_data),
        .in_last(in_last),
        .out_ready(out_ready),
        .kernel_ready(kernel_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_data(out_data),
        .out_last(out_last)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [DATA_WIDTH-1:0] test_kernel [0:KERNEL_SIZE-1];
    reg [DATA_WIDTH-1:0] test_input [0:MAX_SIZE-1];
    integer input_size;

    reg [OUT_WIDTH-1:0] outputs [0:MAX_SIZE-1];
    integer num_outputs;

    // Reference convolution
    function automatic [OUT_WIDTH-1:0] ref_conv;
        input integer idx;
        integer k;
        reg [OUT_WIDTH-1:0] sum;
        begin
            sum = 0;
            for (k = 0; k < KERNEL_SIZE; k = k + 1) begin
                sum = sum + test_input[idx + k] * test_kernel[k];
            end
            ref_conv = sum;
        end
    endfunction

    task automatic run_test;
        integer i, timeout;
        integer exp_outputs;
        begin
            $write("  Kernel: [");
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                $write("%0d", test_kernel[i]);
                if (i < KERNEL_SIZE - 1) $write(", ");
            end
            $display("]");

            $write("  Input:  [");
            for (i = 0; i < input_size; i = i + 1) begin
                $write("%0d", test_input[i]);
                if (i < input_size - 1) $write(", ");
            end
            $display("]");

            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            // Load kernel
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                timeout = 0;
                while (!kernel_ready && timeout < 1000) begin
                    @(posedge clk);
                    timeout = timeout + 1;
                end
                kernel_valid <= 1'b1;
                kernel_data  <= test_kernel[i];
                @(posedge clk);
                kernel_valid <= 1'b0;
            end

            num_outputs = 0;
            out_ready <= 1'b1;

            // Send input and collect outputs
            fork
                begin
                    for (i = 0; i < input_size; i = i + 1) begin
                        in_valid <= 1'b1;
                        in_data  <= test_input[i];
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

                begin
                    timeout = 0;
                    while (timeout < 1000) begin
                        @(posedge clk);
                        if (out_valid && out_ready) begin
                            outputs[num_outputs] = out_data;
                            num_outputs = num_outputs + 1;
                            timeout = 0;
                            if (out_last) timeout = 1000;
                        end else begin
                            timeout = timeout + 1;
                        end
                    end
                end
            join

            out_ready <= 1'b0;

            $write("  Output: [");
            for (i = 0; i < num_outputs; i = i + 1) begin
                $write("%0d", outputs[i]);
                if (i < num_outputs - 1) $write(", ");
            end
            $display("]");

            exp_outputs = input_size - KERNEL_SIZE + 1;
            if (exp_outputs < 0) exp_outputs = 0;

            if (num_outputs != exp_outputs) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Output count mismatch: expected %0d, got %0d", exp_outputs, num_outputs);
            end else begin
                for (i = 0; i < num_outputs; i = i + 1) begin
                    if (outputs[i] !== ref_conv(i)) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("Output[%0d] mismatch: expected %0d, got %0d", i, ref_conv(i), outputs[i]);
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
        kernel_valid = 0;
        kernel_data = 0;
        in_valid = 0;
        in_data = 0;
        in_last = 0;
        out_ready = 0;

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing 1D Convolution Engine ===");
        $display("DATA_WIDTH=%0d, KERNEL_SIZE=%0d\n", DATA_WIDTH, KERNEL_SIZE);

        // Test 1: Basic convolution
        $display("--- Test 1: Basic ---");
        test_kernel[0] = 1; test_kernel[1] = 2; test_kernel[2] = 1;
        input_size = 5;
        test_input[0] = 1; test_input[1] = 2; test_input[2] = 3;
        test_input[3] = 4; test_input[4] = 5;
        run_test();

        // Test 2: Edge detection kernel
        $display("--- Test 2: Edge detection ---");
        test_kernel[0] = 1; test_kernel[1] = 0; test_kernel[2] = 255; // -1 as unsigned
        input_size = 6;
        test_input[0] = 10; test_input[1] = 10; test_input[2] = 10;
        test_input[3] = 50; test_input[4] = 50; test_input[5] = 50;
        run_test();

        // Test 3: Minimum size
        $display("--- Test 3: Minimum size ---");
        test_kernel[0] = 1; test_kernel[1] = 1; test_kernel[2] = 1;
        input_size = 3;
        test_input[0] = 3; test_input[1] = 6; test_input[2] = 9;
        run_test();

        // Test 4: All ones kernel (moving sum)
        $display("--- Test 4: Moving sum ---");
        test_kernel[0] = 1; test_kernel[1] = 1; test_kernel[2] = 1;
        input_size = 7;
        test_input[0] = 1; test_input[1] = 2; test_input[2] = 3;
        test_input[3] = 4; test_input[4] = 5; test_input[5] = 6;
        test_input[6] = 7;
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
