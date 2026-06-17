\m5_TLV_version 1d: tl-x.org
\SV

module diff_calc #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire in_valid,
    input wire [DATA_WIDTH-1:0] in_data,
    input wire out_ready,
    output wire in_ready,
    output wire out_valid,
    output wire signed [DATA_WIDTH:0] out_diff
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
