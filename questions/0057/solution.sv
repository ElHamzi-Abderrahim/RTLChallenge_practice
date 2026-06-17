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
    output reg                       ready,
    output reg                       read_valid,
    output reg  [COUNT_WIDTH-1:0]    read_data
);

    localparam NUM_BINS = (1 << BIN_ADDR_WIDTH);
    localparam MAX_COUNT = {COUNT_WIDTH{1'b1}};

    // States
    localparam IDLE      = 3'b000;
    localparam CLEARING  = 3'b001;
    localparam INC_READ  = 3'b010;
    localparam INC_WAIT  = 3'b011;
    localparam INC_WRITE = 3'b100;
    localparam DO_READ   = 3'b101;
    localparam READ_WAIT = 3'b110;

    reg [2:0] state;

    // Memory interface
    reg                      mem_req;
    reg                      mem_wr;
    reg  [BIN_ADDR_WIDTH-1:0] mem_addr;
    reg  [COUNT_WIDTH-1:0]    mem_wdata;
    wire [COUNT_WIDTH-1:0]    mem_rdata;
    wire                      mem_rvalid;

    // Internal registers
    reg [BIN_ADDR_WIDTH-1:0] clear_addr;
    reg [BIN_ADDR_WIDTH-1:0] target_addr;
    reg                      is_read_op;

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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            ready      <= 1'b1;
            read_valid <= 1'b0;
            read_data  <= {COUNT_WIDTH{1'b0}};
            mem_req    <= 1'b0;
            mem_wr     <= 1'b0;
            mem_addr   <= {BIN_ADDR_WIDTH{1'b0}};
            mem_wdata  <= {COUNT_WIDTH{1'b0}};
            clear_addr <= {BIN_ADDR_WIDTH{1'b0}};
            target_addr <= {BIN_ADDR_WIDTH{1'b0}};
            is_read_op <= 1'b0;
        end else begin
            read_valid <= 1'b0;
            mem_req    <= 1'b0;

            case (state)
                IDLE: begin
                    ready <= 1'b1;
                    if (clear) begin
                        ready      <= 1'b0;
                        clear_addr <= {BIN_ADDR_WIDTH{1'b0}};
                        mem_req    <= 1'b1;
                        mem_wr     <= 1'b1;
                        mem_addr   <= {BIN_ADDR_WIDTH{1'b0}};
                        mem_wdata  <= {COUNT_WIDTH{1'b0}};
                        state      <= CLEARING;
                    end else if (data_valid) begin
                        ready       <= 1'b0;
                        target_addr <= data_in;
                        is_read_op  <= 1'b0;
                        mem_req     <= 1'b1;
                        mem_wr      <= 1'b0;
                        mem_addr    <= data_in;
                        state       <= INC_READ;
                    end else if (read_req) begin
                        ready       <= 1'b0;
                        target_addr <= read_addr;
                        is_read_op  <= 1'b1;
                        mem_req     <= 1'b1;
                        mem_wr      <= 1'b0;
                        mem_addr    <= read_addr;
                        state       <= DO_READ;
                    end
                end

                CLEARING: begin
                    if (clear_addr == NUM_BINS - 1) begin
                        state <= IDLE;
                    end else begin
                        clear_addr <= clear_addr + 1'b1;
                        mem_req    <= 1'b1;
                        mem_wr     <= 1'b1;
                        mem_addr   <= clear_addr + 1'b1;
                        mem_wdata  <= {COUNT_WIDTH{1'b0}};
                    end
                end

                INC_READ: begin
                    state <= INC_WAIT;
                end

                INC_WAIT: begin
                    if (mem_rvalid) begin
                        mem_req   <= 1'b1;
                        mem_wr    <= 1'b1;
                        mem_addr  <= target_addr;
                        // Saturation
                        if (mem_rdata == MAX_COUNT) begin
                            mem_wdata <= MAX_COUNT;
                        end else begin
                            mem_wdata <= mem_rdata + 1'b1;
                        end
                        state <= INC_WRITE;
                    end
                end

                INC_WRITE: begin
                    state <= IDLE;
                end

                DO_READ: begin
                    state <= READ_WAIT;
                end

                READ_WAIT: begin
                    if (mem_rvalid) begin
                        read_valid <= 1'b1;
                        read_data  <= mem_rdata;
                        state      <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
