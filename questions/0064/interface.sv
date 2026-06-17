module bubble_sort #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire                  out_ready,
    output wire                  in_ready,
    output wire                  out_valid,
    output wire [DATA_WIDTH-1:0] out_data,
    output wire                  out_last
);
// your implementation here

endmodule
