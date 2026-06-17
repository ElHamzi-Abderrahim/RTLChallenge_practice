module d_flip_flop (
  input     wire      clk,
  input     wire      reset,

  input     wire      d_i, // D input to the flop

  output    reg       q_norst_o, // Q output from non-resettable flop
  output    reg       q_syncrst_o, // Q output from flop using synchronous reset
  output    reg       q_asyncrst_o // Q output from flop using asynchrnoous reset
);

// your implementation here

endmodule