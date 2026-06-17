module crc_calculator #(
    parameter CRC_WIDTH = 8,
    parameter POLYNOMIAL = 8'h07
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      data_valid,
    input  wire [7:0]                data_in,
    input  wire                      start,
    output wire [CRC_WIDTH-1:0]      crc_out,
    output wire                      crc_valid
);

    reg [CRC_WIDTH-1:0] crc_reg;
    reg crc_valid_reg;
    reg [CRC_WIDTH-1:0] crc_temp;
    integer i;

    always @(posedge clk) begin
        if (reset || start) begin
            crc_reg <= {CRC_WIDTH{1'b0}};
            crc_valid_reg <= 1'b0;
        end else if (data_valid) begin
            // XOR input byte with current CRC (standard CRC algorithm)
            crc_temp = crc_reg ^ data_in;

            // Process 8 bit shifts
            for (i = 0; i < 8; i = i + 1) begin
                if (crc_temp[CRC_WIDTH-1]) begin
                    crc_temp = (crc_temp << 1) ^ POLYNOMIAL;
                end else begin
                    crc_temp = crc_temp << 1;
                end
            end

            // Assign result to register
            crc_reg <= crc_temp;
            crc_valid_reg <= 1'b1;
        end
    end
    
    assign crc_out = crc_reg;
    assign crc_valid = crc_valid_reg;

endmodule
