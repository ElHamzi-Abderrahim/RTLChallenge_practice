\m5_TLV_version 1d: tl-x.org
\SV

module mem_interface (
    input wire clk,
    input wire reset,
    input wire req_i,
    input wire req_rnw_i,
    input wire [3:0] req_addr_i,
    input wire [31:0] req_wdata_i,
    output wire req_ready_o,
    output wire [31:0] req_rdata_o
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
