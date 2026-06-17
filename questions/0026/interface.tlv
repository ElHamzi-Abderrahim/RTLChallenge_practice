\m5_TLV_version 1d: tl-x.org
\SV

module seven_segment_driver #(
    parameter ACTIVE_HIGH = 1
)(
    input wire [3:0] bcd_digit,
    input wire enable,
    output wire [6:0] segments,
    output wire digit_valid
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
