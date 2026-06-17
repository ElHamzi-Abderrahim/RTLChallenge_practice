module trailing_zero #(
    parameter DATA_WIDTH = 8
)(
    input  wire                            clk,
    input  wire                            rst_n,
    input  wire                            in_valid,
    input  wire [DATA_WIDTH-1:0]           in_data,
    input  wire                            out_ready,
    output wire                            in_ready,
    output wire                            out_valid,
    output wire [$clog2(DATA_WIDTH+1)-1:0] out_count
);

    localparam COUNT_WIDTH = $clog2(DATA_WIDTH + 1);

    // State machine
    localparam IDLE    = 2'd0;
    localparam COUNT   = 2'd1;
    localparam OUTPUT  = 2'd2;

    reg [1:0] state, next_state;

    // Registers
    reg [DATA_WIDTH-1:0] data_reg;
    reg [COUNT_WIDTH-1:0] count_reg;
    reg [$clog2(DATA_WIDTH+1)-1:0] bit_idx;
    reg found_one;

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
                    next_state = COUNT;
            end
            COUNT: begin
                if (found_one || bit_idx >= DATA_WIDTH)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Count trailing zeros
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= {DATA_WIDTH{1'b0}};
            count_reg <= {COUNT_WIDTH{1'b0}};
            bit_idx <= 0;
            found_one <= 0;
        end else if (state == IDLE && in_valid && in_ready) begin
            data_reg <= in_data;
            count_reg <= {COUNT_WIDTH{1'b0}};
            bit_idx <= 0;
            found_one <= 0;
        end else if (state == COUNT && !found_one && bit_idx < DATA_WIDTH) begin
            if (data_reg[bit_idx]) begin
                found_one <= 1;
            end else begin
                count_reg <= count_reg + 1;
                bit_idx <= bit_idx + 1;
            end
        end
    end

    // Output assignments
    assign in_ready  = (state == IDLE);
    assign out_valid = (state == OUTPUT);
    assign out_count = count_reg;

endmodule
