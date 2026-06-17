module stream_accum #(
    parameter DATA_WIDTH = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      start,
    input  wire                      in_valid,
    input  wire [DATA_WIDTH-1:0]     in_data,
    input  wire                      in_last,
    input  wire                      out_ready,
    output wire                      in_ready,
    output wire                      out_valid,
    output wire [DATA_WIDTH+7:0]     out_sum
);

    localparam SUM_WIDTH = DATA_WIDTH + 8;

    // State machine
    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;
    reg [SUM_WIDTH-1:0] sum_reg;

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
                    next_state = INPUT;
            end
            INPUT: begin
                if (in_valid && in_ready && in_last)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Sum accumulation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg <= {SUM_WIDTH{1'b0}};
        end else if (start) begin
            sum_reg <= {SUM_WIDTH{1'b0}};
        end else if (state == INPUT && in_valid && in_ready) begin
            sum_reg <= sum_reg + {{(SUM_WIDTH-DATA_WIDTH){1'b0}}, in_data};
        end
    end

    // Output assignments
    assign in_ready  = (state == INPUT);
    assign out_valid = (state == OUTPUT);
    assign out_sum   = sum_reg;

endmodule
