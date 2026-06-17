module palindrome_check #(
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
    output reg                   in_ready,
    output reg                   out_valid,
    output reg                   out_is_palindrome
);

    localparam IDX_WIDTH = $clog2(MAX_SIZE + 1);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam CHECK  = 2'd2;
    localparam OUTPUT = 2'd3;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] buffer [0:MAX_SIZE-1];
    reg [IDX_WIDTH-1:0] count;      // Number of elements
    reg [IDX_WIDTH-1:0] wr_idx;     // Write index during input
    reg [IDX_WIDTH-1:0] check_idx;  // Index for checking
    reg is_palindrome;

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= IDLE;
            in_ready        <= 1'b0;
            out_valid       <= 1'b0;
            out_is_palindrome <= 1'b0;
            count           <= {IDX_WIDTH{1'b0}};
            wr_idx          <= {IDX_WIDTH{1'b0}};
            check_idx       <= {IDX_WIDTH{1'b0}};
            is_palindrome   <= 1'b1;
            for (k = 0; k < MAX_SIZE; k = k + 1) begin
                buffer[k] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    if (start) begin
                        state    <= INPUT;
                        in_ready <= 1'b1;
                        wr_idx   <= {IDX_WIDTH{1'b0}};
                        count    <= {IDX_WIDTH{1'b0}};
                    end
                end

                INPUT: begin
                    if (in_valid && in_ready) begin
                        buffer[wr_idx] <= in_data;
                        wr_idx <= wr_idx + 1;
                        count  <= wr_idx + 1;

                        if (in_last || wr_idx == MAX_SIZE - 1) begin
                            in_ready      <= 1'b0;
                            state         <= CHECK;
                            count         <= wr_idx + 1;
                            check_idx     <= {IDX_WIDTH{1'b0}};
                            is_palindrome <= 1'b1;
                        end
                    end
                end

                CHECK: begin
                    // Check one pair per cycle
                    if (check_idx < (count >> 1)) begin
                        if (buffer[check_idx] != buffer[count - 1 - check_idx]) begin
                            is_palindrome <= 1'b0;
                        end
                        check_idx <= check_idx + 1;
                    end else begin
                        // Done checking
                        state             <= OUTPUT;
                        out_valid         <= 1'b1;
                        out_is_palindrome <= is_palindrome;
                    end
                end

                OUTPUT: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        state     <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
