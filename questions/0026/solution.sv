module seven_segment_driver #(
    parameter ACTIVE_HIGH = 1
)(
    input  wire [3:0]    bcd_digit,
    input  wire          enable,
    output wire [6:0]    segments,
    output wire          digit_valid
);

reg [6:0] seg_pattern;
reg valid;

always @(*) begin
    valid = 1'b1;
    case (bcd_digit)
        4'd0: seg_pattern = 7'b0111111;  // 0
        4'd1: seg_pattern = 7'b0000110;  // 1
        4'd2: seg_pattern = 7'b1011011;  // 2
        4'd3: seg_pattern = 7'b1001111;  // 3
        4'd4: seg_pattern = 7'b1100110;  // 4
        4'd5: seg_pattern = 7'b1101101;  // 5
        4'd6: seg_pattern = 7'b1111101;  // 6
        4'd7: seg_pattern = 7'b0000111;  // 7
        4'd8: seg_pattern = 7'b1111111;  // 8
        4'd9: seg_pattern = 7'b1101111;  // 9
        default: begin
            seg_pattern = 7'b0000000;
            valid = 1'b0;
        end
    endcase
end

assign segments = enable ? (ACTIVE_HIGH ? seg_pattern : ~seg_pattern) : (ACTIVE_HIGH ? 7'b0000000 : 7'b1111111);
assign digit_valid = enable ? valid : 1'b0;

endmodule
