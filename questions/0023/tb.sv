`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors - No parameters for this module
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 300_000; //ns

reg clk;
reg reset;
reg req_i;
reg req_rnw_i;
reg [3:0] req_addr_i;
reg [31:0] req_wdata_i;
wire req_ready_o;
wire [31:0] req_rdata_o;

// Expected outputs
reg expected_ready;
reg [31:0] expected_rdata;

int ERR_COUNT = 0;

//DUT instantiation
mem_interface DUT (
    .clk(clk),
    .reset(reset),
    .req_i(req_i),
    .req_rnw_i(req_rnw_i),
    .req_addr_i(req_addr_i),
    .req_wdata_i(req_wdata_i),
    .req_ready_o(req_ready_o),
    .req_rdata_o(req_rdata_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Simplified golden model for memory interface
// Note: This doesn't include the complex LFSR and edge detection
// but provides basic memory functionality verification
reg [31:0] golden_memory [15:0];
reg [3:0] delay_counter;
reg req_active;
reg prev_req_i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        delay_counter <= 4'h0;
        req_active <= 1'b0;
        prev_req_i <= 1'b0;
        // Initialize memory
        for (int i = 0; i < 16; i++) begin
            golden_memory[i] <= 32'h0;
        end
    end else begin
        prev_req_i <= req_i;

        // Detect rising edge of req_i
        if (req_i && !prev_req_i) begin
            req_active <= 1'b1;
            delay_counter <= 4'd3; // Simple fixed delay for testing
        end else if (req_active) begin
            if (delay_counter == 4'h0) begin
                // Process memory operation
                if (!req_rnw_i) begin // Write
                    golden_memory[req_addr_i] <= req_wdata_i;
                end
                req_active <= 1'b0;
            end else begin
                delay_counter <= delay_counter - 4'h1;
            end
        end
    end
end

always @(*) begin
    expected_ready = (delay_counter == 4'h0) && !req_active;
    expected_rdata = req_rnw_i ? golden_memory[req_addr_i] : 32'h0;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    req_i = 0;
    req_rnw_i = 0;
    req_addr_i = 4'h0;
    req_wdata_i = 32'h0;
    #20;

    reset = 0;
    #10;

    // Test 1: Write to address 5
    req_addr_i = 4'h5;
    req_wdata_i = 32'hABCD_1234;
    req_rnw_i = 0; // Write
    req_i = 1;
    #10;

    // Wait for write to complete
    wait(req_ready_o);
    req_i = 0;
    #20;

    // Test 2: Read from address 5
    req_addr_i = 4'h5;
    req_rnw_i = 1; // Read
    req_i = 1;
    #10;

    // Wait for read to complete
    wait(req_ready_o);
    req_i = 0;
    #20;

    // Test 3: Write to address 10
    req_addr_i = 4'hA;
    req_wdata_i = 32'h5555_AAAA;
    req_rnw_i = 0; // Write
    req_i = 1;
    #10;

    // Wait for write to complete
    wait(req_ready_o);
    req_i = 0;
    #20;
    

    // Test 4: Read from address 10
    req_addr_i = 4'hA;
    req_rnw_i = 1; // Read
    req_i = 1;
    #10;

    // Wait for read to complete
    wait(req_ready_o);
    req_i = 0;
    #20;

    // Test 5: Read from address 0 (should be 0)
    req_addr_i = 4'h0;
    req_rnw_i = 1; // Read
    req_i = 1;
    #10;

    // Wait for read to complete
    wait(req_ready_o);
    req_i = 0;
    #20;

    check_result;
end

// Continuous checking (simplified for basic functionality)
always @(posedge clk) begin
    #1; // Small delay to allow outputs to settle
    if (req_ready_o && req_rnw_i) begin
        // Check read data when ready and reading
        if (req_rdata_o !== golden_memory[req_addr_i]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns addr=%h, req_rdata_o=%h, expected=%h",
                   $time, req_addr_i, req_rdata_o, golden_memory[req_addr_i]);
        end else begin
            $display("%0tns READ addr=%h, data=%h", $time, req_addr_i, req_rdata_o);
        end
    end else if (req_ready_o && !req_rnw_i && req_active) begin
        $display("%0tns WRITE addr=%h, data=%h", $time, req_addr_i, req_wdata_i);
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
    $error("Simulation TIMEOUT - DUT did not complete");
    $finish;
end

endmodule