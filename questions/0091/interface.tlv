\m5_TLV_version 1d: tl-x.org
\SV

module eth_header_parser (
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    input wire [7:0] in_data,
    input wire in_sof,
    input wire out_ready,
    output wire in_ready,
    output wire out_valid,
    output wire [47:0] out_dst_mac,
    output wire [47:0] out_src_mac,
    output wire [15:0] out_ethertype
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
