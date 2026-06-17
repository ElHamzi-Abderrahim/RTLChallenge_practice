module mac_unit #(
    parameter DATA_WIDTH = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         clear,
    input  wire                         in_valid,
    input  wire signed [DATA_WIDTH-1:0] in_a,
    input  wire signed [DATA_WIDTH-1:0] in_b,
    input  wire                         in_last,
    input  wire                         out_ready,
    output wire                         in_ready,
    output wire                         out_valid,
    output wire signed [DATA_WIDTH*2+7:0] out_acc
);

    // Your implementation here...

endmodule
