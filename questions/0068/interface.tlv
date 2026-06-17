\m5_TLV_version 1d: tl-x.org
\SV

module factorial #(
    parameter DATA_WIDTH = 32,
    parameter INPUT_WIDTH = 5
)(
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    input wire [INPUT_WIDTH-1:0] in_n,
    input wire out_ready,
    output wire in_ready,
    output wire out_valid,
    output wire [DATA_WIDTH-1:0] out_factorial
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
