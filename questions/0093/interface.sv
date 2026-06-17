module ipv4_checksum (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        in_valid,
    input  wire [15:0] in_data,
    input  wire        in_last,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire [15:0] out_checksum,
    output wire        out_valid_hdr
);

    // Your implementation here...

endmodule
