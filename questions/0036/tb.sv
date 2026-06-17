`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter COUNTER_WIDTH = 6,
    parameter PWM_PERIOD = 16
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg enable;
reg [COUNTER_WIDTH-1:0] duty_cycle;
wire pwm_out;

int ERR_COUNT = 0;

//DUT instantiation
   pwm_generator #(
      .COUNTER_WIDTH(COUNTER_WIDTH),
      .PWM_PERIOD(PWM_PERIOD)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .enable(enable),
      .duty_cycle(duty_cycle),
      .pwm_out(pwm_out)
   );

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test sequence
initial begin
    // Initialize
    reset = 1;
    enable = 0;
    duty_cycle = 0;

    // Reset sequence
    repeat(3) @(posedge clk);
    reset = 0;
    enable = 1;

    // Test different duty cycles
    test_duty_cycle(0);   // 0% duty cycle
    test_duty_cycle(4);   // 25% duty cycle
    test_duty_cycle(8);   // 50% duty cycle
    test_duty_cycle(12);  // 75% duty cycle
    test_duty_cycle(16);  // 100% duty cycle

    // Test edge cases
    test_duty_cycle(1);   // Minimum non-zero
    test_duty_cycle(15);  // Maximum less than period

    check_result;
end

// Task to test a specific duty cycle
task test_duty_cycle(input [COUNTER_WIDTH-1:0] test_duty);
    real actual_duty;
    real expected_duty;
    int local_high_count;
    int i;
    begin
        $display("Testing duty cycle: %0d/%0d", test_duty, PWM_PERIOD);

        duty_cycle = test_duty;

        // Wait for any ongoing period to complete
        @(posedge clk);
        @(posedge clk);

        // Count high cycles over exactly one PWM period
        local_high_count = 0;
        for (i = 0; i < PWM_PERIOD; i = i + 1) begin
            @(posedge clk);
            if (pwm_out) begin
                local_high_count = local_high_count + 1;
            end
        end

        // Verify duty cycle
        actual_duty = (local_high_count * 100.0) / PWM_PERIOD;
        expected_duty = (test_duty * 100.0) / PWM_PERIOD;

        if (test_duty == 0) begin
            if (local_high_count != 0) begin
                ERR_COUNT++;
                $error("Duty cycle %0d: Expected 0 high cycles, got %0d", test_duty, local_high_count);
            end
        end else if (test_duty >= PWM_PERIOD) begin
            if (local_high_count != PWM_PERIOD) begin
                ERR_COUNT++;
                $error("Duty cycle %0d: Expected %0d high cycles, got %0d", test_duty, PWM_PERIOD, local_high_count);
            end
        end else begin
            if (local_high_count != test_duty) begin
                ERR_COUNT++;
                $error("Duty cycle %0d: Expected %0d high cycles, got %0d", test_duty, test_duty, local_high_count);
            end
        end

        $display("  Actual duty cycle: %.1f%%, Expected: %.1f%%", actual_duty, expected_duty);
    end
endtask

// Monitor PWM output
always @(posedge clk) begin
    if (reset) begin
        // Check reset behavior (allow X initially)
        #1;
        if (pwm_out !== 1'b0 && pwm_out !== 1'bx) begin
            ERR_COUNT++;
            $error("PWM output should be 0 during reset, got %b", pwm_out);
        end
    end else if (!enable) begin
        // Check disable behavior
        #1;
        if (pwm_out !== 1'b0) begin
            ERR_COUNT++;
            $error("PWM output should be 0 when disabled, got %b", pwm_out);
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