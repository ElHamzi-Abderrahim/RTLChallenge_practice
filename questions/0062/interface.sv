module gcd_calc #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_a,
    input  wire [DATA_WIDTH-1:0] in_b,
    input  wire                  out_ready,
    output wire                  in_ready,
    output wire                  out_valid,
    output wire [DATA_WIDTH-1:0] out_gcd
);
// your implementation here

endmodule
