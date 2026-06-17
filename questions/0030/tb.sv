`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors

    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns
    localparam CLK_PERIOD = 10; //ns

reg clk = 0;
reg reset = 0;
reg push = 0;
reg pop = 0;
reg [7:0] data_in = 0;
wire [7:0] data_out;
reg [7:0] expected_data_out;

int ERR_COUNT = 0;

//DUT instantiation
lifo DUT(
    .clk(clk),             // Clock signal
    .reset(reset),         // Reset signal
    .push(push),           // Push data into the queue
    .pop(pop),             // Pop data from the queue
    .data_in(data_in),     // Data to be pushed into the queue
    .data_out(data_out)    // Data popped from the queue
);

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    push = 0;
    pop = 0;
    data_in = 0;
    # (2*CLK_PERIOD);
    reset = 0;

    // Test push operations
    push = 1;
    data_in = 8'hAA;
    $display("%0tns Pushing data_in = %h", $time, data_in);
    # (CLK_PERIOD);
    data_in = 8'hBB;
    $display("%0tns Pushing data_in = %h", $time, data_in);
    # (CLK_PERIOD);
    data_in = 8'hCC;
    $display("%0tns Pushing data_in = %h", $time, data_in);
    # (CLK_PERIOD);
    data_in = 8'hDD;
    $display("%0tns Pushing data_in = %h", $time, data_in);
    # (CLK_PERIOD);
    // Try to push when full (should be ignored)
    data_in = 8'hEE;
    $display("%0tns Attempting to push data_in = %h when full", $time, data_in);
    # (CLK_PERIOD);
    push = 0;
    $display("%0tns Stopped pushing", $time);

    # (CLK_PERIOD);

    // Test pop operations
    pop = 1;
    $display("%0tns Popping data", $time);
    # (4*CLK_PERIOD);
    // Try to pop when empty (should be ignored)
    $display("%0tns Attempting to pop when empty", $time);
    # (CLK_PERIOD);
    pop = 0;
    $display("%0tns Stopped popping", $time);

    check_result;
end

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

// Golden solution
reg [7:0] queue [3:0];     // LIFO queue with 4 elements
reg [2:0] top;             // Top pointer (3 bits to handle overflow)
reg [7:0] output_data;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        top <= 3'b000;           // Reset top pointer
        queue[0] <= 8'b0;        // Clear all elements in the queue
        queue[1] <= 8'b0;
        queue[2] <= 8'b0;
        queue[3] <= 8'b0;
        output_data <= 8'b0;
    end else begin
        if (push && !pop) begin
            if (top < 3'b100) begin  // Check if not full (top < 4)
                queue[top] <= data_in; // Push data into the queue
                top <= top + 1;        // Increment top pointer for push
            end
        end else if (pop && !push) begin
            if (top > 3'b000) begin  // Check if not empty
                top <= top - 1;         // Decrement top pointer for pop
                output_data <= queue[top-1]; // Pop data from the queue
            end else begin
                output_data <= 8'b0;    // Output 0 when empty
            end
        end else if (push && pop) begin  // Push has priority
            if (top < 3'b100) begin  // Check if not full (top < 4)
                queue[top] <= data_in; // Push data into the queue
                top <= top + 1;        // Increment top pointer for push
            end
        end
    end
end

assign expected_data_out = output_data;

// Check DUT output against expected value
always @(posedge clk) begin
   #1; // small delay to allow DUT output to stabilize
   if (data_out !== expected_data_out) begin
         $error("Mismatch at time %0t: expected %h, got %h", $time, expected_data_out, data_out);
         ERR_COUNT = ERR_COUNT + 1;
   end else begin
         $display("%0tns Output is matched expectedly: data_out = %h", $time, data_out);
   end
end

//do not edit below
task check_result;
begin
   if(ERR_COUNT > 0) begin
      $display("Test failed with %0d errors.", ERR_COUNT);
   end else begin
      $display("Test PASS");
   end
   $finish;
end
endtask

string filename;

initial begin
   if ($value$plusargs("VCDFILE=%s",filename)) begin
      $dumpfile(filename);
      $dumpvars(0, DUT);
   end
end

initial begin
    #(TB_SIM_TIMEOUT)
    $display("Simulation TIMEOUT");
    $finish;
end

endmodule