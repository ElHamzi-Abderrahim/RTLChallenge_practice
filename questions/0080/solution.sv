module matrix_transpose #(
    parameter DATA_WIDTH = 8,
    parameter MATRIX_SIZE = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_data,
    output reg                   out_last
);

    localparam TOTAL_SIZE = MATRIX_SIZE * MATRIX_SIZE;
    localparam IDX_WIDTH = $clog2(TOTAL_SIZE + 1);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] matrix [0:MATRIX_SIZE-1][0:MATRIX_SIZE-1];
    reg [IDX_WIDTH-1:0] in_idx;
    reg [IDX_WIDTH-1:0] out_idx;

    // Calculate row/col from linear index
    wire [$clog2(MATRIX_SIZE)-1:0] in_row = in_idx / MATRIX_SIZE;
    wire [$clog2(MATRIX_SIZE)-1:0] in_col = in_idx % MATRIX_SIZE;
    wire [$clog2(MATRIX_SIZE)-1:0] out_row = out_idx / MATRIX_SIZE;
    wire [$clog2(MATRIX_SIZE)-1:0] out_col = out_idx % MATRIX_SIZE;

    // Index/row/col of the NEXT element to emit (presented on out_data after
    // each output handshake so the data leads out_idx by one beat).
    wire [IDX_WIDTH-1:0] nxt_idx = out_idx + 1'b1;
    wire [$clog2(MATRIX_SIZE)-1:0] nxt_row = nxt_idx / MATRIX_SIZE;
    wire [$clog2(MATRIX_SIZE)-1:0] nxt_col = nxt_idx % MATRIX_SIZE;

    integer i, j;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            in_ready  <= 1'b0;
            out_valid <= 1'b0;
            out_data  <= {DATA_WIDTH{1'b0}};
            out_last  <= 1'b0;
            in_idx    <= {IDX_WIDTH{1'b0}};
            out_idx   <= {IDX_WIDTH{1'b0}};
            for (i = 0; i < MATRIX_SIZE; i = i + 1) begin
                for (j = 0; j < MATRIX_SIZE; j = j + 1) begin
                    matrix[i][j] <= {DATA_WIDTH{1'b0}};
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    out_last  <= 1'b0;
                    if (start) begin
                        state    <= INPUT;
                        in_ready <= 1'b1;
                        in_idx   <= {IDX_WIDTH{1'b0}};
                    end
                end

                INPUT: begin
                    if (in_valid && in_ready) begin
                        matrix[in_row][in_col] <= in_data;
                        in_idx <= in_idx + 1;

                        if (in_idx == TOTAL_SIZE - 1) begin
                            in_ready  <= 1'b0;
                            state     <= OUTPUT;
                            out_idx   <= {IDX_WIDTH{1'b0}};
                            out_valid <= 1'b1;
                            // First output: transposed[0][0] = original[0][0]
                            out_data  <= matrix[0][0];
                            out_last  <= (TOTAL_SIZE == 1);
                        end
                    end
                end

                OUTPUT: begin
                    // out_data already holds matrix[out_col][out_row] for the
                    // current out_idx; on each handshake advance and pre-load
                    // the next transposed element.
                    if (out_valid && out_ready) begin
                        if (out_idx == TOTAL_SIZE - 1) begin
                            out_valid <= 1'b0;
                            out_last  <= 1'b0;
                            state     <= IDLE;
                        end else begin
                            out_idx  <= out_idx + 1'b1;
                            out_data <= matrix[nxt_col][nxt_row];
                            out_last <= (nxt_idx == TOTAL_SIZE - 1);
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
