`timescale 1us / 1us

module tb (
    );
    //---------------------------------------------------------
    // Input Vectors - None for this module
    // --------------------------------------------------------

    localparam CLK_FREQ = 100; // 100Hz for faster simulation
    localparam TENTH_SEC_CYCLES = CLK_FREQ / 10; // 10 cycles per 0.1s
    localparam TB_SIM_TIMEOUT = 10000000000; // 1 second in us

reg clk;
reg reset;
reg start;
reg clear;
wire [5:0] minutes;
wire [5:0] seconds;
wire [3:0] tenths;
wire running;

int ERR_COUNT = 0;
int cycle_count = 0;

//DUT instantiation
   stopwatch_timer DUT (
      .clk(clk),
      .reset(reset),
      .start(start),
      .clear(clear),
      .minutes(minutes),
      .seconds(seconds),
      .tenths(tenths),
      .running(running)
   );

// Clock generation - period calculated from CLK_FREQ
// CLK_FREQ = 100 Hz → period = 1/100 = 10ms = 10,000us
localparam CLK_PERIOD_US = 1_000_000 / CLK_FREQ; // Period in microseconds
localparam CLK_HALF_PERIOD_US = CLK_PERIOD_US / 2;

initial begin
    clk = 0;
    forever #(CLK_HALF_PERIOD_US) clk = ~clk;
end

// Test sequence
initial begin
    // Initialize
    reset = 1;
    start = 0;
    clear = 0;

    // Reset sequence
    repeat(5) @(posedge clk);
    reset = 0;
    repeat(2) @(posedge clk);

    // Undriven / empty implementations leave outputs unknown (x) -> fail
    #1;
    if ((^{minutes, seconds, tenths, running}) === 1'bx) begin
        ERR_COUNT++;
        $error("DUT outputs are unknown (x) after reset");
    end

    // Test 1: Basic start/stop functionality
    test_basic_operation();

    // Test 2: Clear functionality
    test_clear_operation();

    // Test 3: Timer accuracy
    test_timing_accuracy();

    // Test 4: Rollover behavior
    test_rollover();

    check_result;
end

// Task to test basic start/stop operation
task test_basic_operation();
    int saved_tenths, saved_seconds, saved_minutes;
    begin
        $display("Test 1: Basic start/stop operation");

        // Check initial state
        if (running || minutes || seconds || tenths) begin
            ERR_COUNT++;
            $error("Initial state should be stopped and zero");
        end

        // Start timer
        @(negedge clk);
        start = 1;
        $display("%0tus Starting timer", $time);
        @(posedge clk);
        #1;
        if (!running) begin
            ERR_COUNT++;
            $error("Timer should be running after start");
        end

        // Let it run for a short time
        repeat(TENTH_SEC_CYCLES * 3) @(posedge clk); // 0.3 seconds
        #1;
        if (tenths != 3) begin
            ERR_COUNT++;
            $error("Expected 3 tenths, got %0d", tenths);
        end

        // Stop timer
        @(negedge clk);
        start = 0;
        $display("%0tus Stopping timer", $time);
        @(posedge clk);
        #1;
        if (running) begin
            ERR_COUNT++;
            $error("Timer should be stopped after stop");
        end

        // Remember current time
        saved_tenths = tenths;
        saved_seconds = seconds;
        saved_minutes = minutes;

        // Wait some time while stopped
        repeat(TENTH_SEC_CYCLES * 2) @(posedge clk);

        // Time should not have changed
        if (tenths != saved_tenths || seconds != saved_seconds || minutes != saved_minutes) begin
            ERR_COUNT++;
            $error("Time should not advance when stopped");
        end

        // Restart timer
        @(negedge clk);
        start = 1;
        $display("%0tus Restarting timer", $time);
        @(posedge clk);
        #1;
        if (!running) begin
            ERR_COUNT++;
            $error("Timer should be running after restart");
        end

        $display("  ✓ Basic start/stop operation working");
    end
endtask

// Task to test clear operation
task test_clear_operation();
    begin
        $display("Test 2: Clear operation");

        @(negedge clk);
        start = 1;
        $display("%0tus Start timer", $time);
        
        // Let timer run to some non-zero value
        repeat(TENTH_SEC_CYCLES * 5) @(posedge clk); // 0.5 seconds

        $display("%0tus Stop timer", $time);
        // Clear while running
        pulse_clear();
        #1;

        if (minutes || seconds || tenths) begin
            ERR_COUNT++;
            $error("Timer should be zero after clear");
        end

        if (!running) begin
            ERR_COUNT++;
            $error("Timer should still be running after clear");
        end

        // Set timer to some value again
        @(negedge clk);
        start = 1;
        $display("%0tus Start timer again", $time);
        repeat(TENTH_SEC_CYCLES * 7) @(posedge clk); // 0.7 seconds
        @(negedge clk);
        start = 0; //stop
        $display("%0tus Stop timer", $time);
       
        // Clear while stopped
        pulse_clear();
        #1;
        if (minutes || seconds || tenths) begin
            ERR_COUNT++;
            $error("Timer should be zero after clear while stopped");
        end

        if (running) begin
            ERR_COUNT++;
            $error("Timer should remain stopped after clear while stopped");
        end

        $display("  ✓ Clear operation working");
    end
endtask

// Task to test timing accuracy
task test_timing_accuracy();
    begin
        $display("Test 3: Timing accuracy");
        @(negedge clk);
        start = 0;
        $display("%0tus Ensure timer is stopped", $time);
        // Clear and start
        pulse_clear();
        @(negedge clk);
        start = 1;
        $display("%0tus Start timer for accuracy test", $time);

        // Test tenths rollover (0.9 → 1.0)
        repeat(TENTH_SEC_CYCLES * 10) @(posedge clk); // 1.0 second
        #1;
        if (seconds != 1 || tenths != 0) begin
            ERR_COUNT++;
            $error("After 1 second: expected 01.0, got %02d.%01d", seconds, tenths);
        end

        // Test seconds rollover (59.9 → 1:00.0)
        // Fast forward to 59.5 seconds
        force_time(0, 59, 5);
        repeat(TENTH_SEC_CYCLES * 5) @(posedge clk); // 0.5 more seconds
        #1;
        if (minutes != 1 || seconds != 0 || tenths != 0) begin
            ERR_COUNT++;
            $error("After minute rollover: expected 01:00.0, got %02d:%02d.%01d",
                   minutes, seconds, tenths);
        end

        $display("  ✓ Timing accuracy verified");
    end
endtask

// Task to test rollover at maximum time
task test_rollover();
    begin
        $display("Test 4: Rollover behavior");

        // Set to near maximum (59:59.8)
        force_time(59, 59, 8);
        repeat(TENTH_SEC_CYCLES * 2) @(posedge clk); // 0.2 more seconds
        #1;
        if (minutes != 0 || seconds != 0 || tenths != 0) begin
            ERR_COUNT++;
            $error("Timer should rollover to 00:00.0 after 59:59.9");
        end

        @(negedge clk);
        start = 0;
        $display("  ✓ Rollover behavior verified");
    end
endtask



// Helper task to pulse clear
task pulse_clear();
    begin
        @(negedge clk);
        clear = 1;
        @(negedge clk);
        clear = 0;
    end
endtask

// Helper task to force timer to specific time (for testing)
task force_time(input int min, input int sec, input int tenth);
    int total_tenths;
    begin
        // This is a testing shortcut - in real implementation,
        // we would need to let the timer naturally count to this value
        // For simulation purposes, we'll just advance time quickly
        pulse_clear();
        @(negedge clk);
        start = 1;

        // Calculate total tenths and advance quickly
        total_tenths = min * 600 + sec * 10 + tenth;
        repeat(total_tenths * TENTH_SEC_CYCLES) @(posedge clk);
    end
endtask

// Monitor for timing violations
always @(posedge clk) begin
    if (!reset) begin
        cycle_count <= cycle_count + 1;

        // Check value ranges
        if (minutes > 59) begin
            ERR_COUNT++;
            $error("Minutes out of range: %0d", minutes);
        end

        if (seconds > 59) begin
            ERR_COUNT++;
            $error("Seconds out of range: %0d", seconds);
        end

        if (tenths > 9) begin
            ERR_COUNT++;
            $error("Tenths out of range: %0d", tenths);
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