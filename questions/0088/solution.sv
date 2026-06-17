module insertion_sort #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
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
    output wire [DATA_WIDTH-1:0] out_data,
    output wire                  out_last
);

    // State machine
    localparam IDLE   = 3'd0;
    localparam INPUT  = 3'd1;
    localparam SORT   = 3'd2;
    localparam SHIFT  = 3'd3;
    localparam OUTPUT = 3'd4;

    reg [2:0] state, next_state;

    // Storage
    reg [DATA_WIDTH-1:0] buffer [0:MAX_SIZE-1];
    reg [3:0] buf_count;

    // Sort variables
    reg [3:0] sort_i;
    reg signed [4:0] sort_j;
    reg [DATA_WIDTH-1:0] key;
    reg sorting_done;

    // Output variables
    reg [3:0] out_idx;

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
                if (sort_i >= buf_count)
                    next_state = OUTPUT;
                else
                    next_state = SHIFT;
            end
            SHIFT: begin
                if (sort_j < 0 || buffer[sort_j] <= key)
                    next_state = SORT;
            end
            OUTPUT: begin
                if (out_valid && out_ready && out_last)
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

    // Insertion sort logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sort_i <= 1;
            sort_j <= 0;
            key <= 0;
        end else if (state == INPUT && in_valid && in_ready && in_last) begin
            sort_i <= 1;
            sort_j <= 0;
            key <= 0;
        end else if (state == SORT) begin
            if (sort_i < buf_count) begin
                key <= buffer[sort_i];
                sort_j <= sort_i - 1;
            end
        end else if (state == SHIFT) begin
            if (sort_j >= 0 && buffer[sort_j] > key) begin
                // Shift element right
                buffer[sort_j + 1] <= buffer[sort_j];
                sort_j <= sort_j - 1;
            end else begin
                // Insert key
                buffer[sort_j + 1] <= key;
                sort_i <= sort_i + 1;
            end
        end
    end

    // Output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_idx <= 0;
        end else if (state == SORT && sort_i >= buf_count) begin
            out_idx <= 0;
        end else if (state == OUTPUT && out_valid && out_ready) begin
            out_idx <= out_idx + 1;
        end
    end

    // Output assignments
    assign in_ready  = (state == INPUT);
    assign out_valid = (state == OUTPUT);
    assign out_data  = buffer[out_idx];
    assign out_last  = (state == OUTPUT) && (out_idx == buf_count - 1);

endmodule
