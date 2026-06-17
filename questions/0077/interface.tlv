\m5_TLV_version 1d: tl-x.org
\SV

module peak_detect #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire in_valid,
    input wire [DATA_WIDTH-1:0] in_data,
    input wire in_last,
    input wire out_ready,
    output wire in_ready,
    output wire out_valid,
    output wire out_is_peak,
    output wire [DATA_WIDTH-1:0] out_value,
    output wire [7:0] out_index
);

\TLV
   // Your TL-Verilog implementation here

\SV
endmodule
