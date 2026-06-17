\m5_TLV_version 1d: tl-x.org
\SV

module mem_read_ctrl #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [ADDR_WIDTH-1:0] num_reads,
    output wire done,
    output wire [DATA_WIDTH-1:0] checksum
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
