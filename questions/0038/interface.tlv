\m5_TLV_version 1d: tl-x.org
\SV

module debounce #(
    parameter CLK_FREQ = 50000000,
    parameter DEBOUNCE_TIME_MS = 20
)(
    input wire clk,
    input wire reset,
    input wire button_in,
    output wire button_out
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
