module max_pool #(
    parameter DATA_WIDTH = 8,
    parameter POOL_SIZE = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire                  out_ready,
    output wire                  in_ready,
    output wire                  out_valid,
    output wire [DATA_WIDTH-1:0] out_max
);

    // State machine
    localparam IDLE   = 2'd0;
    localparam POOL   = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;

    // Max register
    reg [DATA_WIDTH-1:0] max_reg;

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
                    next_state = POOL;
            end
            POOL: begin
                if (in_valid && in_ready && in_last)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
        endcase
    end

    // Max tracking
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_reg <= {DATA_WIDTH{1'b0}};
        end else if (start) begin
            max_reg <= {DATA_WIDTH{1'b0}};
        end else if (state == POOL && in_valid && in_ready) begin
            if (in_data > max_reg)
                max_reg <= in_data;
        end
    end

    // Output assignments
    assign in_ready  = (state == POOL);
    assign out_valid = (state == OUTPUT);
    assign out_max   = max_reg;

endmodule
