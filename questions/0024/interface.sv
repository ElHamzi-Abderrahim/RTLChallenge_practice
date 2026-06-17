module binary_to_bcd #(
    parameter BINARY_WIDTH = 8,
    parameter BCD_DIGITS = 3,
    parameter BCD_WIDTH = 12
)(
    input  wire                         clk,
    input  wire                         reset,
    input  wire                         start,
    input  wire [BINARY_WIDTH-1:0]      binary_in,
    output wire [BCD_WIDTH-1:0]         bcd_out,
    output wire                         valid
);
// your implementation here

endmodule