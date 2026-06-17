module edge_detector (
  input     wire    clk,
  input     wire    reset,

  input     wire    a_i,

  output    wire    rising_edge_o,
  output    wire    falling_edge_o
);

reg a_prev;

always @(posedge clk) begin
    if (reset) begin
        a_prev <= 1'b0;
    end else begin
        a_prev <= a_i;
    end
end

assign rising_edge_o = a_i & ~a_prev;
assign falling_edge_o = ~a_i & a_prev;

endmodule
