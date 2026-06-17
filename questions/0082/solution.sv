module prefix_sum #(
    parameter DATA_WIDTH = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      start,
    input  wire                      in_valid,
    input  wire [DATA_WIDTH-1:0]     in_data,
    input  wire                      out_ready,
    output wire                      in_ready,
    output wire                      out_valid,
    output wire [DATA_WIDTH+7:0]     out_data
);

    localparam SUM_WIDTH = DATA_WIDTH + 8;

    // State machine
    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam OUTPUT  = 2'd2;

    reg [1:0] state, next_state;
    reg [SUM_WIDTH-1:0] sum_reg;
    reg [SUM_WIDTH-1:0] out_reg;
    reg out_valid_reg;

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
                    next_state = COMPUTE;
            end
            COMPUTE: begin
                if (in_valid && in_ready)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = COMPUTE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Sum computation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg <= {SUM_WIDTH{1'b0}};
            out_reg <= {SUM_WIDTH{1'b0}};
            out_valid_reg <= 1'b0;
        end else if (start) begin
            sum_reg <= {SUM_WIDTH{1'b0}};
            out_valid_reg <= 1'b0;
        end else if (state == COMPUTE && in_valid && in_ready) begin
            sum_reg <= sum_reg + {{(SUM_WIDTH-DATA_WIDTH){1'b0}}, in_data};
            out_reg <= sum_reg + {{(SUM_WIDTH-DATA_WIDTH){1'b0}}, in_data};
            out_valid_reg <= 1'b1;
        end else if (state == OUTPUT && out_valid && out_ready) begin
            out_valid_reg <= 1'b0;
        end
    end

    // Output assignments
    assign in_ready  = (state == COMPUTE);
    assign out_valid = out_valid_reg && (state == OUTPUT);
    assign out_data  = out_reg;

endmodule
