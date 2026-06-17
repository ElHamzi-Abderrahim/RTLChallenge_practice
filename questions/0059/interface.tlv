\m5_TLV_version 1d: tl-x.org
\SV

module scratchpad_acc #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [ADDR_WIDTH-1:0] src_addr,
    input wire [ADDR_WIDTH-1:0] count,
    input wire [ADDR_WIDTH-1:0] dst_addr,
    output wire busy,
    output wire done,
    output wire [DATA_WIDTH-1:0] result
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
