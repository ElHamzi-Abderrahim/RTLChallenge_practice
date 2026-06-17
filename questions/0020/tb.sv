`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter NUM_PORTS = 4,
    parameter INPUT1_1 = 4'b0001,
    parameter INPUT1_2 = 4'b1111,
    parameter INPUT1_3 = 4'b0110
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [NUM_PORTS-1:0] req_i;
wire [NUM_PORTS-1:0] gnt_o;
reg [NUM_PORTS-1:0] expected_gnt;

integer ERR_COUNT = 0;

//DUT instantiation
priority_arbiter #(
    .NUM_PORTS(NUM_PORTS)
) DUT (
    .req_i(req_i),
    .gnt_o(gnt_o)
);

// Golden model - priority arbiter logic
integer i;
always @(*) begin
    expected_gnt = {NUM_PORTS{1'b0}};  // Initialize to all zeros
    for (i = 0; i < NUM_PORTS; i = i + 1) begin
        if (req_i[i]) begin
            expected_gnt[i] = 1'b1;
            i = NUM_PORTS;  // Break out of loop - found highest priority
        end
    end
end

// stimulus/test sequence
initial begin
    // Test 1: No requests
    req_i = 4'b0000;
    #20;

    // Test 2: Single request port 0 (highest priority)
    req_i = INPUT1_1; // 4'b0001
    #20;

    // Test 3: All ports request (should grant to port 0)
    req_i = INPUT1_2; // 4'b1111
    #20;

    // Test 4: Ports 1 and 2 request (should grant to port 1)
    req_i = INPUT1_3; // 4'b0110
    #20;

    // Additional test cases
    // Test 5: Only port 3 requests
    req_i = 4'b1000;
    #20;

    // Test 6: Ports 0 and 3 request (should grant to port 0)
    req_i = 4'b1001;
    #20;

    // Test 7: Only port 2 requests
    req_i = 4'b0100;
    #20;

    // Test 8: Ports 2 and 3 request (should grant to port 2)
    req_i = 4'b1100;
    #20;

    check_result;
end

// Continuous checking
always @(req_i) begin
    #1; // Small delay to allow outputs to settle
    if(expected_gnt !== gnt_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns req_i = %b, gnt_o = %b, expected = %b",
               $time, req_i, gnt_o, expected_gnt);
    end else begin
        $display("%0tns req_i = %b, gnt_o = %b", $time, req_i, gnt_o);
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
