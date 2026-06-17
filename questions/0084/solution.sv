module longest_consec #(
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
    output wire [7:0]            out_length
);

    // State machine
    localparam IDLE   = 3'd0;
    localparam INPUT  = 3'd1;
    localparam SORT   = 3'd2;
    localparam SCAN   = 3'd3;
    localparam OUTPUT = 3'd4;

    reg [2:0] state, next_state;

    // Storage
    reg [DATA_WIDTH-1:0] buffer [0:MAX_SIZE-1];
    reg [4:0] buf_count;

    // Sort variables
    reg [4:0] sort_i, sort_j;
    reg sort_swapped;
    reg [DATA_WIDTH-1:0] temp;

    // Scan variables
    reg [4:0] scan_idx;
    reg [7:0] curr_len, max_len;

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
                    next_state = SCAN;
            end
            SCAN: begin
                if (scan_idx >= buf_count)
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
                    // Swap
                    buffer[sort_j] <= buffer[sort_j + 1];
                    buffer[sort_j + 1] <= buffer[sort_j];
                    sort_swapped <= 1;
                end
                sort_j <= sort_j + 1;
            end else begin
                sort_j <= 0;
                sort_i <= sort_i + 1;
                if (sort_i >= buf_count - 2 || !sort_swapped) begin
                    // Done or no swaps
                end else begin
                    sort_swapped <= 0;
                end
            end
        end
    end

    // Scan for longest consecutive
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scan_idx <= 0;
            curr_len <= 1;
            max_len <= 1;
        end else if (state == SORT && next_state == SCAN) begin
            scan_idx <= 1;
            curr_len <= 1;
            max_len <= (buf_count > 0) ? 1 : 0;
        end else if (state == SCAN && scan_idx < buf_count) begin
            scan_idx <= scan_idx + 1;

            if (buffer[scan_idx] == buffer[scan_idx - 1]) begin
                // Duplicate - skip
            end else if (buffer[scan_idx] == buffer[scan_idx - 1] + 1) begin
                // Consecutive
                curr_len <= curr_len + 1;
                if (curr_len + 1 > max_len)
                    max_len <= curr_len + 1;
            end else begin
                // Break in sequence
                curr_len <= 1;
            end
        end
    end

    // Output assignments
    assign in_ready  = (state == INPUT);
    assign out_valid = (state == OUTPUT);
    assign out_length = (buf_count == 0) ? 8'd0 : max_len;

endmodule
