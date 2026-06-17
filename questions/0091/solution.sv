module eth_header_parser (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_sof,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire [47:0] out_dst_mac,
    output wire [47:0] out_src_mac,
    output wire [15:0] out_ethertype
);

    // State machine
    localparam IDLE   = 2'd0;
    localparam PARSE  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;

    // Byte counter (0-13 for 14 bytes)
    reg [3:0] byte_cnt;

    // Header fields
    reg [47:0] dst_mac_reg;
    reg [47:0] src_mac_reg;
    reg [15:0] ethertype_reg;

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
                if (in_valid && in_ready && in_sof)
                    next_state = PARSE;
            end
            PARSE: begin
                if (in_valid && in_ready && byte_cnt == 4'd13)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Byte counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_cnt <= 4'd0;
        end else if (state == IDLE && in_valid && in_ready && in_sof) begin
            byte_cnt <= 4'd1;  // First byte received
        end else if (state == PARSE && in_valid && in_ready) begin
            byte_cnt <= byte_cnt + 1;
        end else if (state == OUTPUT && out_valid && out_ready) begin
            byte_cnt <= 4'd0;
        end
    end

    // Parse header fields
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dst_mac_reg <= 48'd0;
            src_mac_reg <= 48'd0;
            ethertype_reg <= 16'd0;
        end else if (in_valid && in_ready) begin
            if (in_sof || state == PARSE) begin
                case (byte_cnt)
                    // First byte comes with SOF, byte_cnt will be 0
                    4'd0: dst_mac_reg[47:40] <= in_data;
                    4'd1: dst_mac_reg[39:32] <= in_data;
                    4'd2: dst_mac_reg[31:24] <= in_data;
                    4'd3: dst_mac_reg[23:16] <= in_data;
                    4'd4: dst_mac_reg[15:8]  <= in_data;
                    4'd5: dst_mac_reg[7:0]   <= in_data;
                    4'd6: src_mac_reg[47:40] <= in_data;
                    4'd7: src_mac_reg[39:32] <= in_data;
                    4'd8: src_mac_reg[31:24] <= in_data;
                    4'd9: src_mac_reg[23:16] <= in_data;
                    4'd10: src_mac_reg[15:8] <= in_data;
                    4'd11: src_mac_reg[7:0]  <= in_data;
                    4'd12: ethertype_reg[15:8] <= in_data;
                    4'd13: ethertype_reg[7:0]  <= in_data;
                endcase
            end
        end
    end

    // Output assignments
    assign in_ready     = (state == IDLE) || (state == PARSE);
    assign out_valid    = (state == OUTPUT);
    assign out_dst_mac  = dst_mac_reg;
    assign out_src_mac  = src_mac_reg;
    assign out_ethertype = ethertype_reg;

endmodule
