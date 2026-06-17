`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter WINDOW_SIZE = 4,
    parameter INPUT1_1 = 8,
    parameter INPUT1_2 = 16,
    parameter INPUT1_3 = 24,
    parameter INPUT1_4 = 32,
    parameter INPUT1_5 = 40,
    parameter INPUT1_6 = 48
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg [DATA_WIDTH-1:0] data_in;
wire [DATA_WIDTH-1:0] data_out;

int ERR_COUNT = 0;

//DUT instantiation
   moving_average #(
      .DATA_WIDTH(DATA_WIDTH),
      .WINDOW_SIZE(WINDOW_SIZE)
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
reg [DATA_WIDTH-1:0] window [0:WINDOW_SIZE-1];
reg [DATA_WIDTH+$clog2(WINDOW_SIZE)-1:0] sum;
reg [DATA_WIDTH-1:0] expected_out;
integer i;

initial begin
    for (i = 0; i < WINDOW_SIZE; i = i + 1)
        window[i] = 0;
    forever begin
        @(posedge clk);
        if (reset) begin
            for (i = 0; i < WINDOW_SIZE; i = i + 1)
                window[i] <= 0;
            expected_out <= 0;
        end else begin
            // Shift window
            for (i = WINDOW_SIZE-1; i > 0; i = i - 1)
                window[i] <= window[i-1];
            window[0] <= data_in;

            #1;
            // Calculate sum
            sum = 0;
            for (i = 0; i < WINDOW_SIZE; i = i + 1)
                sum = sum + window[i];

            expected_out = sum >> $clog2(WINDOW_SIZE); // divide by WINDOW_SIZE

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