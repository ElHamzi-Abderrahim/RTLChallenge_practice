module decimation_filter #(
    parameter DATA_WIDTH = 8,
    parameter DECIMATION_FACTOR = 4
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire signed [DATA_WIDTH-1:0]    data_in,
    input  wire                       data_valid_in,
    output wire signed [DATA_WIDTH-1:0]    data_out,
    output wire                       data_valid_out
);
// your implementation here

endmodule