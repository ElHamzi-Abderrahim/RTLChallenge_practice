module fib_gen #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  out_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_data,
    output reg  [7:0]            out_index
);

    reg [DATA_WIDTH-1:0] fib_prev;  // F(n-2)
    reg [DATA_WIDTH-1:0] fib_curr;  // F(n-1)
    reg                  running;

    wire handshake = out_valid && out_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_data  <= {DATA_WIDTH{1'b0}};
            out_index <= 8'd0;
            fib_prev  <= {DATA_WIDTH{1'b0}};
            fib_curr  <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
            running   <= 1'b0;
        end else begin
            if (start) begin
                // Start from F(0)
                running   <= 1'b1;
                out_valid <= 1'b1;
                out_data  <= {DATA_WIDTH{1'b0}};  // F(0) = 0
                out_index <= 8'd0;
                fib_prev  <= {DATA_WIDTH{1'b0}};  // Will be F(n-2)
                fib_curr  <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};  // Will be F(n-1)
            end else if (running && handshake) begin
                // Move to next Fibonacci number
                out_index <= out_index + 1'b1;

                if (out_index == 8'd0) begin
                    // Was F(0), now output F(1)
                    out_data <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                end else begin
                    // F(n) = F(n-1) + F(n-2)
                    out_data <= fib_prev + fib_curr;
                    fib_prev <= fib_curr;
                    fib_curr <= fib_prev + fib_curr;
                end
            end
        end
    end

endmodule
