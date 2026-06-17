module counter_manager #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  cmd_valid,
    input  wire [1:0]            cmd_op,
    input  wire [ADDR_WIDTH-1:0] cmd_addr,
    input  wire [DATA_WIDTH-1:0] cmd_wdata,
    output wire                  cmd_ready,
    output wire                  resp_valid,
    output wire [DATA_WIDTH-1:0] resp_data
);

    // Memory interface signals
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Instantiate SRAM model (defined in tb.sv)
    sram_rw_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
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
