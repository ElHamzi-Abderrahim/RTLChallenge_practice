\m5_TLV_version 1d: tl-x.org
\SV

module simple_mux #(
    parameter DATA_WIDTH = 8,
    parameter SELECT_WIDTH = 2
)(
    input wire [DATA_WIDTH*(2**SELECT_WIDTH)-1:0] data_in,
    input wire [SELECT_WIDTH-1:0] select,
    output wire [DATA_WIDTH-1:0] data_out
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
