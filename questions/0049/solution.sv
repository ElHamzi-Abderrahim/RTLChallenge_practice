module iir_biquad #(
    parameter DATA_WIDTH = 8
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire signed [DATA_WIDTH-1:0]    data_in,
    output wire signed [DATA_WIDTH-1:0]    data_out
);

    // Coefficients (scaled by 8):
    // b0=1, b1=2, b2=1
    // a1=1, a2=0
    // y[n] = (x[n] + 2*x[n-1] + x[n-2] - y[n-1]) / 8
    
    reg signed [DATA_WIDTH-1:0] x1, x2;  // Input delays
    reg signed [DATA_WIDTH-1:0] y1;      // Output delay
    reg signed [DATA_WIDTH+3:0] accumulator;
    reg signed [DATA_WIDTH-1:0] y_out;
    reg signed [DATA_WIDTH-1:0] y_temp;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            x1 <= {DATA_WIDTH{1'b0}};
            x2 <= {DATA_WIDTH{1'b0}};
            y1 <= {DATA_WIDTH{1'b0}};
            y_out <= {DATA_WIDTH{1'b0}};
        end else begin
            // Calculate output using current delays before updating
            accumulator = data_in + (x1 << 1) + x2 - y1;

            // Saturate and divide by 8
            if (accumulator[DATA_WIDTH+3:DATA_WIDTH+2] == 2'b01) begin
                // Positive overflow after division
                y_temp = {1'b0, {(DATA_WIDTH-1){1'b1}}};
            end else if (accumulator[DATA_WIDTH+3:DATA_WIDTH+2] == 2'b10) begin
                // Negative overflow after division
                y_temp = {1'b1, {(DATA_WIDTH-1){1'b0}}};
            end else begin
                // No overflow - divide by 8
                y_temp = accumulator >>> 3;
            end

            // Update delay lines and output
            x2 <= x1;
            x1 <= data_in;
            y1 <= y_temp;
            y_out <= y_temp;
        end
    end
    
    assign data_out = y_out;

endmodule
