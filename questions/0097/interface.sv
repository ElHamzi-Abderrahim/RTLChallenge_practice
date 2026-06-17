module relu_unit #(
    parameter DATA_WIDTH = 16
)(
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       in_valid,
    input  wire signed [DATA_WIDTH-1:0] in_data,
    input  wire                       out_ready,
    output wire                       in_ready,
    output wire                       out_valid,
    output wire signed [DATA_WIDTH-1:0] out_data
);

    // Your implementation here...

endmodule
