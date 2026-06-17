`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors

    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns
    localparam CLK_PERIOD = 10; //ns

reg clock = 0;
reg reset = 0;
reg serial_in = 0;
wire [7:0] parallel_out;
reg [7:0] expected_parallel_out;

int ERR_COUNT = 0;

//DUT instantiation
serial_in_parallel_out DUT(
    .clock(clock),         // Clock input
    .reset(reset),         // Reset input
    .serial_in(serial_in), // Serial input
    .parallel_out(parallel_out) // 8-bit parallel output
);

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    serial_in = 0;
    # (2*CLK_PERIOD);
    reset = 0;

    // Test serial input sequence
    serial_in = 1;
    # (CLK_PERIOD);
    serial_in = 0;
    # (CLK_PERIOD);
    serial_in = 1;
    # (CLK_PERIOD);
    serial_in = 0;
    # (CLK_PERIOD);
    serial_in = 1;
    # (CLK_PERIOD);
    serial_in = 1;
    # (CLK_PERIOD);
    serial_in = 0;
    # (CLK_PERIOD);
    serial_in = 1;
    # (CLK_PERIOD);

    check_result;
end

// Clock generation
always #(CLK_PERIOD/2) clock = ~clock;

// Golden solution
reg [7:0] shift_register;
always @(posedge clock or posedge reset) begin
    if (reset) begin
        shift_register <= 8'b00000000; // Reset the shift register to all zeros
    end else begin
        // Shift the data in on the rising edge of the clock
        shift_register <= {shift_register[6:0], serial_in};
    end
end

assign expected_parallel_out = shift_register;

// Check DUT output against expected value
always @(posedge clock) begin
   #1; // small delay to allow DUT output to stabilize
   if (parallel_out !== expected_parallel_out) begin
         $error("Mismatch at time %0t: expected %b, got %b", $time, expected_parallel_out, parallel_out);
         ERR_COUNT = ERR_COUNT + 1;
   end else begin
         $display("Match at time %0t: parallel_out = %b", $time, parallel_out);
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