\m5_TLV_version 1d: tl-x.org
\SV

module hamming_encoder #(
    parameter DATA_BITS = 4,
    parameter PARITY_BITS = 3,
    parameter TOTAL_BITS = 7
)(
    input wire [DATA_BITS-1:0] data_in,
    output wire [TOTAL_BITS-1:0] encoded_out,
    output wire [PARITY_BITS-1:0] parity_bits
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
