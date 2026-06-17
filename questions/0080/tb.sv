`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8,
    parameter MATRIX_SIZE = 4
);

    localparam TB_SIM_TIMEOUT = 10_000_000;
    localparam TOTAL_SIZE = MATRIX_SIZE * MATRIX_SIZE;

    reg                   clk;
    reg                   rst_n;
    reg                   start;
    reg                   in_valid;
    reg  [DATA_WIDTH-1:0] in_data;
    reg                   out_ready;
    wire                  in_ready;
    wire                  out_valid;
    wire [DATA_WIDTH-1:0] out_data;
    wire                  out_last;

    integer ERR_COUNT = 0;

    matrix_transpose #(
        .DATA_WIDTH(DATA_WIDTH),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_valid(in_valid),
        .in_data(in_data),
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

    reg [DATA_WIDTH-1:0] input_matrix [0:TOTAL_SIZE-1];
    reg [DATA_WIDTH-1:0] output_arr [0:TOTAL_SIZE-1];
    integer num_outputs;

    // Reference transpose
    function automatic [DATA_WIDTH-1:0] ref_transpose;
        input integer out_idx;
        integer out_row, out_col, in_idx;
        begin
            out_row = out_idx / MATRIX_SIZE;
            out_col = out_idx % MATRIX_SIZE;
            // Transposed[row][col] = Original[col][row]
            in_idx = out_col * MATRIX_SIZE + out_row;
            ref_transpose = input_matrix[in_idx];
        end
    endfunction

    task automatic run_test;
        integer i, j, timeout;
        begin
            // Print input matrix
            $display("  Input Matrix:");
            for (i = 0; i < MATRIX_SIZE; i = i + 1) begin
                $write("    [");
                for (j = 0; j < MATRIX_SIZE; j = j + 1) begin
                    $write("%3d", input_matrix[i * MATRIX_SIZE + j]);
                    if (j < MATRIX_SIZE - 1) $write(", ");
                end
                $display("]");
            end

            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;

            num_outputs = 0;
            out_ready <= 1'b1;

            fork
                // Sender
                begin
                    for (i = 0; i < TOTAL_SIZE; i = i + 1) begin
                        timeout = 0;
                        while (!in_ready && timeout < 1000) begin
                            @(posedge clk);
                            timeout = timeout + 1;
                        end
                        in_valid <= 1'b1;
                        in_data  <= input_matrix[i];
                        @(posedge clk);
                        in_valid <= 1'b0;
                    end
                end

                // Receiver
                begin
                    timeout = 0;
                    while (num_outputs < TOTAL_SIZE && timeout < 10000) begin
                        @(posedge clk);
                        if (out_valid && out_ready) begin
                            output_arr[num_outputs] = out_data;
                            num_outputs = num_outputs + 1;
                            timeout = 0;
                        end else begin
                            timeout = timeout + 1;
                        end
                    end
                end
            join

            out_ready <= 1'b0;

            // Print output matrix
            $display("  Output Matrix (Transposed):");
            for (i = 0; i < MATRIX_SIZE; i = i + 1) begin
                $write("    [");
                for (j = 0; j < MATRIX_SIZE; j = j + 1) begin
                    $write("%3d", output_arr[i * MATRIX_SIZE + j]);
                    if (j < MATRIX_SIZE - 1) $write(", ");
                end
                $display("]");
            end

            // Verify
            if (num_outputs != TOTAL_SIZE) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Output count mismatch: expected %0d, got %0d", TOTAL_SIZE, num_outputs);
            end else begin
                for (i = 0; i < TOTAL_SIZE; i = i + 1) begin
                    if (output_arr[i] !== ref_transpose(i)) begin
                        ERR_COUNT = ERR_COUNT + 1;
                        $error("Element %0d mismatch: expected %0d, got %0d",
                               i, ref_transpose(i), output_arr[i]);
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

        $display("=== Testing Matrix Transpose ===");
        $display("DATA_WIDTH=%0d, MATRIX_SIZE=%0d\n", DATA_WIDTH, MATRIX_SIZE);

        // Test 1: Sequential values
        $display("--- Test 1: Sequential values ---");
        begin
            integer i;
            for (i = 0; i < TOTAL_SIZE; i = i + 1) begin
                input_matrix[i] = i + 1;
            end
        end
        run_test();

        // Test 2: Different pattern
        $display("--- Test 2: Different pattern ---");
        begin
            integer i;
            for (i = 0; i < TOTAL_SIZE; i = i + 1) begin
                input_matrix[i] = (i * 7 + 3) % 100;
            end
        end
        run_test();

        // Test 3: Same value (edge case)
        $display("--- Test 3: All same values ---");
        begin
            integer i;
            for (i = 0; i < TOTAL_SIZE; i = i + 1) begin
                input_matrix[i] = 42;
            end
        end
        run_test();

        // Test 4: Diagonal dominance
        $display("--- Test 4: Identity-like ---");
        begin
            integer i, j;
            for (i = 0; i < MATRIX_SIZE; i = i + 1) begin
                for (j = 0; j < MATRIX_SIZE; j = j + 1) begin
                    input_matrix[i * MATRIX_SIZE + j] = (i == j) ? 1 : 0;
                end
            end
        end
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
