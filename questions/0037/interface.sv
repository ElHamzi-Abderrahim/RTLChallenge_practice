module uart_transmitter #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        tx_start,
    input  wire [7:0]  tx_data,
    output wire        tx_out,
    output wire        tx_busy,
    output wire        tx_done
);
// your implementation here

endmodule