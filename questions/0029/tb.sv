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
reg load = 0;
reg shift_left = 0;
reg shift_right = 0;
reg serial_in = 0;
reg enable = 1;
wire [3:0] q;
reg [3:0] expected_q;

int ERR_COUNT = 0;

//DUT instantiation
Universal_Shift_Register DUT(
    .clk(clk),         // Clock input
    .reset(reset),     // Reset input
    .load(load),       // Load input
    .shift_left(shift_left), // Shift left input
    .shift_right(shift_right), // Shift right input
    .serial_in(serial_in),  // Serial input
    .enable(enable),   // Enable input
    .q(q)              // 4-bit output
);

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    load = 0;
    shift_left = 0;
    shift_right = 0;
    serial_in = 0;
    enable = 1;
    # (2*CLK_PERIOD);
    reset = 0;

    // Test parallel load
    load = 1;
    serial_in = 1; // Load value 1 (but should load 4'b0001 based on spec)
    $display("%0tns Loading serial_in = %b", $time, serial_in);
    # (CLK_PERIOD);
    load = 0;
    $display("%0tns Loaded serial_in = %b", $time, serial_in);
    # (CLK_PERIOD);

    // Test shift left
    shift_left = 1;
    shift_right = 0;
    $display("%0tns Shifting left", $time);
    # (3*CLK_PERIOD);
    shift_left = 0;
    $display("%0tns Stopped shifting left", $time);

    // Test shift right
    shift_right = 1;
    shift_left = 0;
    $display("%0tns Shifting right", $time);
    # (3*CLK_PERIOD);
    shift_right = 0;
    $display("%0tns Stopped shifting right", $time);

    check_result;
end

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

// Golden solution
reg [3:0] data_reg;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_reg <= 4'b0000; // Reset to all zeros
    end else if (load) begin
        data_reg <= {3'b000, serial_in}; // Load serial_in as LSB
    end else if (enable) begin
        if (shift_left) begin
            data_reg <= {data_reg[2:0], data_reg[3]}; // Shift left (circular)
        end else if (shift_right) begin
            data_reg <= {data_reg[0], data_reg[3:1]}; // Shift right (circular)
        end
    end
end

assign expected_q = data_reg;

// Check DUT output against expected value
always @(posedge clk) begin
   #1; // small delay to allow DUT output to stabilize
   if (q !== expected_q) begin
         $error("Mismatch at time %0t: expected %b, got %b", $time, expected_q, q);
         ERR_COUNT = ERR_COUNT + 1;
   end else begin
         $display("%tns: Output q is matched expectedly: q = %b", $time, q);
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