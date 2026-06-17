\m5_TLV_version 1d: tl-x.org
\SV

module merge_sorted #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire in_a_valid,
    input wire [DATA_WIDTH-1:0] in_a_data,
    input wire in_a_last,
    input wire in_b_valid,
    input wire [DATA_WIDTH-1:0] in_b_data,
    input wire in_b_last,
    input wire out_ready,
    output wire in_a_ready,
    output wire in_b_ready,
    output wire out_valid,
    output wire [DATA_WIDTH-1:0] out_data,
    output wire out_last
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
