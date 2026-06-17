`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter CLK_FREQ = 1000,
    parameter DEBOUNCE_TIME_MS = 10,
    parameter INITIAL_STATE = 1,
    parameter BOUNCE_CYCLES = 50,
    parameter DEBOUNCE_CYCLES = (CLK_FREQ * DEBOUNCE_TIME_MS) / 1000
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg button_in;
wire button_out;

int ERR_COUNT = 0;
int stable_cycles = 0;
reg last_button_in = 0;

//DUT instantiation
   debounce #(
      .CLK_FREQ(CLK_FREQ),
      .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .button_in(button_in),
      .button_out(button_out)
   );

// Clock generation - fast simulation clock
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
end

// Test sequence
initial begin
    // Initialize
    reset = 1;
    button_in = INITIAL_STATE;

    // Reset sequence
    repeat(5) @(posedge clk);
    reset = 0;
    repeat(10) @(posedge clk);

    // Test 1: Simple press (with bouncing)
    $display("Test 1: Button press with bouncing");
    simulate_bouncy_press();
    repeat(50) @(posedge clk);

    // Test 2: Simple release (with bouncing)
    $display("Test 2: Button release with bouncing");
    simulate_bouncy_release();
    repeat(50) @(posedge clk);

    // Test 3: Quick press/release (should be filtered out)
    $display("Test 3: Quick glitch (should be filtered)");
    simulate_quick_glitch();
    repeat(50) @(posedge clk);

    // Test 4: Stable for exact debounce time
    $display("Test 4: Exactly debounce time stable");
    test_exact_timing();

    check_result;
end

// Task to simulate bouncy button press (1->0 with bouncing)
task simulate_bouncy_press();
    int press_start_time;
    begin
        press_start_time = $time;

        // Initial bounce sequence
        button_in = 0; repeat(5) @(posedge clk);
        button_in = 1; repeat(2) @(posedge clk);
        button_in = 0; repeat(3) @(posedge clk);
        button_in = 1; repeat(1) @(posedge clk);
        button_in = 0; repeat(4) @(posedge clk);
        button_in = 1; repeat(2) @(posedge clk);
        button_in = 0; // Final stable state

        // Wait for debounce + some extra time
        repeat(DEBOUNCE_CYCLES + 100) @(posedge clk);
        #1;
        // Verify output went low after debounce period
        if (button_out !== 1'b0) begin
            ERR_COUNT++;
            $error("Button press: Output should be 0 after debounce period");
        end else begin
            $display("  Button press debounced correctly");
        end
    end
endtask

// Task to simulate bouncy button release (0->1 with bouncing)
task simulate_bouncy_release();
    int release_start_time;
    begin
        release_start_time = $time;

        // Initial bounce sequence
        button_in = 1; repeat(4) @(posedge clk);
        button_in = 0; repeat(2) @(posedge clk);
        button_in = 1; repeat(6) @(posedge clk);
        button_in = 0; repeat(1) @(posedge clk);
        button_in = 1; repeat(3) @(posedge clk);
        button_in = 0; repeat(2) @(posedge clk);
        button_in = 1; // Final stable state

        // Wait for debounce + some extra time
        repeat(DEBOUNCE_CYCLES + 100) @(posedge clk);
        #1;
        // Verify output went high after debounce period
        if (button_out !== 1'b1) begin
            ERR_COUNT++;
            $error("Button release: Output should be 1 after debounce period");
        end else begin
            $display("  Button release debounced correctly");
        end
    end
endtask

// Task to simulate quick glitch that should be filtered out
task simulate_quick_glitch();
    reg initial_state;
    begin
        initial_state = button_out;

        // Create a short glitch (much shorter than debounce time)
        button_in = ~button_in;
        repeat(DEBOUNCE_CYCLES / 4) @(posedge clk); // Only 1/4 of debounce time
        #1;
        button_in = ~button_in; // Return to original state

        // Wait for full debounce time
        repeat(DEBOUNCE_CYCLES + 100) @(posedge clk);
        #1;
        // Output should remain unchanged
        if (button_out !== initial_state) begin
            ERR_COUNT++;
            $error("Quick glitch: Output should not change for short input pulses");
        end else begin
            $display("  Quick glitch correctly filtered out");
        end
    end
endtask

// Task to test exact timing requirements
task test_exact_timing();
    begin
        // Change input
        // Need to account for: 2 sync cycles + DEBOUNCE_CYCLES
        button_in = ~button_in;

        // Wait for sync + debounce period - 1
        repeat(2 + DEBOUNCE_CYCLES - 1) @(posedge clk);
        #1;
        // Output should NOT have changed yet
        if (button_out === button_in) begin
            ERR_COUNT++;
            $error("Timing: Output changed too early (before debounce period completed)");
        end

        // Wait one more cycle (state updates when counter == DEBOUNCE_CYCLES-1)
        @(posedge clk);
        #1;

        // Now output should match input
        if (button_out !== button_in) begin
            ERR_COUNT++;
            $error("Timing: Output should change exactly after debounce period");
        end else begin
            $display("  Exact timing test passed");
        end
    end
endtask

// Monitor for stable input cycles
always @(posedge clk) begin
    if (reset) begin
        stable_cycles <= 0;
        last_button_in <= button_in;
    end else begin
        // Track stable input cycles
        if (button_in === last_button_in) begin
            stable_cycles <= stable_cycles + 1;
        end else begin
            stable_cycles <= 0;
        end
        last_button_in <= button_in;
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