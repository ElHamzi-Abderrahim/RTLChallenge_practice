`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter VEC_W = 4,
    parameter INPUT1_1 = 5,
    parameter INPUT1_2 = 12,
    parameter INPUT1_3 = 0
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [VEC_W-1:0] bin_i;
wire [VEC_W-1:0] gray_o;
reg [VEC_W-1:0] expected_out;

int ERR_COUNT = 0;

//DUT instantiation
binary_to_gray_code #(
    .VEC_W(VEC_W)
) DUT (
    .bin_i(bin_i),
    .gray_o(gray_o)
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

// Golden solution for binary to gray conversion
always @(*) begin
    integer i;
    expected_out[VEC_W-1] = bin_i[VEC_W-1];
    for (i = VEC_W-2; i >= 0; i = i-1) begin
        expected_out[i] = bin_i[i+1] ^ bin_i[i];
    end
end

// Continuous checking
always @(*) begin
    #1; // Small delay to allow outputs to settle
    if(expected_out !== gray_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns gray_o = %b, expected = %b (bin_i = %b)",
               $time, gray_o, expected_out, bin_i);
    end else begin
        $display("%0tns bin_i = %b (%d), gray_o = %b (%d)", $time, bin_i, bin_i, gray_o, gray_o);
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
