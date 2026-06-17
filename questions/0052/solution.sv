module parity_gen_check #(
    parameter DATA_WIDTH  = 8,
    parameter PARITY_TYPE = 0  // 0 = even, 1 = odd
)(
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire                  mode,       // 0 = generate, 1 = check
    input  wire                  parity_in,  // input parity (for check mode)
    output wire                  parity_out, // generated parity (for generate mode)
    output wire                  error       // error flag (for check mode)
);

wire data_parity;

// XOR all data bits to get even parity
assign data_parity = ^data_in;

// Generate mode: output parity bit
// Even parity: parity_out = data_parity
// Odd parity:  parity_out = ~data_parity
assign parity_out = (PARITY_TYPE == 0) ? data_parity : ~data_parity;

// Check mode: verify parity
// For even parity: XOR of all bits including parity_in should be 0
// For odd parity:  XOR of all bits including parity_in should be 1
wire check_result;
assign check_result = data_parity ^ parity_in;

// error = 1 if parity check fails
assign error = (PARITY_TYPE == 0) ? check_result : ~check_result;

endmodule
