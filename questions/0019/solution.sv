module priority_encoder (
    input  logic [3:0] data_i,
    output logic       valid_o,
    output logic [1:0] pos_o
);

  // Valid signal: high when any bit is active
  assign valid_o = |data_i;

  // Priority encoding: LSB has highest priority
  always_comb begin
    if (data_i[0]) begin
      pos_o = 2'b00;
    end else if (data_i[1]) begin
      pos_o = 2'b01;
    end else if (data_i[2]) begin
      pos_o = 2'b10;
    end else if (data_i[3]) begin
      pos_o = 2'b11;
    end else begin
      pos_o = 2'bxx;  // Don't care when no bits are active
    end
  end

endmodule
