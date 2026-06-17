module gray_to_binary #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] gray_in,
    output wire [WIDTH-1:0] binary_out
);

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin : gen_xor
        assign binary_out[i] = ^gray_in[WIDTH-1:i];
    end
endgenerate

endmodule
