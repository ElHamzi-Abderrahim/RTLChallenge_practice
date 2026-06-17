\m5_TLV_version 1d: tl-x.org
\SV

module mem_arbiter #(
    parameter NUM_MASTERS = 4,
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [NUM_MASTERS-1:0] req,
    input wire [NUM_MASTERS-1:0] req_wr,
    input wire [NUM_MASTERS*ADDR_WIDTH-1:0] req_addr,
    input wire [NUM_MASTERS*DATA_WIDTH-1:0] req_wdata,
    output wire [NUM_MASTERS-1:0] gnt,
    output wire [NUM_MASTERS*DATA_WIDTH-1:0] gnt_rdata,
    output wire [NUM_MASTERS-1:0] gnt_rvalid
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
