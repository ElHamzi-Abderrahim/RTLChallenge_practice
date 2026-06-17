module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input  wire                      wr_clk,
    input  wire                      wr_rst_n,
    input  wire                      wr_en,
    input  wire [DATA_WIDTH-1:0]     wr_data,
    output wire                      wr_full,

    input  wire                      rd_clk,
    input  wire                      rd_rst_n,
    input  wire                      rd_en,
    output wire [DATA_WIDTH-1:0]     rd_data,
    output wire                      rd_empty
);
// your implementation here

endmodule