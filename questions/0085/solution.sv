module dot_product #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
)(
    input  wire                             clk,
    input  wire                             rst_n,
    input  wire                             start,
    input  wire                             vec_a_valid,
    input  wire [DATA_WIDTH-1:0]            vec_a_data,
    input  wire                             vec_a_last,
    input  wire                             vec_b_valid,
    input  wire [DATA_WIDTH-1:0]            vec_b_data,
    input  wire                             vec_b_last,
    input  wire                             out_ready,
    output wire                             vec_a_ready,
    output wire                             vec_b_ready,
    output wire                             out_valid,
    output wire [DATA_WIDTH*2+7:0]          out_result
);

    localparam RESULT_WIDTH = DATA_WIDTH * 2 + 8;

    // State machine
    localparam IDLE     = 2'd0;
    localparam INPUT_A  = 2'd1;
    localparam INPUT_B  = 2'd2;
    localparam OUTPUT   = 2'd3;

    reg [1:0] state, next_state;

    // Storage for vector A
    reg [DATA_WIDTH-1:0] vec_a [0:MAX_SIZE-1];
    reg [3:0] vec_a_count;
    reg [3:0] vec_b_idx;

    // Accumulator
    reg [RESULT_WIDTH-1:0] accum;

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
                    next_state = INPUT_A;
            end
            INPUT_A: begin
                if (vec_a_valid && vec_a_ready && vec_a_last)
                    next_state = INPUT_B;
            end
            INPUT_B: begin
                if (vec_b_valid && vec_b_ready && vec_b_last)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Store vector A
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vec_a_count <= 0;
        end else if (start) begin
            vec_a_count <= 0;
        end else if (state == INPUT_A && vec_a_valid && vec_a_ready) begin
            vec_a[vec_a_count] <= vec_a_data;
            vec_a_count <= vec_a_count + 1;
        end
    end

    // Multiply-accumulate with vector B
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vec_b_idx <= 0;
            accum <= {RESULT_WIDTH{1'b0}};
        end else if (start) begin
            vec_b_idx <= 0;
            accum <= {RESULT_WIDTH{1'b0}};
        end else if (state == INPUT_B && vec_b_valid && vec_b_ready) begin
            accum <= accum + (vec_a[vec_b_idx] * vec_b_data);
            vec_b_idx <= vec_b_idx + 1;
        end
    end

    // Output assignments
    assign vec_a_ready = (state == INPUT_A);
    assign vec_b_ready = (state == INPUT_B);
    assign out_valid   = (state == OUTPUT);
    assign out_result  = accum;

endmodule
