module pkt_len_validator (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_last,
    input  wire [15:0] hdr_total_len,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_len_ok,
    output wire [15:0] out_actual_len
);

    // State machine
    localparam IDLE   = 2'd0;
    localparam COUNT  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;

    // Byte counter
    reg [15:0] byte_count;
    reg [15:0] expected_len;

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
                if (start)
                    next_state = COUNT;
            end
            COUNT: begin
                if (in_valid && in_ready && in_last)
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
            byte_count <= 16'd0;
            expected_len <= 16'd0;
        end else if (start) begin
            byte_count <= 16'd0;
            expected_len <= hdr_total_len;
        end else if (state == COUNT && in_valid && in_ready) begin
            byte_count <= byte_count + 1;
        end
    end

    // Output assignments
    assign in_ready      = (state == COUNT);
    assign out_valid     = (state == OUTPUT);
    assign out_len_ok    = (byte_count == expected_len);
    assign out_actual_len = byte_count;

endmodule
