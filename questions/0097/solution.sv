module relu_unit #(
    parameter DATA_WIDTH = 16
)(
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       in_valid,
    input  wire signed [DATA_WIDTH-1:0] in_data,
    input  wire                       out_ready,
    output wire                       in_ready,
    output wire                       out_valid,
    output wire signed [DATA_WIDTH-1:0] out_data
);

    // State machine
    localparam IDLE   = 1'd0;
    localparam OUTPUT = 1'd1;

    reg state, next_state;
    reg signed [DATA_WIDTH-1:0] result_reg;

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

    // ReLU computation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_reg <= {DATA_WIDTH{1'b0}};
        end else if (state == IDLE && in_valid && in_ready) begin
            // ReLU: max(0, x)
            if (in_data[DATA_WIDTH-1])  // Negative (MSB = 1)
                result_reg <= {DATA_WIDTH{1'b0}};
            else
                result_reg <= in_data;
        end
    end

    // Output assignments
    assign in_ready  = (state == IDLE);
    assign out_valid = (state == OUTPUT);
    assign out_data  = result_reg;

endmodule
