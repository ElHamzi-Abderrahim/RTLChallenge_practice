module argmax_unit #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 16
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
    output wire [7:0]            out_argmax,
    output wire [DATA_WIDTH-1:0] out_max
);

    // State machine
    localparam IDLE   = 2'd0;
    localparam SEARCH = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;

    // Tracking registers
    reg [7:0] curr_idx;
    reg [7:0] max_idx;
    reg [DATA_WIDTH-1:0] max_val;

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
                    next_state = SEARCH;
            end
            SEARCH: begin
                if (in_valid && in_ready && in_last)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
        endcase
    end

    // Argmax tracking
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            curr_idx <= 8'd0;
            max_idx <= 8'd0;
            max_val <= {DATA_WIDTH{1'b0}};
        end else if (start) begin
            curr_idx <= 8'd0;
            max_idx <= 8'd0;
            max_val <= {DATA_WIDTH{1'b0}};
        end else if (state == SEARCH && in_valid && in_ready) begin
            if (curr_idx == 0 || in_data > max_val) begin
                max_val <= in_data;
                max_idx <= curr_idx;
            end
            curr_idx <= curr_idx + 1;
        end
    end

    // Output assignments
    assign in_ready    = (state == SEARCH);
    assign out_valid   = (state == OUTPUT);
    assign out_argmax  = max_idx;
    assign out_max     = max_val;

endmodule
