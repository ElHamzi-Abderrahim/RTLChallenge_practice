module merge_sorted #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  in_a_valid,
    input  wire [DATA_WIDTH-1:0] in_a_data,
    input  wire                  in_a_last,
    input  wire                  in_b_valid,
    input  wire [DATA_WIDTH-1:0] in_b_data,
    input  wire                  in_b_last,
    input  wire                  out_ready,
    output reg                   in_a_ready,
    output reg                   in_b_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_data,
    output reg                   out_last
);

    // Buffered values from each stream
    reg [DATA_WIDTH-1:0] buf_a, buf_b;
    reg buf_a_valid, buf_b_valid;
    reg buf_a_last, buf_b_last;
    reg a_done, b_done;  // Stream has ended

    // Handshakes
    wire a_handshake = in_a_valid && in_a_ready;
    wire b_handshake = in_b_valid && in_b_ready;
    wire out_handshake = out_valid && out_ready;

    // Decide which to output
    wire select_a = buf_a_valid && (!buf_b_valid || buf_a <= buf_b);
    wire select_b = buf_b_valid && (!buf_a_valid || buf_b < buf_a);

    // Can output when we have buffered data and downstream ready
    wire can_output = (buf_a_valid || buf_b_valid) && out_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buf_a       <= {DATA_WIDTH{1'b0}};
            buf_b       <= {DATA_WIDTH{1'b0}};
            buf_a_valid <= 1'b0;
            buf_b_valid <= 1'b0;
            buf_a_last  <= 1'b0;
            buf_b_last  <= 1'b0;
            a_done      <= 1'b0;
            b_done      <= 1'b0;
            in_a_ready  <= 1'b1;
            in_b_ready  <= 1'b1;
            out_valid   <= 1'b0;
            out_data    <= {DATA_WIDTH{1'b0}};
            out_last    <= 1'b0;
        end else begin
            // Clear output valid after handshake
            if (out_handshake) begin
                out_valid <= 1'b0;
                out_last  <= 1'b0;
            end

            // Capture input A
            if (a_handshake) begin
                buf_a       <= in_a_data;
                buf_a_valid <= 1'b1;
                buf_a_last  <= in_a_last;
                in_a_ready  <= 1'b0;
            end

            // Capture input B
            if (b_handshake) begin
                buf_b       <= in_b_data;
                buf_b_valid <= 1'b1;
                buf_b_last  <= in_b_last;
                in_b_ready  <= 1'b0;
            end

            // Output logic - when both buffers valid or one stream done
            if (!out_valid || out_handshake) begin
                if (buf_a_valid && buf_b_valid) begin
                    // Both have data, compare and output smaller
                    if (buf_a <= buf_b) begin
                        out_valid   <= 1'b1;
                        out_data    <= buf_a;
                        buf_a_valid <= 1'b0;
                        in_a_ready  <= !buf_a_last;

                        if (buf_a_last) begin
                            a_done <= 1'b1;
                        end

                        // The other buffer still holds a value to emit, so this
                        // can never be the final output.
                        out_last <= 1'b0;
                    end else begin
                        out_valid   <= 1'b1;
                        out_data    <= buf_b;
                        buf_b_valid <= 1'b0;
                        in_b_ready  <= !buf_b_last;

                        if (buf_b_last) begin
                            b_done <= 1'b1;
                        end

                        out_last <= 1'b0;
                    end
                end else if (buf_a_valid && (b_done || buf_b_last)) begin
                    // Only A has data, B is done
                    out_valid   <= 1'b1;
                    out_data    <= buf_a;
                    out_last    <= buf_a_last;
                    buf_a_valid <= 1'b0;
                    in_a_ready  <= !buf_a_last;

                    if (buf_a_last) begin
                        a_done <= 1'b1;
                    end
                end else if (buf_b_valid && (a_done || buf_a_last)) begin
                    // Only B has data, A is done
                    out_valid   <= 1'b1;
                    out_data    <= buf_b;
                    out_last    <= buf_b_last;
                    buf_b_valid <= 1'b0;
                    in_b_ready  <= !buf_b_last;

                    if (buf_b_last) begin
                        b_done <= 1'b1;
                    end
                end
            end

            // Re-enable ready when buffer consumed and stream not done
            if (!buf_a_valid && !a_done && !in_a_ready) begin
                in_a_ready <= 1'b1;
            end
            if (!buf_b_valid && !b_done && !in_b_ready) begin
                in_b_ready <= 1'b1;
            end
        end
    end

endmodule
