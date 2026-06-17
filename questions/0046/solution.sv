module fir_filter #(
    parameter DATA_WIDTH = 8
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire signed [DATA_WIDTH-1:0]    data_in,
    output wire signed [DATA_WIDTH+1:0]    data_out
);

    // Coefficients: h[0]=1, h[1]=2, h[2]=2, h[3]=1
    // Output = (1*x[n] + 2*x[n-1] + 2*x[n-2] + 1*x[n-3]) / 8
    
    reg signed [DATA_WIDTH-1:0] delay1, delay2, delay3;
    reg signed [DATA_WIDTH+3:0] accumulator;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            delay1 <= {DATA_WIDTH{1'b0}};
            delay2 <= {DATA_WIDTH{1'b0}};
            delay3 <= {DATA_WIDTH{1'b0}};
            accumulator = 0;
        end else begin
            delay1 <= data_in;
            delay2 <= delay1;
            delay3 <= delay2;
            accumulator <= ((data_in) + (delay1 << 1) + (delay2 << 1) + (delay3))>>>3;
        end
    end
    
    assign data_out = accumulator;

endmodule
