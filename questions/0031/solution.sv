module johnson_counter #(
    parameter WIDTH = 4
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    enable,
    output wire [WIDTH-1:0]        count_out
);

    reg [WIDTH-1:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            counter <= {WIDTH{1'b0}};
        end else if (enable) begin
            // Johnson counter: shift left and insert inverted MSB at LSB
            counter <= {counter[WIDTH-2:0], ~counter[WIDTH-1]};
        end
    end

    assign count_out = counter;

endmodule
