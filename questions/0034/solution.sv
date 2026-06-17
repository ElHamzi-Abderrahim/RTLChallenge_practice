module gray_counter #(
    parameter WIDTH = 4
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    enable,
    output wire [WIDTH-1:0]        gray_count,
    output wire [WIDTH-1:0]        binary_count
);

    reg [WIDTH-1:0] binary_counter;
    
    // Binary counter
    always @(posedge clk) begin
        if (reset) begin
            binary_counter <= {WIDTH{1'b0}};
        end else if (enable) begin
            binary_counter <= binary_counter + 1'b1;
        end
    end
    
    // Binary to Gray conversion
    assign gray_count = binary_counter ^ (binary_counter >> 1);
    assign binary_count = binary_counter;

endmodule
