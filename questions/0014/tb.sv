`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter BIN_W = 4,
    parameter ONE_HOT_W = 16,
    parameter INPUT1_1 = 5,
    parameter INPUT1_2 = 12,
    parameter INPUT1_3 = 0
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [BIN_W-1:0] bin_i;
wire [ONE_HOT_W-1:0] one_hot_o;
reg [ONE_HOT_W-1:0] expected_out;

int ERR_COUNT = 0;

//DUT instantiation
binary_to_one_hot #(
    .BIN_W(BIN_W),
    .ONE_HOT_W(ONE_HOT_W)
) DUT (
    .bin_i(bin_i),
    .one_hot_o(one_hot_o)
);

// stimulus/test sequence
initial begin
    // Initialize inputs
    bin_i = INPUT1_1;
    #20;
    bin_i = INPUT1_2;
    #20;
    bin_i = INPUT1_3;
    #20;
    check_result;
end 

// Golden solution
always @(*) begin
    expected_out = {{(ONE_HOT_W-1){1'b0}}, 1'b1} << bin_i;
end

// Continuous checking
always @(*) begin
    #1; // Small delay to allow outputs to settle
    if(expected_out !== one_hot_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns one_hot_o = %b, expected = %b (bin_i = %d)",
               $time, one_hot_o, expected_out, bin_i);
    end else begin
        $display("%0tns bin_i = %d, one_hot_o = %b", $time, bin_i, one_hot_o);
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
