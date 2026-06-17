\m5_TLV_version 1d: tl-x.org
\SV

module mem_copy_ctrl #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [ADDR_WIDTH-1:0] src_addr,
    input wire [ADDR_WIDTH-1:0] dst_addr,
    input wire [ADDR_WIDTH-1:0] length,
    output wire busy,
    output wire done
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
