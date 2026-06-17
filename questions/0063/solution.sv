module prime_check #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_num,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg                   out_is_prime
);

    localparam IDLE  = 2'd0;
    localparam CHECK = 2'd1;
    localparam DONE  = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] num;
    reg [DATA_WIDTH-1:0] divisor;
    reg [DATA_WIDTH*2-1:0] divisor_sq;  // To hold divisor^2

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            in_ready     <= 1'b1;
            out_valid    <= 1'b0;
            out_is_prime <= 1'b0;
            num          <= {DATA_WIDTH{1'b0}};
            divisor      <= {DATA_WIDTH{1'b0}};
            divisor_sq   <= {(DATA_WIDTH*2){1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    if (in_valid && in_ready) begin
                        in_ready <= 1'b0;
                        num      <= in_num;

                        // Handle special cases immediately
                        if (in_num <= 1) begin
                            // 0 and 1 are not prime
                            state        <= DONE;
                            out_valid    <= 1'b1;
                            out_is_prime <= 1'b0;
                        end else if (in_num <= 3) begin
                            // 2 and 3 are prime
                            state        <= DONE;
                            out_valid    <= 1'b1;
                            out_is_prime <= 1'b1;
                        end else if (in_num[0] == 1'b0) begin
                            // Even numbers > 2 are not prime
                            state        <= DONE;
                            out_valid    <= 1'b1;
                            out_is_prime <= 1'b0;
                        end else begin
                            // Start checking from 3
                            state      <= CHECK;
                            divisor    <= 'd3;
                            divisor_sq <= 'd9;  // 3^2
                        end
                    end
                end

                CHECK: begin
                    if (divisor_sq > num) begin
                        // No divisor found, number is prime
                        state        <= DONE;
                        out_valid    <= 1'b1;
                        out_is_prime <= 1'b1;
                    end else if (num % divisor == 0) begin
                        // Found a divisor, not prime
                        state        <= DONE;
                        out_valid    <= 1'b1;
                        out_is_prime <= 1'b0;
                    end else begin
                        // Try next odd divisor
                        divisor    <= divisor + 2;
                        divisor_sq <= (divisor + 2) * (divisor + 2);
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
