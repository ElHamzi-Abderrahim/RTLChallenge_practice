`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors - No parameters for this module
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg [3:0] req_i;
wire [3:0] gnt_o;

// Expected outputs
reg [3:0] expected_gnt;

int ERR_COUNT = 0;

//DUT instantiation
round_robin_arbiter DUT (
    .clk(clk),
    .reset(reset),
    .req_i(req_i),
    .gnt_o(gnt_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Golden model for round robin arbiter
reg [1:0] last_granted_golden;
reg [3:0] gnt_golden;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        last_granted_golden <= 2'b11; // Start before port 0
        expected_gnt = 4'b0000;
    end else begin
        // Update last granted port
        expected_gnt = gnt_golden;
        if (gnt_golden[0]) last_granted_golden <= 2'd0;
        else if (gnt_golden[1]) last_granted_golden <= 2'd1;
        else if (gnt_golden[2]) last_granted_golden <= 2'd2;
        else if (gnt_golden[3]) last_granted_golden <= 2'd3;
    end
end

// Round robin arbitration logic
always @(*) begin
    gnt_golden = 4'b0000;

    if (|req_i) begin
        // Check for requests starting from next port after last granted
        case (last_granted_golden)
            2'd0: begin
                if (req_i[1]) gnt_golden[1] = 1'b1;
                else if (req_i[2]) gnt_golden[2] = 1'b1;
                else if (req_i[3]) gnt_golden[3] = 1'b1;
                else if (req_i[0]) gnt_golden[0] = 1'b1;
            end
            2'd1: begin
                if (req_i[2]) gnt_golden[2] = 1'b1;
                else if (req_i[3]) gnt_golden[3] = 1'b1;
                else if (req_i[0]) gnt_golden[0] = 1'b1;
                else if (req_i[1]) gnt_golden[1] = 1'b1;
            end
            2'd2: begin
                if (req_i[3]) gnt_golden[3] = 1'b1;
                else if (req_i[0]) gnt_golden[0] = 1'b1;
                else if (req_i[1]) gnt_golden[1] = 1'b1;
                else if (req_i[2]) gnt_golden[2] = 1'b1;
            end
            2'd3: begin
                if (req_i[0]) gnt_golden[0] = 1'b1;
                else if (req_i[1]) gnt_golden[1] = 1'b1;
                else if (req_i[2]) gnt_golden[2] = 1'b1;
                else if (req_i[3]) gnt_golden[3] = 1'b1;
            end
        endcase
    end
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    req_i = 4'b0000;
    #20;

    reset = 0;
    #10;

    // Test 1: Single request port 0
    req_i = 4'b0001;
    #20;

    // Test 2: Single request port 1 (should grant since port 0 was last)
    req_i = 4'b0010;
    #20;

    // Test 3: All ports request - should grant port 2 (next after port 1)
    req_i = 4'b1111;
    #20;

    // Test 4: Ports 0,1 request - should grant port 0 (next after port 2)
    req_i = 4'b0011;
    #20;

    // Test 5: Only port 3 requests
    req_i = 4'b1000;
    #20;

    // Test 6: Ports 1,2 request - should grant port 1 (next after port 3)
    req_i = 4'b0110;
    #20;

    // Test 7: No requests
    req_i = 4'b0000;
    #20;

    // Test 8: Restart with port 3 - should grant port 2 (next after port 1)
    req_i = 4'b1100;
    #20;

    check_result;
end

// Continuous checking
always @(posedge clk) begin
    #1; // Small delay to allow outputs to settle
    if(expected_gnt !== gnt_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns req_i = %b, gnt_o = %b, expected = %b, last_granted = %d",
               $time, req_i, gnt_o, expected_gnt, last_granted_golden);
    end else begin
        $display("%0tns req_i = %b, gnt_o = %b, last_granted = %d", $time, req_i, gnt_o, last_granted_golden);
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