module scratchpad_acc #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] src_addr,
    input  wire [ADDR_WIDTH-1:0] count,
    input  wire [ADDR_WIDTH-1:0] dst_addr,
    output reg                   busy,
    output reg                   done,
    output reg  [DATA_WIDTH-1:0] result
);

    // States
    localparam IDLE      = 3'b000;
    localparam READ      = 3'b001;
    localparam WAIT_READ = 3'b010;
    localparam WRITE_RES = 3'b011;
    localparam DONE_ST   = 3'b100;

    reg [2:0] state;

    // Memory interface
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Latched parameters
    reg [ADDR_WIDTH-1:0] src_addr_r;
    reg [ADDR_WIDTH-1:0] count_r;
    reg [ADDR_WIDTH-1:0] dst_addr_r;
    reg [ADDR_WIDTH-1:0] offset;
    reg [DATA_WIDTH-1:0] accumulator;

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
            state       <= IDLE;
            busy        <= 1'b0;
            done        <= 1'b0;
            result      <= {DATA_WIDTH{1'b0}};
            mem_req     <= 1'b0;
            mem_wr      <= 1'b0;
            mem_addr    <= {ADDR_WIDTH{1'b0}};
            mem_wdata   <= {DATA_WIDTH{1'b0}};
            src_addr_r  <= {ADDR_WIDTH{1'b0}};
            count_r     <= {ADDR_WIDTH{1'b0}};
            dst_addr_r  <= {ADDR_WIDTH{1'b0}};
            offset      <= {ADDR_WIDTH{1'b0}};
            accumulator <= {DATA_WIDTH{1'b0}};
        end else begin
            done    <= 1'b0;
            mem_req <= 1'b0;

            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy        <= 1'b1;
                        src_addr_r  <= src_addr;
                        count_r     <= count;
                        dst_addr_r  <= dst_addr;
                        offset      <= {ADDR_WIDTH{1'b0}};
                        accumulator <= {DATA_WIDTH{1'b0}};

                        if (count == 0) begin
                            // Edge case: count=0, write 0
                            result    <= {DATA_WIDTH{1'b0}};
                            mem_req   <= 1'b1;
                            mem_wr    <= 1'b1;
                            mem_addr  <= dst_addr;
                            mem_wdata <= {DATA_WIDTH{1'b0}};
                            state     <= WRITE_RES;
                        end else begin
                            // Start first read
                            mem_req  <= 1'b1;
                            mem_wr   <= 1'b0;
                            mem_addr <= src_addr;
                            state    <= READ;
                        end
                    end
                end

                READ: begin
                    state <= WAIT_READ;
                end

                WAIT_READ: begin
                    if (mem_rvalid) begin
                        accumulator <= accumulator + mem_rdata;
                        offset      <= offset + 1'b1;

                        if (offset + 1'b1 >= count_r) begin
                            // All values read, write result
                            result    <= accumulator + mem_rdata;
                            mem_req   <= 1'b1;
                            mem_wr    <= 1'b1;
                            mem_addr  <= dst_addr_r;
                            mem_wdata <= accumulator + mem_rdata;
                            state     <= WRITE_RES;
                        end else begin
                            // Read next value
                            mem_req  <= 1'b1;
                            mem_wr   <= 1'b0;
                            mem_addr <= src_addr_r + offset + 1'b1;
                            state    <= READ;
                        end
                    end
                end

                WRITE_RES: begin
                    state <= DONE_ST;
                end

                DONE_ST: begin
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
