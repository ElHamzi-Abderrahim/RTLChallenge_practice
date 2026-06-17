module debounce #(
    parameter CLK_FREQ = 50000000,
    parameter DEBOUNCE_TIME_MS = 20
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        button_in,
    output wire        button_out
);

    localparam DEBOUNCE_CYCLES = (CLK_FREQ * DEBOUNCE_TIME_MS) / 1000;
    localparam COUNTER_WIDTH = $clog2(DEBOUNCE_CYCLES + 1);
    
    reg [COUNTER_WIDTH-1:0] counter;
    reg button_sync1, button_sync2;
    reg button_state;
    
    // Double synchronizer for metastability
    always @(posedge clk) begin
        if (reset) begin
            button_sync1 <= 1'b0;
            button_sync2 <= 1'b0;
        end else begin
            button_sync1 <= button_in;
            button_sync2 <= button_sync1;
        end
    end
    
    // Debounce logic
    always @(posedge clk) begin
        if (reset) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            button_state <= 1'b0;
        end else begin
            if (button_sync2 != button_state) begin
                // Input changed, start/restart counter
                if (counter == DEBOUNCE_CYCLES - 1) begin
                    // Input stable for debounce period
                    button_state <= button_sync2;
                    counter <= {COUNTER_WIDTH{1'b0}};
                end else begin
                    counter <= counter + 1'b1;
                end
            end else begin
                // Input matches current state, reset counter
                counter <= {COUNTER_WIDTH{1'b0}};
            end
        end
    end
    
    assign button_out = button_state;

endmodule
