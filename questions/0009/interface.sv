module edge_detector (
  input     wire    clk,
  input     wire    reset,

  input     wire    a_i,

  output    wire    rising_edge_o,
  output    wire    falling_edge_o
);

  reg rising_edge_reg  ;
  reg falling_edge_reg ;

  reg prev_ai_reg ;


  `define ASYNC_DETECTION

  `ifdef SYNC_DETECTION
  assign rising_edge_o  = rising_edge_reg ;
  assign falling_edge_o = falling_edge_reg ;
  always_ff @( posedge clk, posedge reset ) begin : blockName
    if(reset) begin
      rising_edge_reg   <= 1'b0 ;
      falling_edge_reg  <= 1'b0 ;
      prev_ai_reg       <= 1'b0 ;
    end else begin
      prev_ai_reg       <= a_i ;
      rising_edge_reg   <=  a_i  & !prev_ai_reg ;
      falling_edge_reg  <= !a_i  &  prev_ai_reg ;
    end
  end
  `elsif ASYNC_DETECTION
  always_ff @( posedge clk, posedge reset ) begin : blockName
    if(reset) begin
      prev_ai_reg       <= 1'b0 ;
    end else begin
      prev_ai_reg       <= a_i ;
    end
  end
  assign rising_edge_o   =  a_i   & !prev_ai_reg ;
  assign falling_edge_o  =  !a_i  &  prev_ai_reg ;
  `endif

endmodule