module crc_calculator #(
    parameter CRC_WIDTH = 8,
    parameter POLYNOMIAL = 8'h07
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      data_valid,
    input  wire [7:0]                data_in,
    input  wire                      start,
    output wire [CRC_WIDTH-1:0]      crc_out,
    output wire                      crc_valid
);
// your implementation here

endmodule