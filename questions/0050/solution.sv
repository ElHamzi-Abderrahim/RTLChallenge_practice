module decimation_filter #(
    parameter DATA_WIDTH = 8,
    parameter DECIMATION_FACTOR = 4
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire signed [DATA_WIDTH-1:0]    data_in,
    input  wire                       data_valid_in,
    output wire signed [DATA_WIDTH-1:0]    data_out,
    output wire                       data_valid_out
);

    localparam COUNTER_WIDTH = $clog2(DECIMATION_FACTOR);
    
    // FIR filter coefficients: [1, 3, 3, 1] (normalized by 8)
    reg signed [DATA_WIDTH-1:0] x1, x2, x3;
    reg signed [DATA_WIDTH+3:0] filtered;
    reg [COUNTER_WIDTH-1:0] sample_counter;
    reg valid_out_reg;
    reg signed [DATA_WIDTH-1:0] output_reg;
    
    always @(posedge clk) begin
        if (reset) begin
            x1 <= {DATA_WIDTH{1'b0}};
            x2 <= {DATA_WIDTH{1'b0}};
            x3 <= {DATA_WIDTH{1'b0}};
            sample_counter <= {COUNTER_WIDTH{1'b0}};
            valid_out_reg <= 1'b0;
            output_reg <= {DATA_WIDTH{1'b0}};
        end else if (data_valid_in) begin
            // Update delay line
            x3 <= x2;
            x2 <= x1;
            x1 <= data_in;
            
            // Apply FIR filter: (1*x[n] + 3*x[n-1] + 3*x[n-2] + 1*x[n-3]) / 8
            filtered = data_in + (x1 << 1) + x1 + (x2 << 1) + x2 + x3;
            
            // Increment sample counter
            if (sample_counter == DECIMATION_FACTOR - 1) begin
                sample_counter <= {COUNTER_WIDTH{1'b0}};
                valid_out_reg <= 1'b1;
                output_reg <= filtered >>> 3;  // Divide by 8
            end else begin
                sample_counter <= sample_counter + 1'b1;
                valid_out_reg <= 1'b0;
            end
        end else begin
            valid_out_reg <= 1'b0;
        end
    end
    
    assign data_out = output_reg;
    assign data_valid_out = valid_out_reg;

endmodule
