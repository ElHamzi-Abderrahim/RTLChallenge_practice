module arp_detector (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_sof,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_is_request,
    output wire [31:0] out_sender_ip,
    output wire [31:0] out_target_ip
);

    // Your implementation here...

endmodule
