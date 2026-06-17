module parallel_to_serial (
  input     wire      clk,
  input     wire      reset,

  output    wire      empty_o,
  input     wire[3:0] parallel_i,

  output    wire      serial_o,
  output    wire      valid_o
);

reg [3:0] shift_reg;
reg [2:0] bit_count;
reg busy;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        shift_reg <= 4'h0;
        bit_count <= 3'h0;
        busy <= 1'b0;
    end else if (!busy) begin
        shift_reg <= parallel_i;
        bit_count <= 3'h0;
        busy <= 1'b1;
    end else begin
        shift_reg <= {1'b0, shift_reg[3:1]};
        bit_count <= bit_count + 1'b1;
        if (bit_count == 3'h3) begin
            busy <= 1'b0;
        end
    end
end

assign empty_o = !busy;
assign valid_o = busy;
assign serial_o = shift_reg[0];

endmodule
