`timescale 1ns / 1ps

module tb #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_SIZE = 4
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
    wire [DATA_WIDTH-1:0] out_max;

    integer ERR_COUNT = 0;

    moving_max #(
        .DATA_WIDTH(DATA_WIDTH),
        .WINDOW_SIZE(WINDOW_SIZE)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in_valid(in_valid),
        .in_data(in_data),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_max(out_max)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reference model - circular buffer
    reg [DATA_WIDTH-1:0] ref_buffer [0:WINDOW_SIZE-1];
    integer ref_wr_ptr;
    integer ref_count;

    task automatic ref_clear;
        integer i;
        begin
            ref_wr_ptr = 0;
            ref_count = 0;
            for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
                ref_buffer[i] = 0;
            end
        end
    endtask

    function automatic [DATA_WIDTH-1:0] ref_get_max;
        integer i;
        reg [DATA_WIDTH-1:0] m;
        begin
            m = 0;
            for (i = 0; i < ref_count; i = i + 1) begin
                if (ref_buffer[i] > m) m = ref_buffer[i];
            end
            ref_get_max = m;
        end
    endfunction

    task automatic ref_add(input [DATA_WIDTH-1:0] val);
        begin
            ref_buffer[ref_wr_ptr] = val;
            ref_wr_ptr = (ref_wr_ptr + 1) % WINDOW_SIZE;
            if (ref_count < WINDOW_SIZE) ref_count = ref_count + 1;
        end
    endtask

    // Send value and check output
    task automatic send_and_check(
        input [DATA_WIDTH-1:0] value
    );
        reg [DATA_WIDTH-1:0] expected_max;
        integer timeout;
        begin
            // Update reference model
            ref_add(value);
            expected_max = ref_get_max();

            // Wait for ready
            timeout = 0;
            while (!in_ready && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for in_ready");
                disable send_and_check;
            end

            // Send input
            in_valid <= 1'b1;
            in_data  <= value;
            @(posedge clk);
            in_valid <= 1'b0;

            // Wait for output
            out_ready <= 1'b1;
            timeout = 0;
            while (!out_valid && timeout < 1000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 1000) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("TIMEOUT waiting for out_valid");
                disable send_and_check;
            end

            // Check result
            if (out_max !== expected_max) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("MISMATCH: input=%0d, expected_max=%0d, got=%0d",
                       value, expected_max, out_max);
            end else begin
                $display("Input %0d -> Max %0d (correct)", value, out_max);
            end

            @(posedge clk);
        end
    endtask

    task automatic do_start;
        begin
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;
            ref_clear();
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        in_valid = 0;
        in_data = 0;
        out_ready = 0;
        ref_clear();

        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);

        $display("=== Testing Moving Maximum Filter ===");
        $display("DATA_WIDTH=%0d, WINDOW_SIZE=%0d\n", DATA_WIDTH, WINDOW_SIZE);

        // Test 1: Fill window and slide
        $display("--- Test 1: Basic sliding window ---");
        do_start();
        send_and_check(2);
        send_and_check(5);
        send_and_check(1);
        send_and_check(8);
        send_and_check(3);
        send_and_check(4);

        // Test 2: Increasing sequence
        $display("\n--- Test 2: Increasing sequence ---");
        do_start();
        send_and_check(10);
        send_and_check(20);
        send_and_check(30);
        send_and_check(40);
        send_and_check(50);

        // Test 3: Decreasing sequence
        $display("\n--- Test 3: Decreasing sequence ---");
        do_start();
        send_and_check(50);
        send_and_check(40);
        send_and_check(30);
        send_and_check(20);
        send_and_check(10);

        // Test 4: Same values
        $display("\n--- Test 4: Same values ---");
        do_start();
        send_and_check(42);
        send_and_check(42);
        send_and_check(42);
        send_and_check(42);

        // Test 5: Single spike
        $display("\n--- Test 5: Single spike ---");
        do_start();
        send_and_check(5);
        send_and_check(5);
        send_and_check(100);
        send_and_check(5);
        send_and_check(5);
        send_and_check(5);  // Spike should be out of window now

        // Test 6: Alternating
        $display("\n--- Test 6: Alternating ---");
        do_start();
        send_and_check(10);
        send_and_check(90);
        send_and_check(10);
        send_and_check(90);
        send_and_check(10);
        send_and_check(90);

        // Test 7: Reset in middle
        $display("\n--- Test 7: Reset in middle ---");
        do_start();
        send_and_check(50);
        send_and_check(60);
        do_start();  // Reset
        send_and_check(10);
        send_and_check(20);

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
