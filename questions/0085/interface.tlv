\m5_TLV_version 1d: tl-x.org
\SV

module dot_product #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire vec_a_valid,
    input wire [DATA_WIDTH-1:0] vec_a_data,
    input wire vec_a_last,
    input wire vec_b_valid,
    input wire [DATA_WIDTH-1:0] vec_b_data,
    input wire vec_b_last,
    input wire out_ready,
    output wire vec_a_ready,
    output wire vec_b_ready,
    output wire out_valid,
    output wire [DATA_WIDTH*2+7:0] out_result
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
