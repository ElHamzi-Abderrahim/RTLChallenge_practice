module median_calc #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 9
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
    output reg  [DATA_WIDTH-1:0] out_median
);

    localparam IDX_WIDTH = $clog2(MAX_SIZE + 1);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam SORT   = 2'd2;
    localparam OUTPUT = 2'd3;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] arr [0:MAX_SIZE-1];
    reg [IDX_WIDTH-1:0] count;
    reg [IDX_WIDTH-1:0] wr_idx;
    reg [IDX_WIDTH-1:0] i_cnt, j_cnt;
    reg swapped;

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            in_ready   <= 1'b0;
            out_valid  <= 1'b0;
            out_median <= {DATA_WIDTH{1'b0}};
            count      <= {IDX_WIDTH{1'b0}};
            wr_idx     <= {IDX_WIDTH{1'b0}};
            i_cnt      <= {IDX_WIDTH{1'b0}};
            j_cnt      <= {IDX_WIDTH{1'b0}};
            swapped    <= 1'b0;
            for (k = 0; k < MAX_SIZE; k = k + 1) begin
                arr[k] <= {DATA_WIDTH{1'b0}};
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
                        arr[wr_idx] <= in_data;
                        wr_idx <= wr_idx + 1;
                        count  <= wr_idx + 1;

                        if (in_last || wr_idx == MAX_SIZE - 1) begin
                            in_ready <= 1'b0;
                            state    <= SORT;
                            count    <= wr_idx + 1;
                            i_cnt    <= {IDX_WIDTH{1'b0}};
                            j_cnt    <= {IDX_WIDTH{1'b0}};
                            swapped  <= 1'b0;
                        end
                    end
                end

                SORT: begin
                    if (count <= 1) begin
                        // Single element
                        state      <= OUTPUT;
                        out_valid  <= 1'b1;
                        out_median <= arr[0];
                    end else if (j_cnt < count - 1 - i_cnt) begin
                        // Compare and swap
                        if (arr[j_cnt] > arr[j_cnt + 1]) begin
                            arr[j_cnt]     <= arr[j_cnt + 1];
                            arr[j_cnt + 1] <= arr[j_cnt];
                            swapped <= 1'b1;
                        end
                        j_cnt <= j_cnt + 1;
                    end else begin
                        // End of inner loop
                        if (!swapped || i_cnt >= count - 2) begin
                            // Sorting complete
                            state      <= OUTPUT;
                            out_valid  <= 1'b1;
                            out_median <= arr[count >> 1];
                        end else begin
                            // Next pass
                            i_cnt   <= i_cnt + 1;
                            j_cnt   <= {IDX_WIDTH{1'b0}};
                            swapped <= 1'b0;
                        end
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
