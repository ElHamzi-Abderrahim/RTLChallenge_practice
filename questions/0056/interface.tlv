\m5_TLV_version 1d: tl-x.org
\SV

module counter_manager #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire cmd_valid,
    input wire [1:0] cmd_op,
    input wire [ADDR_WIDTH-1:0] cmd_addr,
    input wire [DATA_WIDTH-1:0] cmd_wdata,
    output wire cmd_ready,
    output wire resp_valid,
    output wire [DATA_WIDTH-1:0] resp_data
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
