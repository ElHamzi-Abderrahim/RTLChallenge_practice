`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter DATA_1 = 8'hAA,
    parameter DATA_2 = 8'h55,
    parameter DATA_3 = 8'hFF,
    parameter DATA_4 = 8'h00,
    parameter DATA_5 = 8'hF0
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg rst_n;
reg [DATA_WIDTH-1:0] data_in;
wire [DATA_WIDTH-1:0] data_out;
reg [DATA_WIDTH-1:0] expected_out;

int ERR_COUNT = 0;
int test_cycle = 0;

//DUT instantiation
   dual_edge_dff #(
      .DATA_WIDTH(DATA_WIDTH)
   ) DUT (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(data_in),
      .data_out(data_out)
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
    data_in = 0;
    test_cycle = 0;
    #25;
    rst_n = 1;

    // Test with different data values
    test_data_input(DATA_1);
    test_data_input(DATA_2);
    test_data_input(DATA_3);
    test_data_input(DATA_4);
    test_data_input(DATA_5);

    #40;
    check_result;
end

// Task to test data input on both edges
task test_data_input(input [DATA_WIDTH-1:0] test_data);
    // Set data and wait for rising edge
    data_in = test_data;
    @(posedge clk);
    test_cycle=test_cycle + 1;
    #1; // Small delay for signal propagation

    // Change data and wait for falling edge
    data_in = ~test_data;
    @(negedge clk);
    test_cycle=test_cycle + 1;
    #1; // Small delay for signal propagation
endtask

// Golden model - dual edge behavior
always @(posedge clk or negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        expected_out <= 0;
    end else begin
        expected_out <= data_in;
    end
end

// Check results on both edges
always @(posedge clk or negedge clk) begin
    if (rst_n) begin
        #1; // Small delay for signal propagation
        if(data_out !== expected_out) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns Test cycle %0d: data_out = %h, expected = %h", $time, test_cycle, data_out, expected_out);
        end else begin
            $display("%0tns Test cycle %0d: data_out = %h", $time, test_cycle, data_out);
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