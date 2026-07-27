module sequence_detector #(
    parameter PATTERN = 4'b1011
)(
    input  wire                                clk,
    input  wire                                rst_n,
    input  wire                                data_in,
    output wire                                pattern_detected
);
// your implementation here
parameter pattern_size = 4;
reg [pattern_size-1:0] shift_reg;
reg pattern_detected_reg ;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= {pattern_size{1'b0}};
    end else begin
        shift_reg <= {shift_reg[pattern_size-2:0], data_in};
        if (shift_reg == PATTERN) begin // pattern_detected will be asserted in the next clock cycle if the pattern is detected in this clock cycle.
            pattern_detected_reg <= 1'b1;
        end else begin
            pattern_detected_reg <= 1'b0;
        end

    end
end

assign pattern_detected = pattern_detected_reg;

endmodule
