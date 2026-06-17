\m5_TLV_version 1d: tl-x.org
\SV

module gray_counter #(
    parameter WIDTH = 4
)(
    input wire clk,
    input wire reset,
    input wire enable,
    output wire [WIDTH-1:0] gray_count,
    output wire [WIDTH-1:0] binary_count
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
