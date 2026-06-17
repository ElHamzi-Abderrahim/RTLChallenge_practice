module clock_divider #(
    parameter DIVIDE_FACTOR = 2
)(
    input  wire                    clk_in,
    input  wire                    reset,
    input  wire                    enable,
    output wire                    clk_out
);

    localparam COUNTER_WIDTH = $clog2(DIVIDE_FACTOR);
    
    reg [COUNTER_WIDTH-1:0] counter;
    reg clk_out_reg;

    always @(posedge clk_in) begin
        if (reset) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            clk_out_reg <= 1'b0;
        end else if (enable) begin
            if (counter == (DIVIDE_FACTOR/2) - 1) begin
                counter <= {COUNTER_WIDTH{1'b0}};
                clk_out_reg <= ~clk_out_reg;
            end else begin
                counter <= counter + 1'b1;
            end
        end else begin
            clk_out_reg <= 1'b0;
        end
    end

    assign clk_out = enable ? clk_out_reg : 1'b0;

endmodule
