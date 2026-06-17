module rle_encoder #(
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
    output reg  [DATA_WIDTH-1:0] out_value,
    output reg  [7:0]            out_count,
    output reg                   out_last
);

    localparam IDLE    = 2'd0;
    localparam ENCODE  = 2'd1;
    localparam EMIT    = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] curr_value;
    reg [7:0] curr_count;
    reg is_last_run;
    reg first_value;
    reg final_pending;  // A trailing single-element run still needs emitting

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            in_ready    <= 1'b0;
            out_valid   <= 1'b0;
            out_value   <= {DATA_WIDTH{1'b0}};
            out_count   <= 8'd0;
            out_last    <= 1'b0;
            curr_value  <= {DATA_WIDTH{1'b0}};
            curr_count  <= 8'd0;
            is_last_run <= 1'b0;
            first_value <= 1'b1;
            final_pending <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    out_last  <= 1'b0;
                    if (start) begin
                        state       <= ENCODE;
                        in_ready    <= 1'b1;
                        curr_count  <= 8'd0;
                        first_value <= 1'b1;
                        is_last_run <= 1'b0;
                        final_pending <= 1'b0;
                    end
                end

                ENCODE: begin
                    if (in_valid && in_ready) begin
                        if (first_value) begin
                            // First value of sequence
                            curr_value  <= in_data;
                            curr_count  <= 8'd1;
                            first_value <= 1'b0;

                            if (in_last) begin
                                // Single value sequence
                                state       <= EMIT;
                                in_ready    <= 1'b0;
                                out_valid   <= 1'b1;
                                out_value   <= in_data;
                                out_count   <= 8'd1;
                                out_last    <= 1'b1;
                                is_last_run <= 1'b1;
                            end
                        end else if (in_data == curr_value && curr_count < 8'hFF) begin
                            // Continue current run
                            curr_count <= curr_count + 1;

                            if (in_last) begin
                                // End of input, emit final run
                                state       <= EMIT;
                                in_ready    <= 1'b0;
                                out_valid   <= 1'b1;
                                out_value   <= curr_value;
                                out_count   <= curr_count + 1;
                                out_last    <= 1'b1;
                                is_last_run <= 1'b1;
                            end
                        end else begin
                            // Value changed or count overflow, emit current run
                            state       <= EMIT;
                            in_ready    <= 1'b0;
                            out_valid   <= 1'b1;
                            out_value   <= curr_value;
                            out_count   <= curr_count;
                            out_last    <= 1'b0;

                            // Save new value for next run. If this changing
                            // input is also the last, that new run is a final
                            // single-element run that must still be emitted.
                            curr_value    <= in_data;
                            curr_count    <= 8'd1;
                            is_last_run   <= 1'b0;
                            final_pending <= in_last;
                        end
                    end
                end

                EMIT: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        out_last  <= 1'b0;

                        if (is_last_run) begin
                            // Was last run, done
                            state <= IDLE;
                        end else if (final_pending) begin
                            // Emit the trailing single-element run
                            out_valid     <= 1'b1;
                            out_value     <= curr_value;
                            out_count     <= curr_count;
                            out_last      <= 1'b1;
                            is_last_run   <= 1'b1;
                            final_pending <= 1'b0;
                        end else begin
                            // More input to process
                            state    <= ENCODE;
                            in_ready <= 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
