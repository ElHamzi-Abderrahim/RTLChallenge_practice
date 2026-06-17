module trailing_zero #(
    parameter DATA_WIDTH = 8
)(
    input  wire                            clk,
    input  wire                            rst_n,
    input  wire                            in_valid,
    input  wire [DATA_WIDTH-1:0]           in_data,
    input  wire                            out_ready,
    output wire                            in_ready,
    output wire                            out_valid,
    output wire [$clog2(DATA_WIDTH+1)-1:0] out_count
);

    // Your implementation here...

endmodule
