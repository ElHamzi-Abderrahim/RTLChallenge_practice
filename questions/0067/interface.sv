module moving_max #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_SIZE = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  out_ready,
    output wire                  in_ready,
    output wire                  out_valid,
    output wire [DATA_WIDTH-1:0] out_max
);
// your implementation here

endmodule
