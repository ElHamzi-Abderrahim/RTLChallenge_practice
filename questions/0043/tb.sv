`timescale 1ns/1ps

module tb #(
    parameter INPUT_WIDTH = 8,
    parameter COUNT_WIDTH = 4
);

localparam NUM_VECTORS = 16;
localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg  [INPUT_WIDTH-1:0] data_in;
wire [COUNT_WIDTH-1:0] zero_count;
wire all_zero;

integer ERR_COUNT = 0;
integer i;

// Parallel test vectors
reg [INPUT_WIDTH-1:0] tv_data [0:NUM_VECTORS-1];

// DUT
leading_zero_counter #(
    .INPUT_WIDTH(INPUT_WIDTH),
    .COUNT_WIDTH(COUNT_WIDTH)
) DUT (
    .data_in(data_in),
    .zero_count(zero_count),
    .all_zero(all_zero)
);

// Reference leading zero count
function [COUNT_WIDTH-1:0] count_leading_zeros(input [INPUT_WIDTH-1:0] data);
    integer k;
    begin
        count_leading_zeros = 0;
        for (k = INPUT_WIDTH-1; k >= 0; k = k - 1) begin
            if (data[k] == 1'b0)
                count_leading_zeros = count_leading_zeros + 1;
            else
                k = -1; // break
        end
    end
endfunction

// Reference all-zero detection
function is_all_zeros(input [INPUT_WIDTH-1:0] data);
    begin
        is_all_zeros = (data == 0);
    end
endfunction

// Initialize test vectors - scaled to INPUT_WIDTH
initial begin
    // Boundary cases
    tv_data[0]  = {INPUT_WIDTH{1'b0}};           // all zeros
    tv_data[1]  = {INPUT_WIDTH{1'b1}};           // all ones

    // Single-bit patterns (MSB position varying)
    tv_data[2]  = {{1'b1}, {(INPUT_WIDTH-1){1'b0}}};  // MSB set (0 leading zeros)
    tv_data[3]  = {{2{1'b0}}, {(INPUT_WIDTH-2){1'b1}}};  // 2 leading zeros
    tv_data[4]  = {{3{1'b0}}, {(INPUT_WIDTH-3){1'b1}}};  // 3 leading zeros
    tv_data[5]  = {{4{1'b0}}, {(INPUT_WIDTH-4){1'b1}}};  // 4 leading zeros

    // Single bit set at various positions
    tv_data[6]  = 1 << (INPUT_WIDTH-1);          // MSB only
    tv_data[7]  = 1 << (INPUT_WIDTH/2);          // middle bit
    tv_data[8]  = 1;                              // LSB only

    // Alternating patterns (scaled to width)
    tv_data[9]  = {INPUT_WIDTH/2{2'b10}};        // 10101010...
    tv_data[10] = {INPUT_WIDTH/2{2'b01}};        // 01010101...

    // Other patterns
    tv_data[11] = {{INPUT_WIDTH/2{1'b0}}, {INPUT_WIDTH/2{1'b1}}};  // half zeros, half ones
    tv_data[12] = {{INPUT_WIDTH/2{1'b1}}, {INPUT_WIDTH/2{1'b0}}};  // half ones, half zeros
    tv_data[13] = {{(INPUT_WIDTH-1){1'b0}}, 1'b1};  // only LSB set
    tv_data[14] = 2;                              // single bit at position 1
    tv_data[15] = 4;                              // single bit at position 2
end

// Run directed test
initial begin
    reg [COUNT_WIDTH-1:0] exp_cnt;
    reg exp_az;

    $display("Running %0d directed test vectors (INPUT_WIDTH=%0d, COUNT_WIDTH=%0d)",
             NUM_VECTORS, INPUT_WIDTH, COUNT_WIDTH);

    for (i = 0; i < NUM_VECTORS; i = i + 1) begin
        data_in = tv_data[i];
        #5;

        // Calculate expected values using reference functions
        exp_cnt = count_leading_zeros(tv_data[i]);
        exp_az = is_all_zeros(tv_data[i]);

        if (zero_count !== exp_cnt) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERR[%0d]: cnt exp=%0d got=%0d data=0x%0h",
                     i, exp_cnt, zero_count, tv_data[i]);
        end
        if (all_zero !== exp_az) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERR[%0d]: az exp=%0b got=%0b data=0x%0h",
                     i, exp_az, all_zero, tv_data[i]);
        end
    end

    test_exhaustive();
    test_edge_cases();
    check_result();
end

// Exhaustive test for small widths, sampling for larger
task test_exhaustive;
    integer j;
    integer max_tests;
    integer step;
    reg [COUNT_WIDTH-1:0] exp;
    reg exp_az;
begin
    // For small INPUT_WIDTH, test all values; for larger, sample
    if (INPUT_WIDTH <= 8) begin
        max_tests = (1 << INPUT_WIDTH);
        step = 1;
    end else if (INPUT_WIDTH <= 16) begin
        max_tests = 1024;  // Sample 1024 values
        step = (1 << INPUT_WIDTH) / 1024;
        if (step < 1) step = 1;
    end else begin
        max_tests = 256;   // Sample 256 values for very wide inputs
        step = (1 << (INPUT_WIDTH > 20 ? 20 : INPUT_WIDTH)) / 256;
        if (step < 1) step = 1;
    end

    $display("Exhaustive/sampling test (%0d values)...", max_tests);

    for (j = 0; j < max_tests; j = j + 1) begin
        data_in = (j * step);
        #1;

        exp    = count_leading_zeros(data_in);
        exp_az = is_all_zeros(data_in);

        if (zero_count !== exp || all_zero !== exp_az) begin
            ERR_COUNT = ERR_COUNT + 1;
            if (ERR_COUNT < 10)
                $error("Mismatch: x=0x%0h exp=%0d/%0b got=%0d/%0b",
                         data_in, exp, exp_az, zero_count, all_zero);
        end
    end
end
endtask

// Simple extra checks - parameterized for any width
task test_edge_cases;
begin
    $display("Edge case tests...");
    // All zeros - should return INPUT_WIDTH leading zeros
    data_in = 0;
    #2;
    if (zero_count !== INPUT_WIDTH) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("Edge case fail: all zeros, exp=%0d got=%0d", INPUT_WIDTH, zero_count);
    end

    // MSB set - should return 0 leading zeros
    data_in = (1 << (INPUT_WIDTH-1));
    #2;
    if (zero_count !== 0) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("Edge case fail: MSB set, exp=0 got=%0d", zero_count);
    end

    // Only LSB set - should return INPUT_WIDTH-1 leading zeros
    data_in = 1;
    #2;
    if (zero_count !== (INPUT_WIDTH-1)) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("Edge case fail: LSB only, exp=%0d got=%0d", INPUT_WIDTH-1, zero_count);
    end
end
endtask

//do not edit below
task check_result;
begin
   if(ERR_COUNT > 0) begin
      $error("Test failed with %0d errors.", ERR_COUNT);
   end else begin
      $display("Test PASS");
   end
   $finish;
end
endtask

string filename;

initial begin
   if ($value$plusargs("VCDFILE=%s",filename)) begin
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
