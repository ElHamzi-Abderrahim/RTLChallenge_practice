module traffic_light_controller #(
    parameter CLK_FREQ = 1000,
    parameter GREEN_TIME_SEC = 10,
    parameter YELLOW_TIME_SEC = 3,
    parameter RED_TIME_SEC = 2
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        emergency,
    output wire        ns_red,
    output wire        ns_yellow,
    output wire        ns_green,
    output wire        ew_red,
    output wire        ew_yellow,
    output wire        ew_green
);

    localparam GREEN_CYCLES  = CLK_FREQ * GREEN_TIME_SEC;
    localparam YELLOW_CYCLES = CLK_FREQ * YELLOW_TIME_SEC;
    localparam RED_CYCLES    = CLK_FREQ * RED_TIME_SEC;
    localparam COUNTER_WIDTH = $clog2(GREEN_CYCLES + 1);
    
    localparam NS_GREEN_EW_RED   = 3'd0;
    localparam NS_YELLOW_EW_RED  = 3'd1;
    localparam ALL_RED_1         = 3'd2;
    localparam EW_GREEN_NS_RED   = 3'd3;
    localparam EW_YELLOW_NS_RED  = 3'd4;
    localparam ALL_RED_2         = 3'd5;
    
    reg [2:0] state;
    reg [COUNTER_WIDTH-1:0] timer;
    reg ns_red_reg, ns_yellow_reg, ns_green_reg;
    reg ew_red_reg, ew_yellow_reg, ew_green_reg;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= NS_GREEN_EW_RED;
            timer <= {COUNTER_WIDTH{1'b0}};
            ns_red_reg <= 1'b0;
            ns_yellow_reg <= 1'b0;
            ns_green_reg <= 1'b1;
            ew_red_reg <= 1'b1;
            ew_yellow_reg <= 1'b0;
            ew_green_reg <= 1'b0;
        end else if (emergency) begin
            // Emergency mode - all lights red
            ns_red_reg <= 1'b1;
            ns_yellow_reg <= 1'b0;
            ns_green_reg <= 1'b0;
            ew_red_reg <= 1'b1;
            ew_yellow_reg <= 1'b0;
            ew_green_reg <= 1'b0;
            timer <= {COUNTER_WIDTH{1'b0}};
        end else if (enable) begin
            timer <= timer + 1'b1;
            
            case (state)
                NS_GREEN_EW_RED: begin
                    ns_red_reg <= 1'b0;
                    ns_yellow_reg <= 1'b0;
                    ns_green_reg <= 1'b1;
                    ew_red_reg <= 1'b1;
                    ew_yellow_reg <= 1'b0;
                    ew_green_reg <= 1'b0;
                    
                    if (timer >= GREEN_CYCLES - 1) begin
                        state <= NS_YELLOW_EW_RED;
                        timer <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                
                NS_YELLOW_EW_RED: begin
                    ns_red_reg <= 1'b0;
                    ns_yellow_reg <= 1'b1;
                    ns_green_reg <= 1'b0;
                    ew_red_reg <= 1'b1;
                    ew_yellow_reg <= 1'b0;
                    ew_green_reg <= 1'b0;
                    
                    if (timer >= YELLOW_CYCLES - 1) begin
                        state <= ALL_RED_1;
                        timer <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                
                ALL_RED_1: begin
                    ns_red_reg <= 1'b1;
                    ns_yellow_reg <= 1'b0;
                    ns_green_reg <= 1'b0;
                    ew_red_reg <= 1'b1;
                    ew_yellow_reg <= 1'b0;
                    ew_green_reg <= 1'b0;
                    
                    if (timer >= RED_CYCLES - 1) begin
                        state <= EW_GREEN_NS_RED;
                        timer <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                
                EW_GREEN_NS_RED: begin
                    ns_red_reg <= 1'b1;
                    ns_yellow_reg <= 1'b0;
                    ns_green_reg <= 1'b0;
                    ew_red_reg <= 1'b0;
                    ew_yellow_reg <= 1'b0;
                    ew_green_reg <= 1'b1;
                    
                    if (timer >= GREEN_CYCLES - 1) begin
                        state <= EW_YELLOW_NS_RED;
                        timer <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                
                EW_YELLOW_NS_RED: begin
                    ns_red_reg <= 1'b1;
                    ns_yellow_reg <= 1'b0;
                    ns_green_reg <= 1'b0;
                    ew_red_reg <= 1'b0;
                    ew_yellow_reg <= 1'b1;
                    ew_green_reg <= 1'b0;
                    
                    if (timer >= YELLOW_CYCLES - 1) begin
                        state <= ALL_RED_2;
                        timer <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                
                ALL_RED_2: begin
                    ns_red_reg <= 1'b1;
                    ns_yellow_reg <= 1'b0;
                    ns_green_reg <= 1'b0;
                    ew_red_reg <= 1'b1;
                    ew_yellow_reg <= 1'b0;
                    ew_green_reg <= 1'b0;
                    
                    if (timer >= RED_CYCLES - 1) begin
                        state <= NS_GREEN_EW_RED;
                        timer <= {COUNTER_WIDTH{1'b0}};
                    end
                end
                
                default: begin
                    state <= NS_GREEN_EW_RED;
                    timer <= {COUNTER_WIDTH{1'b0}};
                end
            endcase
        end
    end
    
    assign ns_red = ns_red_reg;
    assign ns_yellow = ns_yellow_reg;
    assign ns_green = ns_green_reg;
    assign ew_red = ew_red_reg;
    assign ew_yellow = ew_yellow_reg;
    assign ew_green = ew_green_reg;

endmodule
