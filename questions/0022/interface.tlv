\m5_TLV_version 1d: tl-x.org
\SV

module stopwatch_timer (
    input wire clk,
    input wire reset,
    input wire start,
    input wire clear,
    output wire [5:0] minutes,
    output wire [5:0] seconds,
    output wire [3:0] tenths,
    output wire running
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
