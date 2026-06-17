\m5_TLV_version 1d: tl-x.org
\SV

module vlan_detector (
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    input wire [15:0] in_ethertype,
    input wire [15:0] in_tci,
    input wire out_ready,
    output wire in_ready,
    output wire out_valid,
    output wire out_is_tagged,
    output wire [2:0] out_pcp,
    output wire out_dei,
    output wire [11:0] out_vid
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
