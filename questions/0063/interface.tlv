\m5_TLV_version 1d: tl-x.org
\SV

module prime_check #(
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    input wire [DATA_WIDTH-1:0] in_num,
    input wire out_ready,
    output wire in_ready,
    output wire out_valid,
    output wire out_is_prime
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
