\m5_TLV_version 1d: tl-x.org
\SV

module regfile_max #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [ADDR_WIDTH-1:0] count,
    input wire write_en,
    input wire [ADDR_WIDTH-1:0] write_addr,
    input wire [DATA_WIDTH-1:0] write_data,
    output wire busy,
    output wire done,
    output wire [DATA_WIDTH-1:0] max_val,
    output wire [ADDR_WIDTH-1:0] max_idx
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
