module mem_read_ctrl #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] num_reads,
    output reg                   done,
    output reg  [DATA_WIDTH-1:0] checksum
);

    // Internal signals for memory interface
    reg                   mem_rd_en;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Instantiate the SRAM model (defined in tb.sv)
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

    // State machine
    localparam IDLE    = 2'b00;
    localparam READING = 2'b01;
    localparam DONE_ST = 2'b10;

    reg [1:0] state;
    reg [ADDR_WIDTH-1:0] addr_cnt;
    reg [ADDR_WIDTH-1:0] recv_cnt;
    reg [ADDR_WIDTH-1:0] num_reads_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            mem_addr      <= {ADDR_WIDTH{1'b0}};
            mem_rd_en     <= 1'b0;
            done          <= 1'b0;
            checksum      <= {DATA_WIDTH{1'b0}};
            addr_cnt      <= {ADDR_WIDTH{1'b0}};
            recv_cnt      <= {ADDR_WIDTH{1'b0}};
            num_reads_reg <= {ADDR_WIDTH{1'b0}};
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        state         <= READING;
                        num_reads_reg <= num_reads;
                        addr_cnt      <= {ADDR_WIDTH{1'b0}};
                        recv_cnt      <= {ADDR_WIDTH{1'b0}};
                        checksum      <= {DATA_WIDTH{1'b0}};
                        mem_addr      <= {ADDR_WIDTH{1'b0}};
                        mem_rd_en     <= 1'b1;
                    end
                end

                READING: begin
                    if (mem_rvalid) begin
                        checksum <= checksum ^ mem_rdata;
                        recv_cnt <= recv_cnt + 1'b1;
                    end

                    if (mem_rd_en) begin
                        if (addr_cnt + 1'b1 < num_reads_reg) begin
                            addr_cnt  <= addr_cnt + 1'b1;
                            mem_addr  <= addr_cnt + 1'b1;
                            mem_rd_en <= 1'b1;
                        end else begin
                            mem_rd_en <= 1'b0;
                        end
                    end

                    if (mem_rvalid && (recv_cnt + 1'b1 == num_reads_reg)) begin
                        state <= DONE_ST;
                        done  <= 1'b1;
                    end
                end

                DONE_ST: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
