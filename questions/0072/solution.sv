module dup_detect #(
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
    output reg                   out_has_dup
);

    localparam IDX_WIDTH = $clog2(MAX_SIZE + 1);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam CHECK  = 2'd2;
    localparam OUTPUT = 2'd3;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] arr [0:MAX_SIZE-1];
    reg [IDX_WIDTH-1:0] count;
    reg [IDX_WIDTH-1:0] wr_idx;
    reg [IDX_WIDTH-1:0] i_idx, j_idx;
    reg has_dup;

    // Check new value against stored values during input
    reg dup_found_early;
    integer m;

    always @(*) begin
        dup_found_early = 1'b0;
        if (state == INPUT && in_valid && in_ready) begin
            for (m = 0; m < MAX_SIZE; m = m + 1) begin
                if (m < wr_idx && arr[m] == in_data) begin
                    dup_found_early = 1'b1;
                end
            end
        end
    end

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            in_ready    <= 1'b0;
            out_valid   <= 1'b0;
            out_has_dup <= 1'b0;
            count       <= {IDX_WIDTH{1'b0}};
            wr_idx      <= {IDX_WIDTH{1'b0}};
            i_idx       <= {IDX_WIDTH{1'b0}};
            j_idx       <= {IDX_WIDTH{1'b0}};
            has_dup     <= 1'b0;
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
                        has_dup  <= 1'b0;
                    end
                end

                INPUT: begin
                    if (in_valid && in_ready) begin
                        arr[wr_idx] <= in_data;
                        wr_idx <= wr_idx + 1;
                        count  <= wr_idx + 1;

                        // Early detection during input
                        if (dup_found_early) begin
                            has_dup <= 1'b1;
                        end

                        if (in_last || wr_idx == MAX_SIZE - 1) begin
                            in_ready <= 1'b0;

                            // If already found duplicate, go directly to output
                            if (has_dup || dup_found_early) begin
                                state       <= OUTPUT;
                                out_valid   <= 1'b1;
                                out_has_dup <= 1'b1;
                            end else begin
                                state <= OUTPUT;
                                out_valid   <= 1'b1;
                                out_has_dup <= 1'b0;
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
