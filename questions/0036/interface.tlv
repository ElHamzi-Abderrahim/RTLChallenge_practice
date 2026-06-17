\m5_TLV_version 1d: tl-x.org
\SV

module pwm_generator #(
    parameter COUNTER_WIDTH = 8,
    parameter PWM_PERIOD = 256
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [COUNTER_WIDTH-1:0] duty_cycle,
    output wire pwm_out
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
