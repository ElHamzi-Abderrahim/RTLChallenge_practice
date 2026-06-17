module ring_counter #(
    parameter COUNTER_WIDTH = 4
)(
    input  wire                                clk,
    input  wire                                rst_n,
    output wire [COUNTER_WIDTH-1:0]            count_out
);
// your implementation here

reg [COUNTER_WIDTH-1:0] count_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_reg <= {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
    end else begin
        count_reg <= {count_reg[COUNTER_WIDTH-2:0], count_reg[COUNTER_WIDTH-1]};
    end
end

assign count_out = count_reg;

endmodule
