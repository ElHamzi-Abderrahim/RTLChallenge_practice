module subtractor #(
    parameter INPUT_WIDTH = 8
)(
    input  wire [INPUT_WIDTH-1:0]              data_in_1,
    input  wire [INPUT_WIDTH-1:0]              data_in_2,
    output wire [INPUT_WIDTH-1:0]                data_out
);

assign data_out = (data_in_1 > data_in_2) ? (data_in_1 - data_in_2) : {INPUT_WIDTH{1'b0}};

endmodule
