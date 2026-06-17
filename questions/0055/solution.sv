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
    output reg  [NUM_MASTERS-1:0]            gnt,
    output wire [NUM_MASTERS*DATA_WIDTH-1:0] gnt_rdata,
    output reg  [NUM_MASTERS-1:0]            gnt_rvalid
);

    // Internal signals for memory interface
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Instantiate the SRAM model (defined in tb.sv)
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

    // Internal signals
    integer i;
    reg [$clog2(NUM_MASTERS)-1:0] selected_master;
    reg                           has_request;
    reg                           pending_read;
    reg [$clog2(NUM_MASTERS)-1:0] pending_master;
    reg [DATA_WIDTH-1:0]          rdata_reg [0:NUM_MASTERS-1];

    // Priority encoder - find highest priority requester
    always @(*) begin
        selected_master = 0;
        has_request = 1'b0;
        for (i = 0; i < NUM_MASTERS; i = i + 1) begin
            if (req[i] && !has_request) begin
                selected_master = i;
                has_request = 1'b1;
            end
        end
    end

    // Main arbiter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gnt          <= {NUM_MASTERS{1'b0}};
            gnt_rvalid   <= {NUM_MASTERS{1'b0}};
            mem_req      <= 1'b0;
            mem_wr       <= 1'b0;
            mem_addr     <= {ADDR_WIDTH{1'b0}};
            mem_wdata    <= {DATA_WIDTH{1'b0}};
            pending_read <= 1'b0;
            pending_master <= 0;
            for (i = 0; i < NUM_MASTERS; i = i + 1) begin
                rdata_reg[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            gnt        <= {NUM_MASTERS{1'b0}};
            gnt_rvalid <= {NUM_MASTERS{1'b0}};
            mem_req    <= 1'b0;

            // Handle pending read response
            if (mem_rvalid && pending_read) begin
                gnt_rvalid[pending_master] <= 1'b1;
                rdata_reg[pending_master]  <= mem_rdata;
                pending_read <= 1'b0;
            end

            // Issue new request if no pending read
            if (has_request && !pending_read) begin
                mem_req   <= 1'b1;
                mem_addr  <= req_addr[selected_master*ADDR_WIDTH +: ADDR_WIDTH];
                mem_wr    <= req_wr[selected_master];
                mem_wdata <= req_wdata[selected_master*DATA_WIDTH +: DATA_WIDTH];

                if (req_wr[selected_master]) begin
                    gnt[selected_master] <= 1'b1;
                end else begin
                    pending_read   <= 1'b1;
                    pending_master <= selected_master;
                    gnt[selected_master] <= 1'b1;
                end
            end
        end
    end

    // Read data output
    genvar g;
    generate
        for (g = 0; g < NUM_MASTERS; g = g + 1) begin : gen_rdata
            assign gnt_rdata[g*DATA_WIDTH +: DATA_WIDTH] = rdata_reg[g];
        end
    endgenerate

endmodule
