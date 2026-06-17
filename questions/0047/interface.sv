module moving_average #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_SIZE = 4
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire [DATA_WIDTH-1:0]      data_in,
    output wire [DATA_WIDTH-1:0]      data_out
);
// your implementation here

endmodule