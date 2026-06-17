module digital_differentiator #(
    parameter DATA_WIDTH = 8
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire signed [DATA_WIDTH-1:0]    data_in,
    output wire signed [DATA_WIDTH:0]      data_out
);

    reg signed [DATA_WIDTH-1:0] prev_data;
    reg signed [DATA_WIDTH:0] data_out_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            prev_data <= {DATA_WIDTH{1'b0}};
            data_out_reg <= {DATA_WIDTH+1{1'b0}};
        end else begin
            prev_data <= data_in;
            data_out_reg <= data_in - prev_data;
        end
    end
    
    // Calculate difference: y[n] = x[n] - x[n-1]
    assign data_out = data_out_reg;

endmodule
