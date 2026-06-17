module running_sum #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_sum
);

    reg [DATA_WIDTH-1:0] accumulator;

    // Input handshake
    wire in_handshake = in_valid && in_ready;
    // Output handshake
    wire out_handshake = out_valid && out_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= {DATA_WIDTH{1'b0}};
            out_valid   <= 1'b0;
            out_sum     <= {DATA_WIDTH{1'b0}};
            in_ready    <= 1'b1;
        end else begin
            if (start) begin
                accumulator <= {DATA_WIDTH{1'b0}};
                out_valid   <= 1'b0;
                in_ready    <= 1'b1;
            end else begin
                // Handle output handshake
                if (out_handshake) begin
                    out_valid <= 1'b0;
                end

                // Handle input handshake
                if (in_handshake) begin
                    accumulator <= accumulator + in_data;
                    out_sum     <= accumulator + in_data;
                    out_valid   <= 1'b1;
                    in_ready    <= 1'b0;  // Not ready until output consumed
                end

                // Ready for new input when output is consumed or no pending output
                if (!out_valid || out_handshake) begin
                    in_ready <= 1'b1;
                end
            end
        end
    end

endmodule
