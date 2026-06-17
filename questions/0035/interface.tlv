\m5_TLV_version 1d: tl-x.org
\SV

module barrel_shifter #(
    parameter DATA_WIDTH = 8,
    parameter SHIFT_WIDTH = 3
)(
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [SHIFT_WIDTH-1:0] shift_amt,
    input wire shift_dir,
    input wire shift_type,
    output wire [DATA_WIDTH-1:0] data_out
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
