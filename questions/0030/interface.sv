module lifo (
  input wire clk,            // Clock signal
  input wire reset,          // Reset signal
  input wire push,           // Push data into the queue
  input wire pop,            // Pop data from the queue
  input wire [7:0] data_in,  // Data to be pushed into the queue
  output wire [7:0] data_out // Data popped from the queue
);

// your implementation here

endmodule