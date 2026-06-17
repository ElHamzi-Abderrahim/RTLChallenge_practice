module mem_read_ctrl #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] num_reads,
    output wire                  done,
    output wire [DATA_WIDTH-1:0] checksum
);

    // Internal signals for memory interface
    reg                   mem_rd_en;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // You MUST instantiate the SRAM model (defined in tb.sv)
    sram_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_sram (
        .clk(clk),
        .rd_en(mem_rd_en),
        .addr(mem_addr),
        .rdata(mem_rdata),
        .rvalid(mem_rvalid)
    );

    // your implementation here

endmodule
