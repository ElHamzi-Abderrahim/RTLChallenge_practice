module bitonic_detect #(
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
    output wire                  out_is_bitonic,
    output wire [7:0]            out_peak_idx
);

    // Main state machine
    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam OUTPUT = 2'd2;

    // Bitonic phase tracking
    localparam PHASE_INIT = 2'd0;
    localparam PHASE_INC  = 2'd1;
    localparam PHASE_DEC  = 2'd2;

    reg [1:0] state, next_state;
    reg [1:0] phase;

    // Storage
    reg [DATA_WIDTH-1:0] prev_val;
    reg [7:0] curr_idx;
    reg [7:0] peak_idx;
    reg is_bitonic;
    reg first_elem;

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

    // Bitonic detection logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_val <= {DATA_WIDTH{1'b0}};
            curr_idx <= 0;
            peak_idx <= 0;
            phase <= PHASE_INIT;
            is_bitonic <= 1;
            first_elem <= 1;
        end else if (start) begin
            prev_val <= {DATA_WIDTH{1'b0}};
            curr_idx <= 0;
            peak_idx <= 0;
            phase <= PHASE_INIT;
            is_bitonic <= 1;
            first_elem <= 1;
        end else if (state == INPUT && in_valid && in_ready) begin
            prev_val <= in_data;
            curr_idx <= curr_idx + 1;

            if (first_elem) begin
                first_elem <= 0;
                peak_idx <= 0;  // First element is initial peak candidate
            end else begin
                // Compare with previous value
                if (in_data > prev_val) begin
                    // Increasing
                    case (phase)
                        PHASE_INIT: begin
                            phase <= PHASE_INC;
                            peak_idx <= curr_idx;
                        end
                        PHASE_INC: begin
                            peak_idx <= curr_idx;
                        end
                        PHASE_DEC: begin
                            // Was decreasing, now increasing - not bitonic
                            is_bitonic <= 0;
                        end
                    endcase
                end else if (in_data < prev_val) begin
                    // Decreasing
                    case (phase)
                        PHASE_INIT: begin
                            phase <= PHASE_DEC;
                            // Peak was at previous index (index 0 for first decrease)
                        end
                        PHASE_INC: begin
                            phase <= PHASE_DEC;
                            // Peak was at previous index
                        end
                        PHASE_DEC: begin
                            // Still decreasing, OK
                        end
                    endcase
                end
                // Equal values: stay in current phase, don't update peak
            end
        end
    end

    // Output assignments
    assign in_ready     = (state == INPUT);
    assign out_valid    = (state == OUTPUT);
    assign out_is_bitonic = is_bitonic;
    assign out_peak_idx = peak_idx;

endmodule
