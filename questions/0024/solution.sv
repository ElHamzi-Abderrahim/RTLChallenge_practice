module binary_to_bcd #(
    parameter BINARY_WIDTH = 8,
    parameter BCD_DIGITS = 3,
    parameter BCD_WIDTH = 12
)(
    input  wire                         clk,
    input  wire                         reset,
    input  wire                         start,
    input  wire [BINARY_WIDTH-1:0]      binary_in,
    output wire [BCD_WIDTH-1:0]         bcd_out,
    output wire                         valid
);

reg [BCD_WIDTH-1:0] bcd_reg;
reg [BINARY_WIDTH-1:0] binary_reg;
reg [4:0] bit_count;
reg busy;
integer i;

always @(posedge clk) begin
    if (reset) begin
        bcd_reg <= {BCD_WIDTH{1'b0}};
        binary_reg <= {BINARY_WIDTH{1'b0}};
        bit_count <= 5'd0;
        busy <= 1'b0;
    end else if (start && !busy) begin
        bcd_reg <= {BCD_WIDTH{1'b0}};
        binary_reg <= binary_in;
        bit_count <= BINARY_WIDTH;
        busy <= 1'b1;
    end else if (busy) begin
        if (bit_count > 0) begin
            // Double Dabble (Shift and Add-3) algorithm for binary to BCD conversion
            // Add 3 to each BCD digit if >= 5
            for (i = 0; i < BCD_DIGITS; i = i + 1) begin
                if (bcd_reg[i*4 +: 4] >= 4'd5) begin
                    bcd_reg[i*4 +: 4] = bcd_reg[i*4 +: 4] + 4'd3;
                end
            end

            // Shift left
            bcd_reg <= {bcd_reg[BCD_WIDTH-2:0], binary_reg[BINARY_WIDTH-1]};
            binary_reg <= {binary_reg[BINARY_WIDTH-2:0], 1'b0};
            bit_count <= bit_count - 1'b1;
        end else begin
            busy <= 1'b0;
        end
    end
end

assign bcd_out = bcd_reg;
assign valid = !busy;

endmodule
