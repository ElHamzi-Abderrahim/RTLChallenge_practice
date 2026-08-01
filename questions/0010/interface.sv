module simple_alu (
  input     wire [7:0]   a_i,
  input     wire [7:0]   b_i,
  input     wire [2:0]   op_i,

  output    reg [7:0]    alu_o
);

  parameter ADD_OPCODE = 3'b000 , 
            SUB_OPCODE = 3'b001 ,
            AND_OPCODE = 3'b010 ,
            OR_OPCODE  = 3'b011 ,
            XOR_OPCODE = 3'b100 ,
            NOT_OPCODE = 3'b101 ,
            SLL_OPCODE = 3'b110 ,
            SRL_OPCODE = 3'b111 
          ;

  always_comb begin : alu_comb
    case (op_i)
      ADD_OPCODE:
        alu_o = a_i + b_i ;
      SUB_OPCODE:
        alu_o = a_i - b_i ;
      AND_OPCODE:
        alu_o = a_i & b_i ;
      OR_OPCODE:
        alu_o = a_i | b_i ;
      XOR_OPCODE:
        alu_o = a_i ^ b_i ;
      NOT_OPCODE:
        alu_o = ~a_i ;
      SLL_OPCODE:
        alu_o = a_i << 1 ;
      SRL_OPCODE:
        alu_o = a_i >> 1 ;
      default: 
        alu_o = {8{1'b0}} ;
    endcase
  end

endmodule