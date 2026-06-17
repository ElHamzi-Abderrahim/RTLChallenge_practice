module barrel_shifter #(
    parameter DATA_WIDTH = 8,
    parameter SHIFT_WIDTH = 3
)(
    input  wire [DATA_WIDTH-1:0]     data_in,
    input  wire [SHIFT_WIDTH-1:0]    shift_amt,
    input  wire                      shift_dir,
    input  wire                      shift_type,
    output wire [DATA_WIDTH-1:0]     data_out
);

    reg [DATA_WIDTH-1:0] shifted_data;
    reg [SHIFT_WIDTH-1:0] eff_shift;
    integer i;

    always @(*) begin
        eff_shift = shift_amt % DATA_WIDTH;

        if (shift_dir == 1'b0) begin
            // Left shift/rotate
            if (shift_type == 1'b0) begin
                // Logical left shift
                shifted_data = data_in << shift_amt;
            end else begin
                // Left rotate
                if (eff_shift == 0)
                    shifted_data = data_in;
                else
                    shifted_data = (data_in << eff_shift) | (data_in >> (DATA_WIDTH - eff_shift));
            end
        end else begin
            // Right shift/rotate
            if (shift_type == 1'b0) begin
                // Logical right shift
                shifted_data = data_in >> shift_amt;
            end else begin
                // Right rotate
                if (eff_shift == 0)
                    shifted_data = data_in;
                else
                    shifted_data = (data_in >> eff_shift) | (data_in << (DATA_WIDTH - eff_shift));
            end
        end
    end
    
    assign data_out = shifted_data;

endmodule
