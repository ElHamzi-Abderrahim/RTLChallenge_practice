module two_sum #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire [DATA_WIDTH-1:0] target,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg                   out_found,
    output reg  [7:0]            out_idx1,
    output reg  [7:0]            out_idx2
);

    localparam IDX_WIDTH = $clog2(MAX_SIZE + 1);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam SEARCH = 2'd2;
    localparam OUTPUT = 2'd3;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] arr [0:MAX_SIZE-1];
    reg [DATA_WIDTH-1:0] target_reg;
    reg [IDX_WIDTH-1:0] count;
    reg [IDX_WIDTH-1:0] wr_idx;
    reg [IDX_WIDTH-1:0] i_idx, j_idx;
    reg found;

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            in_ready  <= 1'b0;
            out_valid <= 1'b0;
            out_found <= 1'b0;
            out_idx1  <= 8'd0;
            out_idx2  <= 8'd0;
            count     <= {IDX_WIDTH{1'b0}};
            wr_idx    <= {IDX_WIDTH{1'b0}};
            i_idx     <= {IDX_WIDTH{1'b0}};
            j_idx     <= {IDX_WIDTH{1'b0}};
            found     <= 1'b0;
            target_reg <= {DATA_WIDTH{1'b0}};
            for (k = 0; k < MAX_SIZE; k = k + 1) begin
                arr[k] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    if (start) begin
                        state      <= INPUT;
                        in_ready   <= 1'b1;
                        wr_idx     <= {IDX_WIDTH{1'b0}};
                        count      <= {IDX_WIDTH{1'b0}};
                        target_reg <= target;
                        found      <= 1'b0;
                    end
                end

                INPUT: begin
                    if (in_valid && in_ready) begin
                        arr[wr_idx] <= in_data;
                        wr_idx <= wr_idx + 1;
                        count  <= wr_idx + 1;

                        if (in_last || wr_idx == MAX_SIZE - 1) begin
                            in_ready <= 1'b0;
                            state    <= SEARCH;
                            count    <= wr_idx + 1;
                            i_idx    <= {IDX_WIDTH{1'b0}};
                            j_idx    <= 'd1;
                        end
                    end
                end

                SEARCH: begin
                    if (count < 2) begin
                        // Need at least 2 elements
                        state     <= OUTPUT;
                        out_valid <= 1'b1;
                        out_found <= 1'b0;
                    end else if (arr[i_idx] + arr[j_idx] == target_reg) begin
                        // Found!
                        state     <= OUTPUT;
                        out_valid <= 1'b1;
                        out_found <= 1'b1;
                        out_idx1  <= i_idx;
                        out_idx2  <= j_idx;
                    end else begin
                        // Continue search
                        if (j_idx < count - 1) begin
                            j_idx <= j_idx + 1;
                        end else begin
                            // Move to next i
                            if (i_idx < count - 2) begin
                                i_idx <= i_idx + 1;
                                j_idx <= i_idx + 2;
                            end else begin
                                // Not found
                                state     <= OUTPUT;
                                out_valid <= 1'b1;
                                out_found <= 1'b0;
                            end
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
