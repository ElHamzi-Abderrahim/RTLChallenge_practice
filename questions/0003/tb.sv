`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter COUNTER_WIDTH = 4
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg rst_n;
wire [COUNTER_WIDTH-1:0] count_out;
reg [COUNTER_WIDTH-1:0] expected_out;

int ERR_COUNT = 0;
int cycle_count = 0;

//DUT instantiation
   ring_counter #(
      .COUNTER_WIDTH(COUNTER_WIDTH)
   ) DUT (
      .clk(clk),
      .rst_n(rst_n),
      .count_out(count_out)
   );

// Clock generation
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    rst_n = 0;
    cycle_count = 0;
    #25;
    rst_n = 1;

    // Test for multiple cycles (2*(2^COUNTER_WIDTH))
    repeat(2*(1 << COUNTER_WIDTH)) begin
        @(posedge clk);
        cycle_count = cycle_count + 1;
    end

    check_result;
end

// golden solution
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        expected_out <= 1;
    end else begin
        expected_out <= {expected_out[COUNTER_WIDTH-2:0], expected_out[COUNTER_WIDTH-1]};
    end
end

// Check results
always @(posedge clk) begin
    if (rst_n) begin
        #1; // Small delay for signal propagation
        if(count_out !== expected_out) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Cycle %0d: count_out = %b, expected = %b", $time, cycle_count, count_out, expected_out);
        end else begin
            $display("%0tns Cycle %0d: count_out = %b", $time, cycle_count, count_out);
        end
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