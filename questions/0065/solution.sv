module seq_reverse #(
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
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_data,
    output reg                   out_last
);

    localparam IDX_WIDTH = $clog2(MAX_SIZE + 1);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] arr [0:MAX_SIZE-1];
    reg [IDX_WIDTH-1:0] count;      // Number of elements
    reg [IDX_WIDTH-1:0] wr_idx;     // Write index during input
    reg [IDX_WIDTH-1:0] rd_idx;     // Read index during output (counts down)

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            in_ready  <= 1'b0;
            out_valid <= 1'b0;
            out_data  <= {DATA_WIDTH{1'b0}};
            out_last  <= 1'b0;
            count     <= {IDX_WIDTH{1'b0}};
            wr_idx    <= {IDX_WIDTH{1'b0}};
            rd_idx    <= {IDX_WIDTH{1'b0}};
            for (k = 0; k < MAX_SIZE; k = k + 1) begin
                arr[k] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    out_last  <= 1'b0;
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
                            in_ready  <= 1'b0;
                            state     <= OUTPUT;
                            count     <= wr_idx + 1;
                            rd_idx    <= wr_idx;  // Start from last written index
                            out_valid <= 1'b1;
                            out_data  <= in_data;  // First output is last input
                            out_last  <= (wr_idx == 0);  // Single element case
                        end
                    end
                end

                OUTPUT: begin
                    if (out_valid && out_ready) begin
                        if (rd_idx == 0) begin
                            // Done outputting
                            out_valid <= 1'b0;
                            out_last  <= 1'b0;
                            state     <= IDLE;
                        end else begin
                            rd_idx   <= rd_idx - 1;
                            out_data <= arr[rd_idx - 1];
                            out_last <= (rd_idx == 1);
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
