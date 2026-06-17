\m5_TLV_version 1d: tl-x.org
\SV

module traffic_light_controller #(
    parameter CLK_FREQ = 1000,
    parameter GREEN_TIME_SEC = 10,
    parameter YELLOW_TIME_SEC = 3,
    parameter RED_TIME_SEC = 2
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire emergency,
    output wire ns_red,
    output wire ns_yellow,
    output wire ns_green,
    output wire ew_red,
    output wire ew_yellow,
    output wire ew_green
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
