module peak_detect #(
    parameter DATA_WIDTH = 8
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
    output reg                   out_is_peak,
    output reg  [DATA_WIDTH-1:0] out_value,
    output reg  [7:0]            out_index
);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam EMIT   = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] val_prev, val_curr, val_next;
    reg [7:0] idx_curr;
    reg [1:0] count;  // 0, 1, 2+ values received
    reg pending_last;

    wire in_handshake  = in_valid && in_ready;
    wire out_handshake = out_valid && out_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            in_ready     <= 1'b0;
            out_valid    <= 1'b0;
            out_is_peak  <= 1'b0;
            out_value    <= {DATA_WIDTH{1'b0}};
            out_index    <= 8'd0;
            val_prev     <= {DATA_WIDTH{1'b0}};
            val_curr     <= {DATA_WIDTH{1'b0}};
            val_next     <= {DATA_WIDTH{1'b0}};
            idx_curr     <= 8'd0;
            count        <= 2'd0;
            pending_last <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    if (start) begin
                        state        <= INPUT;
                        in_ready     <= 1'b1;
                        count        <= 2'd0;
                        idx_curr     <= 8'd0;
                        pending_last <= 1'b0;
                    end
                end

                INPUT: begin
                    if (in_handshake) begin
                        case (count)
                            2'd0: begin
                                // First value
                                val_prev <= in_data;
                                count    <= 2'd1;
                                if (in_last) begin
                                    // Single element, no peaks possible
                                    in_ready <= 1'b0;
                                    state    <= IDLE;
                                end
                            end

                            2'd1: begin
                                // Second value
                                val_curr <= in_data;
                                idx_curr <= 8'd1;
                                count    <= 2'd2;
                                if (in_last) begin
                                    // Two elements, no peaks possible
                                    in_ready <= 1'b0;
                                    state    <= IDLE;
                                end
                            end

                            default: begin
                                // Third+ value - can output for curr
                                val_next <= in_data;
                                state    <= EMIT;
                                in_ready <= 1'b0;

                                // Check if curr is peak
                                out_valid   <= 1'b1;
                                out_value   <= val_curr;
                                out_index   <= idx_curr;
                                out_is_peak <= (val_curr > val_prev) && (val_curr > in_data);

                                pending_last <= in_last;
                            end
                        endcase
                    end
                end

                EMIT: begin
                    if (out_handshake) begin
                        out_valid <= 1'b0;

                        // Shift window
                        val_prev <= val_curr;
                        val_curr <= val_next;
                        idx_curr <= idx_curr + 1;

                        if (pending_last) begin
                            // Was last input, done
                            state <= IDLE;
                        end else begin
                            state    <= INPUT;
                            in_ready <= 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
