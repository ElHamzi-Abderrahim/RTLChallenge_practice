\m5_TLV_version 1d: tl-x.org
\SV

module digital_differentiator #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire reset,
    input wire signed [DATA_WIDTH-1:0] data_in,
    output wire signed [DATA_WIDTH:0] data_out
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
