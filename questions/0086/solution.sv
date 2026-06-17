module hamming_dist #(
    parameter DATA_WIDTH = 8
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire                           in_valid,
    input  wire [DATA_WIDTH-1:0]          in_a,
    input  wire [DATA_WIDTH-1:0]          in_b,
    input  wire                           out_ready,
    output wire                           in_ready,
    output wire                           out_valid,
    output wire [$clog2(DATA_WIDTH+1)-1:0] out_dist
);

    localparam DIST_WIDTH = $clog2(DATA_WIDTH + 1);

    // State machine
    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam OUTPUT  = 2'd2;

    reg [1:0] state, next_state;

    // Registers
    reg [DATA_WIDTH-1:0] xor_result;
    reg [DIST_WIDTH-1:0] count;
    reg [$clog2(DATA_WIDTH+1)-1:0] bit_idx;

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
                    next_state = COMPUTE;
            end
            COMPUTE: begin
                if (bit_idx >= DATA_WIDTH)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // XOR and count
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xor_result <= {DATA_WIDTH{1'b0}};
            count <= {DIST_WIDTH{1'b0}};
            bit_idx <= 0;
        end else if (state == IDLE && in_valid && in_ready) begin
            xor_result <= in_a ^ in_b;
            count <= {DIST_WIDTH{1'b0}};
            bit_idx <= 0;
        end else if (state == COMPUTE && bit_idx < DATA_WIDTH) begin
            if (xor_result[bit_idx])
                count <= count + 1;
            bit_idx <= bit_idx + 1;
        end
    end

    // Output assignments
    assign in_ready  = (state == IDLE);
    assign out_valid = (state == OUTPUT);
    assign out_dist  = count;

endmodule
