\m5_TLV_version 1d: tl-x.org
\SV

module parity_gen_check #(
    parameter DATA_WIDTH = 8,
    parameter PARITY_TYPE = 0
)(
    input wire [DATA_WIDTH-1:0] data_in,
    input wire mode,
    input wire parity_in,
    output wire parity_out,
    output wire error
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
