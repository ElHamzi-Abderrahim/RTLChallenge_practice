module UpDownCounter (
    input wire clk,         // Clock input
    input wire rst,         // Reset input
    input wire up_down,    // Up/Down control input
    output reg [3:0] count // 4-bit counter output
);

always @(posedge clk) begin
    if (rst) begin
        count <= 4'b0000;
    end else begin
        if (up_down) begin
            // Count up with saturation at 15
            if (count < 4'b1111) begin
                count <= count + 1'b1;
            end
        end else begin
            // Count down with saturation at 0
            if (count > 4'b0000) begin
                count <= count - 1'b1;
            end
        end
    end
end

endmodule
