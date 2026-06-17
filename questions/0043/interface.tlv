\m5_TLV_version 1d: tl-x.org
\SV

module leading_zero_counter #(
    parameter INPUT_WIDTH = 8,
    parameter COUNT_WIDTH = 4
)(
    input wire [INPUT_WIDTH-1:0] data_in,
    output wire [COUNT_WIDTH-1:0] zero_count,
    output wire all_zero
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
