module lifo (
  input wire clk,            // Clock signal
  input wire reset,          // Reset signal
  input wire push,           // Push data into the queue
  input wire pop,            // Pop data from the queue
  input wire [7:0] data_in,  // Data to be pushed into the queue
  output wire [7:0] data_out // Data popped from the queue
);

  reg [7:0] stack [0:3];
  reg [2:0] top;             // 0..4 so a full stack of 4 elements is representable
  reg [7:0] out_reg;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      top      <= 3'b000;
      stack[0] <= 8'h00;
      stack[1] <= 8'h00;
      stack[2] <= 8'h00;
      stack[3] <= 8'h00;
      out_reg  <= 8'h00;
    end else if (push && !pop) begin
      if (top < 3'b100) begin           // not full
        stack[top] <= data_in;
        top        <= top + 1'b1;
      end
    end else if (pop && !push) begin
      if (top > 3'b000) begin           // not empty
        top     <= top - 1'b1;
        out_reg <= stack[top - 1'b1];
      end else begin
        out_reg <= 8'h00;
      end
    end else if (push && pop) begin
      // Push has priority
      if (top < 3'b100) begin
        stack[top] <= data_in;
        top        <= top + 1'b1;
      end
    end
  end

  assign data_out = out_reg;

endmodule
