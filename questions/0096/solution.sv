module vlan_detector (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [15:0] in_ethertype,
    input  wire [15:0] in_tci,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_is_tagged,
    output wire [2:0]  out_pcp,
    output wire        out_dei,
    output wire [11:0] out_vid
);

    localparam VLAN_TPID = 16'h8100;

    // State machine
    localparam IDLE   = 1'd0;
    localparam OUTPUT = 1'd1;

    reg state, next_state;

    // Result registers
    reg is_tagged_reg;
    reg [2:0] pcp_reg;
    reg dei_reg;
    reg [11:0] vid_reg;

    // State transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (in_valid && in_ready)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
        endcase
    end

    // Detection and extraction
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            is_tagged_reg <= 1'b0;
            pcp_reg <= 3'd0;
            dei_reg <= 1'b0;
            vid_reg <= 12'd0;
        end else if (state == IDLE && in_valid && in_ready) begin
            if (in_ethertype == VLAN_TPID) begin
                is_tagged_reg <= 1'b1;
                pcp_reg <= in_tci[15:13];
                dei_reg <= in_tci[12];
                vid_reg <= in_tci[11:0];
            end else begin
                is_tagged_reg <= 1'b0;
                pcp_reg <= 3'd0;
                dei_reg <= 1'b0;
                vid_reg <= 12'd0;
            end
        end
    end

    // Output assignments
    assign in_ready     = (state == IDLE);
    assign out_valid    = (state == OUTPUT);
    assign out_is_tagged = is_tagged_reg;
    assign out_pcp      = pcp_reg;
    assign out_dei      = dei_reg;
    assign out_vid      = vid_reg;

endmodule
