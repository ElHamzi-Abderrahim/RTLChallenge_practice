module mac_filter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [47:0] cfg_mac,
    input  wire        cfg_promisc,
    input  wire        in_valid,
    input  wire [47:0] in_dst_mac,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_accept,
    output wire [2:0]  out_reason
);

    // Reason codes
    localparam REASON_REJECT     = 3'd0;
    localparam REASON_UNICAST    = 3'd1;
    localparam REASON_BROADCAST  = 3'd2;
    localparam REASON_MULTICAST  = 3'd3;
    localparam REASON_PROMISC    = 3'd4;

    // State machine
    localparam IDLE   = 1'd0;
    localparam OUTPUT = 1'd1;

    reg state, next_state;

    // Result registers
    reg accept_reg;
    reg [2:0] reason_reg;

    // Detection signals
    wire is_broadcast;
    wire is_multicast;
    wire is_unicast_match;

    assign is_broadcast    = (in_dst_mac == 48'hFFFFFFFFFFFF);
    assign is_multicast    = in_dst_mac[40];  // LSB of first byte
    assign is_unicast_match = (in_dst_mac == cfg_mac);

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

    // Filter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accept_reg <= 1'b0;
            reason_reg <= REASON_REJECT;
        end else if (state == IDLE && in_valid && in_ready) begin
            if (cfg_promisc) begin
                accept_reg <= 1'b1;
                reason_reg <= REASON_PROMISC;
            end else if (is_broadcast) begin
                accept_reg <= 1'b1;
                reason_reg <= REASON_BROADCAST;
            end else if (is_multicast) begin
                accept_reg <= 1'b1;
                reason_reg <= REASON_MULTICAST;
            end else if (is_unicast_match) begin
                accept_reg <= 1'b1;
                reason_reg <= REASON_UNICAST;
            end else begin
                accept_reg <= 1'b0;
                reason_reg <= REASON_REJECT;
            end
        end
    end

    // Output assignments
    assign in_ready   = (state == IDLE);
    assign out_valid  = (state == OUTPUT);
    assign out_accept = accept_reg;
    assign out_reason = reason_reg;

endmodule
