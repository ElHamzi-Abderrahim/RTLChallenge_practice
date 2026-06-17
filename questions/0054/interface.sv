module lut_interpolator #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter FRAC_BITS  = 4
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire                           start,
    input  wire [ADDR_WIDTH+FRAC_BITS-1:0] phase,
    output wire                           done,
    output wire [DATA_WIDTH-1:0]          result
);

    // Internal signals for ROM interface
    reg                   rom_rd_en;
    reg  [ADDR_WIDTH-1:0] rom_addr;
    wire [DATA_WIDTH-1:0] rom_rdata;

    // You MUST instantiate the ROM model (defined in tb.sv)
    rom_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rom (
        .clk(clk),
        .rd_en(rom_rd_en),
        .addr(rom_addr),
        .rdata(rom_rdata)
    );

    // your implementation here

endmodule
