\m5_TLV_version 1d: tl-x.org
\SV

module histogram_calc #(
    parameter BIN_ADDR_WIDTH = 4,
    parameter COUNT_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire clear,
    input wire data_valid,
    input wire [BIN_ADDR_WIDTH-1:0] data_in,
    input wire read_req,
    input wire [BIN_ADDR_WIDTH-1:0] read_addr,
    output wire ready,
    output wire read_valid,
    output wire [COUNT_WIDTH-1:0] read_data
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
