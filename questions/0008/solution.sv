module d_flip_flop (
  input     wire      clk,
  input     wire      reset,

  input     wire      d_i, // D input to the flop

  output    reg       q_norst_o, // Q output from non-resettable flop
  output    reg       q_syncrst_o, // Q output from flop using synchronous reset
  output    reg       q_asyncrst_o // Q output from flop using asynchrnoous reset
);

// Non-resettable flip-flop
always @(posedge clk) begin
    q_norst_o <= d_i;
end

// Synchronous reset flip-flop
always @(posedge clk) begin
    if (reset) begin
        q_syncrst_o <= 1'b0;
    end else begin
        q_syncrst_o <= d_i;
    end
end

// Asynchronous reset flip-flop
always @(posedge clk or posedge reset) begin
    if (reset) begin
        q_asyncrst_o <= 1'b0;
    end else begin
        q_asyncrst_o <= d_i;
    end
end

endmodule
