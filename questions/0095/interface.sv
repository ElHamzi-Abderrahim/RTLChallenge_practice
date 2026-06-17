module pkt_len_validator (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_last,
    input  wire [15:0] hdr_total_len,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_len_ok,
    output wire [15:0] out_actual_len
);

    // Your implementation here...

endmodule
