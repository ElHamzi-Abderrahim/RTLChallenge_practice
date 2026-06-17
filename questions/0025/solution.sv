module sync_fifo #(
  parameter DEPTH   = 4,
  parameter DATA_W  = 1
)(
  input         wire              clk,
  input         wire              reset,

  input         wire              push_i,
  input         wire[DATA_W-1:0]  push_data_i,

  input         wire              pop_i,
  output        wire[DATA_W-1:0]  pop_data_o,

  output        wire              full_o,
  output        wire              empty_o
);

localparam PTR_W = $clog2(DEPTH);

reg [PTR_W:0] rd_ptr_q;
reg [PTR_W:0] wr_ptr_q;
reg [DATA_W-1:0] fifo_mem [0:DEPTH-1];

// Pointer updates
always @(posedge clk or posedge reset) begin
    if (reset) begin
        rd_ptr_q <= {(PTR_W+1){1'b0}};
        wr_ptr_q <= {(PTR_W+1){1'b0}};
    end else begin
        if (push_i && !full_o) begin
            wr_ptr_q <= wr_ptr_q + 1'b1;
        end
        if (pop_i && !empty_o) begin
            rd_ptr_q <= rd_ptr_q + 1'b1;
        end
    end
end

// FIFO memory write
always @(posedge clk) begin
    if (push_i && !full_o) begin
        fifo_mem[wr_ptr_q[PTR_W-1:0]] <= push_data_i;
    end
end

// Status flags
assign full_o = (rd_ptr_q[PTR_W] != wr_ptr_q[PTR_W]) &&
                (rd_ptr_q[PTR_W-1:0] == wr_ptr_q[PTR_W-1:0]);
assign empty_o = (rd_ptr_q[PTR_W:0] == wr_ptr_q[PTR_W:0]);

// Pop data output
assign pop_data_o = fifo_mem[rd_ptr_q[PTR_W-1:0]];

endmodule
