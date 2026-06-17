module lfsr (
  input     wire      clk,
  input     wire      reset,

  output    wire[3:0] lfsr_o
);

reg [3:0] lfsr_reg;
wire feedback;

assign feedback = lfsr_reg[3] ^ lfsr_reg[1];

always @(posedge clk or posedge reset) begin
    if (reset) begin
        lfsr_reg <= 4'hE;
    end else begin
        lfsr_reg <= {lfsr_reg[2:0], feedback};
    end
end

assign lfsr_o = lfsr_reg;

endmodule
