module gcd_calc #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_a,
    input  wire [DATA_WIDTH-1:0] in_b,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_gcd
);

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] reg_a;
    reg [DATA_WIDTH-1:0] reg_b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            in_ready  <= 1'b1;
            out_valid <= 1'b0;
            out_gcd   <= {DATA_WIDTH{1'b0}};
            reg_a     <= {DATA_WIDTH{1'b0}};
            reg_b     <= {DATA_WIDTH{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    if (in_valid && in_ready) begin
                        in_ready <= 1'b0;
                        reg_a    <= in_a;
                        reg_b    <= in_b;

                        // Handle edge cases immediately
                        if (in_a == 0 && in_b == 0) begin
                            state     <= DONE;
                            out_valid <= 1'b1;
                            out_gcd   <= {DATA_WIDTH{1'b0}};
                        end else if (in_a == 0) begin
                            state     <= DONE;
                            out_valid <= 1'b1;
                            out_gcd   <= in_b;
                        end else if (in_b == 0) begin
                            state     <= DONE;
                            out_valid <= 1'b1;
                            out_gcd   <= in_a;
                        end else begin
                            state <= COMPUTE;
                        end
                    end
                end

                COMPUTE: begin
                    if (reg_b == 0) begin
                        // Done computing
                        state     <= DONE;
                        out_valid <= 1'b1;
                        out_gcd   <= reg_a;
                    end else begin
                        // Euclidean step: (a, b) <- (b, a mod b)
                        reg_a <= reg_b;
                        reg_b <= reg_a % reg_b;
                    end
                end

                DONE: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        in_ready  <= 1'b1;
                        state     <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
