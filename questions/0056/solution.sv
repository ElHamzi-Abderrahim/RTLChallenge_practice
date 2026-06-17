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
    output reg                   cmd_ready,
    output reg                   resp_valid,
    output reg  [DATA_WIDTH-1:0] resp_data
);

    // Operation codes
    localparam OP_NOP   = 2'b00;
    localparam OP_INC   = 2'b01;
    localparam OP_READ  = 2'b10;
    localparam OP_WRITE = 2'b11;

    // State machine
    localparam IDLE       = 3'b000;
    localparam DO_WRITE   = 3'b001;
    localparam DO_READ    = 3'b010;
    localparam WAIT_READ  = 3'b011;
    localparam DO_INC_WR  = 3'b100;
    localparam DONE       = 3'b101;

    reg [2:0] state;

    // Memory interface signals
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Latched command
    reg [1:0]            cmd_op_r;
    reg [ADDR_WIDTH-1:0] cmd_addr_r;
    reg [DATA_WIDTH-1:0] cmd_wdata_r;

    // Instantiate SRAM model
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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            cmd_ready  <= 1'b1;
            resp_valid <= 1'b0;
            resp_data  <= {DATA_WIDTH{1'b0}};
            mem_req    <= 1'b0;
            mem_wr     <= 1'b0;
            mem_addr   <= {ADDR_WIDTH{1'b0}};
            mem_wdata  <= {DATA_WIDTH{1'b0}};
            cmd_op_r   <= 2'b00;
            cmd_addr_r <= {ADDR_WIDTH{1'b0}};
            cmd_wdata_r <= {DATA_WIDTH{1'b0}};
        end else begin
            resp_valid <= 1'b0;
            mem_req    <= 1'b0;

            case (state)
                IDLE: begin
                    cmd_ready <= 1'b1;
                    if (cmd_valid && cmd_ready) begin
                        cmd_op_r    <= cmd_op;
                        cmd_addr_r  <= cmd_addr;
                        cmd_wdata_r <= cmd_wdata;
                        cmd_ready   <= 1'b0;

                        case (cmd_op)
                            OP_NOP: begin
                                state <= DONE;
                            end
                            OP_WRITE: begin
                                mem_req   <= 1'b1;
                                mem_wr    <= 1'b1;
                                mem_addr  <= cmd_addr;
                                mem_wdata <= cmd_wdata;
                                state     <= DO_WRITE;
                            end
                            OP_READ: begin
                                mem_req  <= 1'b1;
                                mem_wr   <= 1'b0;
                                mem_addr <= cmd_addr;
                                state    <= DO_READ;
                            end
                            OP_INC: begin
                                mem_req  <= 1'b1;
                                mem_wr   <= 1'b0;
                                mem_addr <= cmd_addr;
                                state    <= DO_READ;
                            end
                        endcase
                    end
                end

                DO_WRITE: begin
                    state <= DONE;
                end

                DO_READ: begin
                    state <= WAIT_READ;
                end

                WAIT_READ: begin
                    if (mem_rvalid) begin
                        if (cmd_op_r == OP_READ) begin
                            resp_valid <= 1'b1;
                            resp_data  <= mem_rdata;
                            state      <= DONE;
                        end else begin
                            // INCREMENT: write back incremented value
                            mem_req   <= 1'b1;
                            mem_wr    <= 1'b1;
                            mem_addr  <= cmd_addr_r;
                            mem_wdata <= mem_rdata + 1'b1;
                            state     <= DO_INC_WR;
                        end
                    end
                end

                DO_INC_WR: begin
                    state <= DONE;
                end

                DONE: begin
                    cmd_ready <= 1'b1;
                    state     <= IDLE;
                end
            endcase
        end
    end

endmodule
