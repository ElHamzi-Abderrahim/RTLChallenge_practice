`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter SELECT_WIDTH = 2,
    parameter DATA_IN_ARRAY = 32'hDEADBEEF, // {0xDE, 0xAD, 0xBE, 0xEF}
    parameter SELECT_1 = 2'b00,
    parameter SELECT_2 = 2'b01,
    parameter SELECT_3 = 2'b10,
    parameter SELECT_4 = 2'b11
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [DATA_WIDTH*(2**SELECT_WIDTH)-1:0] data_in;
reg [SELECT_WIDTH-1:0] select;
wire [DATA_WIDTH-1:0] data_out;
reg [DATA_WIDTH-1:0] expected_out;

int ERR_COUNT = 0;

//DUT instantiation
   simple_mux #(
      .DATA_WIDTH(DATA_WIDTH),
      .SELECT_WIDTH(SELECT_WIDTH)
   ) DUT (
      .data_in(data_in),
      .select(select),
      .data_out(data_out)
   );

// stimulus/test sequence
initial begin
    // Initialize inputs
    data_in = DATA_IN_ARRAY;
    select = 0;
    #20;

    // Test all select combinations
    test_select(SELECT_1);
    test_select(SELECT_2);
    test_select(SELECT_3);
    test_select(SELECT_4);

    check_result;
end

// Task to test a specific select value
task test_select(input [SELECT_WIDTH-1:0] sel_val);
    select = sel_val;
    #20;

    // Calculate expected output
    expected_out = data_in[sel_val*DATA_WIDTH +: DATA_WIDTH];

    if(data_out !== expected_out) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns Select %b: data_out = %h, expected = %h", $time, sel_val, data_out, expected_out);
    end else begin
        $display("%0tns Select %b: data_out = %h", $time, sel_val, data_out);
    end
endtask

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
