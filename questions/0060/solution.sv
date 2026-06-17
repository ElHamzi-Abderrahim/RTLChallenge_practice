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
    output reg                   busy,
    output reg                   done,
    output reg  [DATA_WIDTH-1:0] max_val,
    output reg  [ADDR_WIDTH-1:0] max_idx
);

    // States
    localparam IDLE     = 3'b000;
    localparam READ     = 3'b001;
    localparam WAIT     = 3'b010;
    localparam COMPARE  = 3'b011;
    localparam DONE_ST  = 3'b100;

    reg [2:0] state;

    // Memory interface
    reg                   mem_rd_en;
    reg                   mem_wr_en;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Latched parameters
    reg [ADDR_WIDTH-1:0] count_r;
    reg [ADDR_WIDTH-1:0] current_idx;
    reg [DATA_WIDTH-1:0] current_max;
    reg [ADDR_WIDTH-1:0] current_max_idx;

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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= IDLE;
            busy            <= 1'b0;
            done            <= 1'b0;
            max_val         <= {DATA_WIDTH{1'b0}};
            max_idx         <= {ADDR_WIDTH{1'b0}};
            mem_rd_en       <= 1'b0;
            mem_wr_en       <= 1'b0;
            mem_addr        <= {ADDR_WIDTH{1'b0}};
            mem_wdata       <= {DATA_WIDTH{1'b0}};
            count_r         <= {ADDR_WIDTH{1'b0}};
            current_idx     <= {ADDR_WIDTH{1'b0}};
            current_max     <= {DATA_WIDTH{1'b0}};
            current_max_idx <= {ADDR_WIDTH{1'b0}};
        end else begin
            done      <= 1'b0;
            mem_rd_en <= 1'b0;
            mem_wr_en <= 1'b0;

            case (state)
                IDLE: begin
                    busy <= 1'b0;

                    // Handle writes when idle
                    if (write_en) begin
                        mem_wr_en <= 1'b1;
                        mem_addr  <= write_addr;
                        mem_wdata <= write_data;
                    end

                    if (start) begin
                        busy <= 1'b1;
                        count_r <= count;
                        current_idx <= {ADDR_WIDTH{1'b0}};
                        current_max <= {DATA_WIDTH{1'b0}};
                        current_max_idx <= {ADDR_WIDTH{1'b0}};

                        if (count == 0) begin
                            max_val <= {DATA_WIDTH{1'b0}};
                            max_idx <= {ADDR_WIDTH{1'b0}};
                            state   <= DONE_ST;
                        end else begin
                            mem_rd_en <= 1'b1;
                            mem_addr  <= {ADDR_WIDTH{1'b0}};
                            state     <= READ;
                        end
                    end
                end

                READ: begin
                    state <= WAIT;
                end

                WAIT: begin
                    if (mem_rvalid) begin
                        state <= COMPARE;
                    end
                end

                COMPARE: begin
                    // Compare with current max
                    if (mem_rdata > current_max) begin
                        current_max     <= mem_rdata;
                        current_max_idx <= current_idx;
                    end

                    current_idx <= current_idx + 1'b1;

                    if (current_idx + 1'b1 >= count_r) begin
                        // Done - output final result
                        if (mem_rdata > current_max) begin
                            max_val <= mem_rdata;
                            max_idx <= current_idx;
                        end else begin
                            max_val <= current_max;
                            max_idx <= current_max_idx;
                        end
                        state <= DONE_ST;
                    end else begin
                        // Read next value
                        mem_rd_en <= 1'b1;
                        mem_addr  <= current_idx + 1'b1;
                        state     <= READ;
                    end
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
