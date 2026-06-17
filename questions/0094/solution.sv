module arp_detector (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_sof,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_is_request,
    output wire [31:0] out_sender_ip,
    output wire [31:0] out_target_ip
);

    // State machine
    localparam IDLE   = 2'd0;
    localparam PARSE  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;

    // Byte counter
    reg [4:0] byte_cnt;

    // Extracted fields
    reg [15:0] operation;
    reg [31:0] sender_ip_reg;
    reg [31:0] target_ip_reg;

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
                if (in_valid && in_ready && byte_cnt == 5'd27)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
        endcase
    end

    // Byte counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_cnt <= 5'd0;
        end else if (state == IDLE && in_valid && in_ready && in_sof) begin
            byte_cnt <= 5'd1;
        end else if (state == PARSE && in_valid && in_ready) begin
            byte_cnt <= byte_cnt + 1;
        end else if (state == OUTPUT && out_valid && out_ready) begin
            byte_cnt <= 5'd0;
        end
    end

    // Parse fields
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            operation <= 16'd0;
            sender_ip_reg <= 32'd0;
            target_ip_reg <= 32'd0;
        end else if (in_valid && in_ready) begin
            case (byte_cnt)
                // Operation code
                5'd6:  operation[15:8] <= in_data;
                5'd7:  operation[7:0]  <= in_data;
                // Sender IP (bytes 14-17)
                5'd14: sender_ip_reg[31:24] <= in_data;
                5'd15: sender_ip_reg[23:16] <= in_data;
                5'd16: sender_ip_reg[15:8]  <= in_data;
                5'd17: sender_ip_reg[7:0]   <= in_data;
                // Target IP (bytes 24-27)
                5'd24: target_ip_reg[31:24] <= in_data;
                5'd25: target_ip_reg[23:16] <= in_data;
                5'd26: target_ip_reg[15:8]  <= in_data;
                5'd27: target_ip_reg[7:0]   <= in_data;
            endcase
        end
    end

    // Output assignments
    assign in_ready      = (state == IDLE) || (state == PARSE);
    assign out_valid     = (state == OUTPUT);
    assign out_is_request = (operation == 16'h0001);
    assign out_sender_ip = sender_ip_reg;
    assign out_target_ip = target_ip_reg;

endmodule
