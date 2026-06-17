module histogram_calc #(
    parameter BIN_ADDR_WIDTH = 4,
    parameter COUNT_WIDTH    = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      clear,
    input  wire                      data_valid,
    input  wire [BIN_ADDR_WIDTH-1:0] data_in,
    input  wire                      read_req,
    input  wire [BIN_ADDR_WIDTH-1:0] read_addr,
    output wire                      ready,
    output wire                      read_valid,
    output wire [COUNT_WIDTH-1:0]    read_data
);

    // Memory interface
    reg                      mem_req;
    reg                      mem_wr;
    reg  [BIN_ADDR_WIDTH-1:0] mem_addr;
    reg  [COUNT_WIDTH-1:0]    mem_wdata;
    wire [COUNT_WIDTH-1:0]    mem_rdata;
    wire                      mem_rvalid;

    sram_rw_model #(
        .ADDR_WIDTH(BIN_ADDR_WIDTH),
        .DATA_WIDTH(COUNT_WIDTH)
    ) u_sram (
        .clk(clk),
        .req(mem_req),
        .wr(mem_wr),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .rdata(mem_rdata),
        .rvalid(mem_rvalid)
    );

    // your implementation here

endmodule
