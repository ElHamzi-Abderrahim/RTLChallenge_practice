module regfile_max #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] count,
    input  wire                  write_en,
    input  wire [ADDR_WIDTH-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0] write_data,
    output wire                  busy,
    output wire                  done,
    output wire [DATA_WIDTH-1:0] max_val,
    output wire [ADDR_WIDTH-1:0] max_idx
);

    // Memory interface
    reg                   mem_rd_en;
    reg                   mem_wr_en;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    sram_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_sram (
        .clk(clk),
        .rd_en(mem_rd_en),
        .wr_en(mem_wr_en),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .rdata(mem_rdata),
        .rvalid(mem_rvalid)
    );

    // your implementation here

endmodule
