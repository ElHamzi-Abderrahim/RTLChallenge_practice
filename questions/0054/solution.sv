module lut_interpolator #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter FRAC_BITS  = 4
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire                           start,
    input  wire [ADDR_WIDTH+FRAC_BITS-1:0] phase,
    output reg                            done,
    output reg  [DATA_WIDTH-1:0]          result
);

    // Internal signals for ROM interface
    reg                   rom_rd_en;
    reg  [ADDR_WIDTH-1:0] rom_addr;
    wire [DATA_WIDTH-1:0] rom_rdata;

    // Instantiate the ROM model (defined in tb.sv)
    rom_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rom (
        .clk(clk),
        .rd_en(rom_rd_en),
        .addr(rom_addr),
        .rdata(rom_rdata)
    );

    // State machine
    localparam IDLE     = 3'b000;
    localparam READ_Y0  = 3'b001;
    localparam READ_Y1  = 3'b010;
    localparam COMPUTE  = 3'b011;
    localparam DONE_ST  = 3'b100;

    reg [2:0] state;
    reg [ADDR_WIDTH-1:0] addr_int;
    reg [FRAC_BITS-1:0]  frac;
    reg [DATA_WIDTH-1:0] y0;
    reg [DATA_WIDTH-1:0] y1;

    // Interpolation computation
    wire signed [DATA_WIDTH:0] diff;
    wire signed [DATA_WIDTH+FRAC_BITS:0] product;
    wire [DATA_WIDTH-1:0] interp_result;

    assign diff = {1'b0, y1} - {1'b0, y0};
    assign product = diff * $signed({1'b0, frac});
    assign interp_result = y0 + product[DATA_WIDTH+FRAC_BITS-1:FRAC_BITS];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            rom_addr  <= {ADDR_WIDTH{1'b0}};
            rom_rd_en <= 1'b0;
            done      <= 1'b0;
            result    <= {DATA_WIDTH{1'b0}};
            addr_int  <= {ADDR_WIDTH{1'b0}};
            frac      <= {FRAC_BITS{1'b0}};
            y0        <= {DATA_WIDTH{1'b0}};
            y1        <= {DATA_WIDTH{1'b0}};
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        addr_int  <= phase[ADDR_WIDTH+FRAC_BITS-1:FRAC_BITS];
                        frac      <= phase[FRAC_BITS-1:0];
                        rom_addr  <= phase[ADDR_WIDTH+FRAC_BITS-1:FRAC_BITS];
                        rom_rd_en <= 1'b1;
                        state     <= READ_Y0;
                    end
                end

                READ_Y0: begin
                    y0        <= rom_rdata;
                    rom_addr  <= addr_int + 1'b1;
                    state     <= READ_Y1;
                end

                READ_Y1: begin
                    y1        <= rom_rdata;
                    rom_rd_en <= 1'b0;
                    state     <= COMPUTE;
                end

                COMPUTE: begin
                    result <= interp_result;
                    state  <= DONE_ST;
                    done   <= 1'b1;
                end

                DONE_ST: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
