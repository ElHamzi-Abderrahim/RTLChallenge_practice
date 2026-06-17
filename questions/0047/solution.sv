module moving_average #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_SIZE = 4
)(
    input  wire                       clk,
    input  wire                       reset,
    input  wire [DATA_WIDTH-1:0]      data_in,
    output wire [DATA_WIDTH-1:0]      data_out
);

    localparam SHIFT_AMOUNT = $clog2(WINDOW_SIZE);
    localparam SUM_WIDTH = DATA_WIDTH + SHIFT_AMOUNT;
    
    reg [DATA_WIDTH-1:0] window [0:WINDOW_SIZE-1];
    reg [SUM_WIDTH-1:0] sum;
    integer i;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
                window[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            // Shift window
            for (i = WINDOW_SIZE-1; i > 0; i = i - 1) begin
                window[i] <= window[i-1];
            end
            window[0] <= data_in;
        end
    end
    
    // Calculate sum
    always @(*) begin
        sum = {SUM_WIDTH{1'b0}};
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
            sum = sum + window[i];
        end
    end
    
    // Divide by WINDOW_SIZE (right shift)
    assign data_out = sum >> SHIFT_AMOUNT;

endmodule
