`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors - Parametric FIFO module
    parameter DEPTH = 4,
    parameter DATA_W = 8,
    parameter INPUT1_1 = 8'hAA,
    parameter INPUT1_2 = 8'h55,
    parameter INPUT1_3 = 8'hFF
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg push_i;
reg [DATA_W-1:0] push_data_i;
reg pop_i;
wire [DATA_W-1:0] pop_data_o;
wire full_o;
wire empty_o;

// Expected outputs
reg expected_full;
reg expected_empty;
reg [DATA_W-1:0] expected_pop_data;

int ERR_COUNT = 0;

//DUT instantiation
sync_fifo #(
    .DEPTH(DEPTH),
    .DATA_W(DATA_W)
) DUT (
    .clk(clk),
    .reset(reset),
    .push_i(push_i),
    .push_data_i(push_data_i),
    .pop_i(pop_i),
    .pop_data_o(pop_data_o),
    .full_o(full_o),
    .empty_o(empty_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Golden model for FIFO
localparam PTR_W = $clog2(DEPTH);
reg [PTR_W:0] rd_ptr_golden;
reg [PTR_W:0] wr_ptr_golden;
reg [DATA_W-1:0] fifo_mem_golden [DEPTH-1:0];

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rd_ptr_golden <= {PTR_W+1{1'b0}};
        wr_ptr_golden <= {PTR_W+1{1'b0}};
    end else begin
        // Handle push and pop operations
        case ({push_i & ~full_o, pop_i & ~empty_o})
            2'b01: begin // Pop only
                rd_ptr_golden <= rd_ptr_golden + 1;
            end
            2'b10: begin // Push only
                fifo_mem_golden[wr_ptr_golden[PTR_W-1:0]] <= push_data_i;
                wr_ptr_golden <= wr_ptr_golden + 1;
            end
            2'b11: begin // Both push and pop
                fifo_mem_golden[wr_ptr_golden[PTR_W-1:0]] <= push_data_i;
                rd_ptr_golden <= rd_ptr_golden + 1;
                wr_ptr_golden <= wr_ptr_golden + 1;
            end
        endcase
    end
end

always @(*) begin
    expected_full = (wr_ptr_golden[PTR_W] != rd_ptr_golden[PTR_W]) &&
                    (wr_ptr_golden[PTR_W-1:0] == rd_ptr_golden[PTR_W-1:0]);
    expected_empty = (wr_ptr_golden == rd_ptr_golden);
    expected_pop_data = fifo_mem_golden[rd_ptr_golden[PTR_W-1:0]];
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    push_i = 0;
    push_data_i = 8'h00;
    pop_i = 0;
    #20;

    reset = 0;
    #10;

    // Test 1: Check empty condition
    #10;

    // Test 2: Push some data
    push_data_i = INPUT1_1; // 0xAA
    push_i = 1;
    #10;
    push_i = 0;
    #10;

    push_data_i = INPUT1_2; // 0x55
    push_i = 1;
    #10;
    push_i = 0;
    #10;

    push_data_i = INPUT1_3; // 0xFF
    push_i = 1;
    #10;
    push_i = 0;
    #10;

    // Test 3: Fill FIFO to full
    push_data_i = 8'h33;
    push_i = 1;
    #10;
    push_i = 0;
    #10;

    // Test 4: Try to push when full (should be ignored)
    push_data_i = 8'h99;
    push_i = 1;
    #10;
    push_i = 0;
    #10;

    // Test 5: Pop data
    pop_i = 1;
    #10;
    pop_i = 0;
    #10;

    pop_i = 1;
    #10;
    pop_i = 0;
    #10;

    // Test 6: Simultaneous push and pop
    push_data_i = 8'h77;
    push_i = 1;
    pop_i = 1;
    #10;
    push_i = 0;
    pop_i = 0;
    #10;

    // Test 7: Empty the FIFO
    pop_i = 1;
    #10;
    pop_i = 0;
    #10;

    pop_i = 1;
    #10;
    pop_i = 0;
    #10;

    // Test 8: Try to pop when empty
    pop_i = 1;
    #10;
    pop_i = 0;
    #10;

    check_result;
end

// Continuous checking
always @(posedge clk) begin
    #1; // Small delay to allow outputs to settle
    if(expected_full !== full_o || expected_empty !== empty_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns full_o=%b (exp=%b), empty_o=%b (exp=%b)",
               $time, full_o, expected_full, empty_o, expected_empty);
    end else begin
        $display("%0tns push_i=%b, pop_i=%b, full_o=%b, empty_o=%b, pop_data_o=%h",
                 $time, push_i, pop_i, full_o, empty_o, pop_data_o);
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