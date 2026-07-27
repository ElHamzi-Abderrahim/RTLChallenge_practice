module sequence_detector #(
    parameter PATTERN = 4'b1011
)(
    input  wire                                clk,
    input  wire                                rst_n,
    input  wire                                data_in,
    output wire                                pattern_detected
);

    `define SYNC_DETECTION
    parameter               pattern_size = 4 ;
    reg                     pattern_detected_reg ; 
    reg [pattern_size-1:0]  capt_window ; 

    // Asserts 'pattern_detected' after one clock cycle after the last bit of the pattern is detected
    `ifdef SYNC_DETECTION
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            pattern_detected_reg <= 1'b0 ;
            capt_window <= {pattern_size{1'b0}};
        end else begin
            capt_window[0] <= data_in ;
            // Shifting capt_window to left
            for (integer i = 1; i < pattern_size; i = i+1) begin
                capt_window[i] <= capt_window[i-1] ;
            end

            if (capt_window == PATTERN) begin
                pattern_detected_reg = 1'b1 ;
            end else begin
                pattern_detected_reg = 1'b0 ;
            end
        end
    end
    assign pattern_detected = pattern_detected_reg;

    // Asserts 'pattern_detected' at the same clock cycle as the last bit of the pattern is detected
    `elsif ASYNC_DETECTION
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            capt_window <= {pattern_size{1'b0}};
        end else begin
            capt_window <= {capt_window[pattern_size-2:0], data_in} ;
        end
    end
    assign pattern_detected = (capt_window == PATTERN) ? 1'b1 : 1'b0 ;
    `endif


endmodule
