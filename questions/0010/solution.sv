module simple_alu (
  input     wire [7:0]   a_i,
  input     wire [7:0]   b_i,
  input     wire [2:0]   op_i,

  output    reg [7:0]    alu_o
);

always @(*) begin
    case (op_i)
        3'b000: alu_o = a_i + b_i;       // ADD
        3'b001: alu_o = a_i - b_i;       // SUB
        3'b010: alu_o = a_i & b_i;       // AND
        3'b011: alu_o = a_i | b_i;       // OR
        3'b100: alu_o = a_i ^ b_i;       // XOR
        3'b101: alu_o = ~a_i;            // NOT
        3'b110: alu_o = a_i << 1;        // SLL
        3'b111: alu_o = a_i >> 1;        // SRL
        default: alu_o = 8'h00;
    endcase
end

endmodule
