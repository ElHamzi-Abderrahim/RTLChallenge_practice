module mem_arbiter #(
    parameter NUM_MASTERS = 4,
    parameter ADDR_WIDTH  = 8,
    parameter DATA_WIDTH  = 8
)(
    input  wire                              clk,
    input  wire                              rst_n,

    // Master request interface
    input  wire [NUM_MASTERS-1:0]            req,
    input  wire [NUM_MASTERS-1:0]            req_wr,
    input  wire [NUM_MASTERS*ADDR_WIDTH-1:0] req_addr,
    input  wire [NUM_MASTERS*DATA_WIDTH-1:0] req_wdata,

    // Master grant interface
    output wire [NUM_MASTERS-1:0]            gnt,
    output wire [NUM_MASTERS*DATA_WIDTH-1:0] gnt_rdata,
    output wire [NUM_MASTERS-1:0]            gnt_rvalid
);

    // Internal signals for memory interface
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // You MUST instantiate the SRAM model (defined in tb.sv)
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
