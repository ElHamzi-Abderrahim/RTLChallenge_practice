module Universal_Shift_Register (
  input wire clk,        // Clock input
  input wire reset,      // Reset input
  input wire load,       // Load input
  input wire shift_left, // Shift left input
  input wire shift_right, // Shift right input
  input wire serial_in,  // Serial input
  input wire enable,     // Enable input
  output wire [3:0] q    // 4-bit output
);

reg [3:0] shift_reg;

always @(posedge clk) begin
    if (reset) begin
        shift_reg <= 4'b0000;
    end else if (load) begin
        shift_reg <= {3'b000, serial_in};
    end else if (enable) begin
        if (shift_left) begin
            shift_reg <= {shift_reg[2:0], shift_reg[3]};  // Circular shift left
        end else if (shift_right) begin
            shift_reg <= {shift_reg[0], shift_reg[3:1]};  // Circular shift right
        end
    end
end

assign q = shift_reg;

endmodule
