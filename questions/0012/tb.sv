`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors
    // Clock and reset generation
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns
    localparam CLK_PERIOD = 10; // 100 MHz clock

reg clk;
reg reset;
reg x_i;
wire [3:0] sr_o;

// Expected outputs from golden model
reg [3:0] exp_sr_o;

int ERR_COUNT = 0;

//DUT instantiation
shift_register DUT (
    .clk(clk),
    .reset(reset),
    .x_i(x_i),
    .sr_o(sr_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// stimulus/test sequence
initial begin
    // Initialize signals
    reset = 1;
    x_i = 0;
    exp_sr_o = 4'b0000;

    // Hold reset for a few cycles
    repeat(3) @(posedge clk);
    reset = 0;

    // Test shifting in a pattern: 1101
    test_shift_sequence(4'b1101);

    // Test shifting in all zeros
    test_shift_sequence(4'b0000);

    // Test shifting in all ones
    test_shift_sequence(4'b1111);

    // Test shifting in alternating pattern
    test_shift_sequence(4'b1010);

    // Test reset functionality during operation
    x_i = 1;
    @(posedge clk);
    reset = 1;
    @(posedge clk);
    exp_sr_o = 4'b0000; // Reset value
    reset = 0;

    // Continue with more test patterns
    test_shift_sequence(4'b0110);

    check_result;
end 

// Golden model for shift register
always @(posedge clk or posedge reset) begin
    if (reset)
        exp_sr_o <= 4'b0000;
    else
        exp_sr_o <= {exp_sr_o[2:0], x_i}; // Shift left, new bit at LSB
end

// Task to test shifting in a specific sequence
task test_shift_sequence(input [3:0] pattern);
    integer i;
    begin
        $display("Testing pattern: %b", pattern);
        for (i = 3; i >= 0; i = i - 1) begin
            x_i = pattern[i]; // Shift in MSB first
            @(posedge clk);
            #1; // Small delay for checking
            if (exp_sr_o !== sr_o) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns sr_o = %b, expected = %b (x_i = %b)",
                       $time, sr_o, exp_sr_o, x_i);
            end else begin
                $display("%0tns sr_o = %b, x_i = %b", $time, sr_o, x_i);
            end
        end
    end
endtask

// Continuous checking
initial begin
    @(posedge clk); // Wait for first clock edge
    forever begin
        @(posedge clk);
        #1; // Small delay to allow outputs to settle

        if(exp_sr_o !== sr_o) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("%0tns sr_o = %b, expected = %b", $time, sr_o, exp_sr_o);
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
