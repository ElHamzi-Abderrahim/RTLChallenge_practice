`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter DECIMATION_FACTOR = 4,
    parameter signed INPUT1_1 = 8,
    parameter signed INPUT1_2 = 16,
    parameter signed INPUT1_3 = 24,
    parameter signed INPUT1_4 = 32,
    parameter signed INPUT1_5 = 40,
    parameter signed INPUT1_6 = 48,
    parameter signed INPUT1_7 = 56,
    parameter signed INPUT1_8 = 64
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg signed [DATA_WIDTH-1:0] data_in;
reg data_valid_in;
wire signed [DATA_WIDTH-1:0] data_out;
wire data_valid_out;

int ERR_COUNT = 0;
int test_cycle = 0;

//DUT instantiation
   decimation_filter #(
      .DATA_WIDTH(DATA_WIDTH),
      .DECIMATION_FACTOR(DECIMATION_FACTOR)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .data_in(data_in),
      .data_valid_in(data_valid_in),
      .data_out(data_out),
      .data_valid_out(data_valid_out)
   );

// Clock generation
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    data_in = 0;
    data_valid_in = 0;
    @(posedge clk);
    @(posedge clk);
    reset = 0;

    // Test sequence
    @(negedge clk);
    
    data_in = INPUT1_1; data_valid_in = 1; test_cycle = 1;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_2; data_valid_in = 1; test_cycle = 2;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_3; data_valid_in = 1; test_cycle = 3;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_4; data_valid_in = 1; test_cycle = 4;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_5; data_valid_in = 1; test_cycle = 5;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_6; data_valid_in = 1; test_cycle = 6;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_7; data_valid_in = 1; test_cycle = 7;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_in = INPUT1_8; data_valid_in = 1; test_cycle = 8;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(negedge clk);
    data_valid_in = 0;
    @(negedge clk);
    @(negedge clk);

    check_result; //must call this task to end the simulation
end

// golden solution
reg signed [DATA_WIDTH-1:0] shift_reg [0:3];
reg [$clog2(DECIMATION_FACTOR)-1:0] sample_counter;
reg signed [DATA_WIDTH+2:0] filtered_sum;
reg signed [DATA_WIDTH-1:0] expected_out;
reg expected_valid_out;
integer i;

initial begin
    for (i = 0; i < 4; i = i + 1)
        shift_reg[i] = 0;
    sample_counter = 0;
    expected_valid_out = 0;
    expected_out = 0;

    forever begin
        @(posedge clk);
        if (reset) begin
            for (i = 0; i < 4; i = i + 1)
                shift_reg[i] <= 0;
            sample_counter <= 0;
            expected_valid_out <= 0;
            expected_out <= 0;
        end else if (data_valid_in) begin
            // Shift register for FIR filter
            for (i = 3; i > 0; i = i - 1)
                shift_reg[i] <= shift_reg[i-1];
            shift_reg[0] <= data_in;

            // FIR filter calculation: [1, 3, 3, 1] / 8
            filtered_sum = data_in + 3*shift_reg[0] + 3*shift_reg[1] + shift_reg[2];

            // Decimation logic
            if (sample_counter == DECIMATION_FACTOR - 1) begin
                expected_out <= filtered_sum >>> 3; // divide by 8
                expected_valid_out <= 1;
                sample_counter <= 0;
            end else begin
                expected_valid_out <= 0;
                sample_counter <= sample_counter + 1;
            end

            #1; // Small delay to check output
            if(data_valid_out !== expected_valid_out) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns Valid_out = %0b, expected = %0b", $time, data_valid_out, expected_valid_out);
            end else if (data_valid_out && (data_out !== expected_out)) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns Data_out = %0d, expected = %0d", $time, data_out, expected_out);
            end else begin
                $display("%0tns Cycle=%0d Data_out = %0d, Valid_out = %0b", $time, test_cycle, data_out, data_valid_out);
            end
        end else begin
            expected_valid_out <= 0;
        end
    end
end

//do not edit below
task check_result;
begin
   if(ERR_COUNT > 0) begin
      $display("Test failed with %0d errors.", ERR_COUNT);
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