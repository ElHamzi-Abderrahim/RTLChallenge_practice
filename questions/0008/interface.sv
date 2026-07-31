module d_flip_flop (
  input     wire      clk,
  input     wire      reset,

  input     wire      d_i, // D input to the flop

  output    reg       q_norst_o, // Q output from non-resettable flop
  output    reg       q_syncrst_o, // Q output from flop using synchronous reset
  output    reg       q_asyncrst_o // Q output from flop using asynchrnoous reset
);


  always_ff @( posedge clk ) begin : dff_norst
    q_norst_o <= d_i ;
  end

  always_ff @( posedge clk ) begin : dff_syncrst
    if (reset) begin
      q_syncrst_o <= 1'b0 ;
    end else begin
      q_syncrst_o <= d_i ;
    end
  end

  always_ff @(posedge clk, posedge reset ) begin: dff_asyncrst
    if (reset) begin
      q_asyncrst_o <= 1'b0 ;
    end else begin
      q_asyncrst_o <= d_i ;
    end
  end

endmodule