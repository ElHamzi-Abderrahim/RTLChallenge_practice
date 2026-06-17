`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter INPUT_WIDTH  = 8,
    parameter INPUT1_1 = 8,
    parameter INPUT2_1 = 8,
    parameter INPUT1_2 = 1,
    parameter INPUT2_2 = 2,
    parameter INPUT1_3 = 3,
    parameter INPUT2_3 = 4
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [INPUT_WIDTH-1:0] data_in_1;
reg [INPUT_WIDTH-1:0] data_in_2;
wire [INPUT_WIDTH*2-1:0] data_out;

int ERR_COUNT = 0;

//DUT instantiation
   multiplier #(
      .INPUT_WIDTH(INPUT_WIDTH)
   ) DUT (
      .data_in_1(data_in_1),
      .data_in_2(data_in_2),
      .data_out(data_out)
   );

// stimulus/test sequence
initial begin
    // Initialize inputs
    data_in_1 = INPUT1_1;
    data_in_2 = INPUT2_1;
    # 20;
    data_in_1 = INPUT1_2;
    data_in_2 = INPUT2_2;
    # 20;
    data_in_1 = INPUT1_3;
    data_in_2 = INPUT2_3;
    # 20;
    check_result;
end

// golden solution
initial begin
forever begin
   @(data_in_1, data_in_2, data_out);
   #1;
   if(data_out !== (data_in_1 * data_in_2)) begin
      ERR_COUNT = ERR_COUNT + 1;
      $error("%0tns Data_out = %0d, expected = %0d", $time, data_out, (data_in_1 * data_in_2));
   end else begin
      $display("%0tns Data_out = %0d, Data_in_1 = %0d, Data_in_2 = %0d", $time, data_out, data_in_1, data_in_2);
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
