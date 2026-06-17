\m5_TLV_version 1d: tl-x.org
\SV

module fib_gen #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire out_ready,
    output wire out_valid,
    output wire [DATA_WIDTH-1:0] out_data,
    output wire [7:0] out_index
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
