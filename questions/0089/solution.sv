module mode_finder #(
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
    output wire [DATA_WIDTH-1:0] out_mode,
    output wire [7:0]            out_count
);

    // State machine
    localparam IDLE   = 3'd0;
    localparam INPUT  = 3'd1;
    localparam SORT   = 3'd2;
    localparam FIND   = 3'd3;
    localparam OUTPUT = 3'd4;

    reg [2:0] state, next_state;

    // Storage
    reg [DATA_WIDTH-1:0] buffer [0:MAX_SIZE-1];
    reg [4:0] buf_count;

    // Sort variables (bubble sort)
    reg [4:0] sort_i, sort_j;
    reg sort_swapped;

    // Find mode variables
    reg [4:0] find_idx;
    reg [7:0] curr_count;
    reg [7:0] max_count;
    reg [DATA_WIDTH-1:0] mode_val;
    reg [DATA_WIDTH-1:0] curr_val;

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
                    next_state = SORT;
            end
            SORT: begin
                if (sort_i >= buf_count - 1 && !sort_swapped)
                    next_state = FIND;
            end
            FIND: begin
                if (find_idx >= buf_count)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Input storage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buf_count <= 0;
        end else if (start) begin
            buf_count <= 0;
        end else if (state == INPUT && in_valid && in_ready) begin
            buffer[buf_count] <= in_data;
            buf_count <= buf_count + 1;
        end
    end

    // Bubble sort
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sort_i <= 0;
            sort_j <= 0;
            sort_swapped <= 0;
        end else if (state == INPUT && in_valid && in_ready && in_last) begin
            sort_i <= 0;
            sort_j <= 0;
            sort_swapped <= 0;
        end else if (state == SORT) begin
            if (sort_j < buf_count - 1 - sort_i) begin
                if (buffer[sort_j] > buffer[sort_j + 1]) begin
                    buffer[sort_j] <= buffer[sort_j + 1];
                    buffer[sort_j + 1] <= buffer[sort_j];
                    sort_swapped <= 1;
                end
                sort_j <= sort_j + 1;
            end else begin
                sort_j <= 0;
                sort_i <= sort_i + 1;
                if (!sort_swapped || sort_i >= buf_count - 2) begin
                    // Done
                end else begin
                    sort_swapped <= 0;
                end
            end
        end
    end

    // Find mode (count consecutive equal values in sorted array)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            find_idx <= 0;
            curr_count <= 1;
            max_count <= 0;
            mode_val <= 0;
            curr_val <= 0;
        end else if (state == SORT && next_state == FIND) begin
            find_idx <= 1;
            curr_count <= 1;
            max_count <= 1;
            mode_val <= buffer[0];
            curr_val <= buffer[0];
        end else if (state == FIND && find_idx < buf_count) begin
            find_idx <= find_idx + 1;

            if (buffer[find_idx] == curr_val) begin
                curr_count <= curr_count + 1;
                if (curr_count + 1 > max_count) begin
                    max_count <= curr_count + 1;
                    mode_val <= curr_val;
                end
            end else begin
                curr_val <= buffer[find_idx];
                curr_count <= 1;
            end
        end
    end

    // Output assignments
    assign in_ready  = (state == INPUT);
    assign out_valid = (state == OUTPUT);
    assign out_mode  = mode_val;
    assign out_count = max_count;

endmodule
