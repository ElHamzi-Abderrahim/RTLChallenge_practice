module thermometer_to_binary #(
    parameter THERMO_WIDTH = 7,
    parameter BINARY_WIDTH = 3
)(
    input  wire [THERMO_WIDTH-1:0]     thermo_in,
    output wire [BINARY_WIDTH-1:0]     binary_out,
    output wire                        valid
);

    integer i;
    reg [BINARY_WIDTH-1:0] count;
    reg is_valid;
    reg found_zero;
    
    always @(*) begin
        count = {BINARY_WIDTH{1'b0}};
        is_valid = 1'b1;
        found_zero = 1'b0;
        
        // Count the number of 1s and validate thermometer code
        for (i = 0; i < THERMO_WIDTH; i = i + 1) begin
            if (thermo_in[i] == 1'b1) begin
                if (found_zero) begin
                    // Found a 1 after a 0 - invalid thermometer code
                    is_valid = 1'b0;
                end
                count = count + 1'b1;
            end else begin
                found_zero = 1'b1;
            end
        end
    end
    
    assign binary_out = count;
    assign valid = is_valid;

endmodule
