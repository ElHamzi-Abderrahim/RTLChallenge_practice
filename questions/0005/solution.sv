module sequence_detector #(
    parameter PATTERN = 4'b1011
)(
    input  wire                                clk,
    input  wire                                rst_n,
    input  wire                                data_in,
    output wire                                pattern_detected
);
// your implementation here

reg [PATTERN-1:0] shift_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= {PATTERN{1'b0}};
    end else begin
        shift_reg <= {shift_reg[PATTERN-2:0], data_in};
    end
end

assign pattern_detected = (shift_reg == PATTERN);

endmodule
