module pwm_generator #(
    parameter COUNTER_WIDTH = 8,
    parameter PWM_PERIOD = 256
)(
    input  wire                         clk,
    input  wire                         reset,
    input  wire                         enable,
    input  wire [COUNTER_WIDTH-1:0]     duty_cycle,
    output wire                         pwm_out
);

    reg [COUNTER_WIDTH-1:0] counter;
    reg pwm_reg;
    
    always @(posedge clk) begin
        if (reset) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            pwm_reg <= 1'b0;
        end else if (enable) begin
            if (counter == PWM_PERIOD - 1) begin
                counter <= {COUNTER_WIDTH{1'b0}};
            end else begin
                counter <= counter + 1'b1;
            end
            
            // PWM output logic
            if (duty_cycle == 0) begin
                pwm_reg <= 1'b0;
            end else if (duty_cycle >= PWM_PERIOD) begin
                pwm_reg <= 1'b1;
            end else begin
                pwm_reg <= (counter < duty_cycle);
            end
        end else begin
            pwm_reg <= 1'b0;
        end
    end
    
    assign pwm_out = pwm_reg;

endmodule
