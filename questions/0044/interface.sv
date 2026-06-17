module thermometer_to_binary #(
    parameter THERMO_WIDTH = 7,
    parameter BINARY_WIDTH = 3
)(
    input  wire [THERMO_WIDTH-1:0]     thermo_in,
    output wire [BINARY_WIDTH-1:0]     binary_out,
    output wire                        valid
);
// your implementation here

endmodule