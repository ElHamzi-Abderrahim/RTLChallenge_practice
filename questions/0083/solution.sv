module majority_elem #(
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
    output wire [DATA_WIDTH-1:0] out_elem,
    output wire                  out_found
);

    // State machine
    localparam IDLE   = 3'd0;
    localparam VOTE   = 3'd1;  // First pass - Boyer-Moore voting
    localparam VERIFY = 3'd2;  // Second pass - count candidate occurrences
    localparam OUTPUT = 3'd3;

    reg [2:0] state, next_state;

    // Storage for verification
    reg [DATA_WIDTH-1:0] buffer [0:MAX_SIZE-1];
    reg [4:0] buf_count;
    reg [4:0] verify_idx;

    // Boyer-Moore state
    reg [DATA_WIDTH-1:0] candidate;
    reg signed [5:0] vote_count;  // Can go negative conceptually, but we reset at 0
    reg [4:0] cand_count;  // Count of candidate in verify phase

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
                    next_state = VOTE;
            end
            VOTE: begin
                if (in_valid && in_ready && in_last)
                    next_state = VERIFY;
            end
            VERIFY: begin
                if (verify_idx >= buf_count)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Boyer-Moore voting and storage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            candidate <= {DATA_WIDTH{1'b0}};
            vote_count <= 0;
            buf_count <= 0;
        end else if (start) begin
            candidate <= {DATA_WIDTH{1'b0}};
            vote_count <= 0;
            buf_count <= 0;
        end else if (state == VOTE && in_valid && in_ready) begin
            // Store for verification
            buffer[buf_count] <= in_data;
            buf_count <= buf_count + 1;

            // Boyer-Moore voting
            if (vote_count == 0) begin
                candidate <= in_data;
                vote_count <= 1;
            end else if (in_data == candidate) begin
                vote_count <= vote_count + 1;
            end else begin
                vote_count <= vote_count - 1;
            end
        end
    end

    // Verification phase
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            verify_idx <= 0;
            cand_count <= 0;
        end else if (start || state == IDLE) begin
            verify_idx <= 0;
            cand_count <= 0;
        end else if (state == VERIFY && verify_idx < buf_count) begin
            verify_idx <= verify_idx + 1;
            if (buffer[verify_idx] == candidate)
                cand_count <= cand_count + 1;
        end
    end

    // Output assignments
    assign in_ready  = (state == VOTE);
    assign out_valid = (state == OUTPUT);
    assign out_elem  = candidate;
    assign out_found = (cand_count > (buf_count >> 1));

endmodule
