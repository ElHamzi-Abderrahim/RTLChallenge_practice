module odd_counter (
  input     wire        clk,
  input     wire        reset,

  output    reg [7:0]  cnt_o
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cnt_o <= 8'h01;
    end else begin
        cnt_o <= cnt_o + 2'd2;
    end
end

endmodule
