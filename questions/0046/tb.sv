`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter signed INPUT1_1 = 16,
    parameter signed INPUT1_2 = 32,
    parameter signed INPUT1_3 = 48,
    parameter signed INPUT1_4 = 64,
    parameter signed INPUT1_5 = 0,
    parameter signed INPUT1_6 = -16
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg signed [DATA_WIDTH-1:0] data_in;
wire signed [DATA_WIDTH+1:0] data_out;

int ERR_COUNT = 0;

//DUT instantiation
   fir_filter #(
      .DATA_WIDTH(DATA_WIDTH)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .data_in(data_in),
      .data_out(data_out)
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
    @(posedge clk);
    @(posedge clk);
    reset = 0;

    // Test sequence
    @(posedge clk);
    #1;
    data_in = INPUT1_1;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(posedge clk);
    #1;
    data_in = INPUT1_2;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(posedge clk);
    #1;
    data_in = INPUT1_3;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(posedge clk);
    #1;
    data_in = INPUT1_4;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(posedge clk);
    #1;
    data_in = INPUT1_5;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(posedge clk);
    #1;
    data_in = INPUT1_6;
    $display("%0tns Applying data_in = %0d", $time, data_in);
    @(posedge clk);
    @(posedge clk);

    check_result; //must call this task to end the simulation
end

// golden solution
reg signed [DATA_WIDTH-1:0] shift_reg [0:2];
reg signed [DATA_WIDTH+3:0] expected_sum;
reg signed [DATA_WIDTH+1:0] expected_out;

initial begin
    shift_reg[0] = 0; shift_reg[1] = 0; shift_reg[2] = 0; 
    forever begin
        @(posedge clk);
        if (reset) begin
            shift_reg[0] <= 0; shift_reg[1] <= 0; shift_reg[2] <= 0; 
            expected_out <= 0;
        end else begin
            shift_reg[2] <= shift_reg[1];
            shift_reg[1] <= shift_reg[0];
            shift_reg[0] <= data_in;

            expected_sum = data_in + 2*shift_reg[0] + 2*shift_reg[1] + shift_reg[2];
            expected_out = expected_sum >>> 3; // divide by 8

            #1; // Small delay to check output
            if(data_out !== expected_out) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns Data_out = %0d, expected = %0d", $time, data_out, expected_out);
            end else begin
                $display("%0tns Data_out = %0d, Data_in = %0d", $time, data_out, data_in);
            end
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