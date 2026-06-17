\m5_TLV_version 1d: tl-x.org
\SV

module lut_interpolator #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter FRAC_BITS = 4
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [ADDR_WIDTH+FRAC_BITS-1:0] phase,
    output wire done,
    output wire [DATA_WIDTH-1:0] result
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
