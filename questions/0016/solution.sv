module self_reload_counter (
  input     wire          clk,
  input     wire          reset,
  input     wire          load_i,
  input     wire[3:0]     load_val_i,

  output    wire[3:0]     count_o
);

reg [3:0] count_reg;
reg [3:0] reload_val;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count_reg <= 4'h0;
        reload_val <= 4'h0;
    end else if (load_i) begin
        count_reg <= load_val_i;
        reload_val <= load_val_i;
    end else if (count_reg == 4'hF) begin
        count_reg <= reload_val;
    end else begin
        count_reg <= count_reg + 1'b1;
    end
end

assign count_o = count_reg;

endmodule
