module diff_calc #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg signed [DATA_WIDTH:0] out_diff
);

    reg [DATA_WIDTH-1:0] prev_value;
    reg has_prev;

    wire in_handshake  = in_valid && in_ready;
    wire out_handshake = out_valid && out_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_ready   <= 1'b0;
            out_valid  <= 1'b0;
            out_diff   <= {(DATA_WIDTH+1){1'b0}};
            prev_value <= {DATA_WIDTH{1'b0}};
            has_prev   <= 1'b0;
        end else begin
            if (start) begin
                in_ready   <= 1'b1;
                out_valid  <= 1'b0;
                has_prev   <= 1'b0;
            end else begin
                // Output handshake
                if (out_handshake) begin
                    out_valid <= 1'b0;
                end

                // Input handshake
                if (in_handshake) begin
                    if (!has_prev) begin
                        // First value, just store
                        prev_value <= in_data;
                        has_prev   <= 1'b1;
                    end else begin
                        // Compute difference
                        out_diff   <= $signed({1'b0, in_data}) - $signed({1'b0, prev_value});
                        out_valid  <= 1'b1;
                        prev_value <= in_data;
                        in_ready   <= 1'b0;
                    end
                end

                // Ready for input when no pending output
                if (!out_valid || out_handshake) begin
                    in_ready <= 1'b1;
                end
            end
        end
    end

endmodule
