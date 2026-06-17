module serial_in_parallel_out (
    input wire clock,          // Clock input
    input wire reset,          // Reset input
    input wire serial_in,     // Serial input
    output wire [7:0] parallel_out // Parallel output
);

reg [7:0] shift_reg;

always @(posedge clock) begin
    if (reset) begin
        shift_reg <= 8'b00000000;
    end else begin
        shift_reg <= {shift_reg[6:0], serial_in};
    end
end

assign parallel_out = shift_reg;

endmodule
