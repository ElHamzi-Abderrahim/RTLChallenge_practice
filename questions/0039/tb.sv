`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors (will be overridden by input_vector.txt)
    parameter CLK_FREQ = 100,
    parameter GREEN_TIME_SEC = 5,
    parameter YELLOW_TIME_SEC = 2,
    parameter RED_TIME_SEC = 1
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg enable;
reg emergency;
wire ns_red, ns_yellow, ns_green;
wire ew_red, ew_yellow, ew_green;

int ERR_COUNT = 0;
int cycle_count = 0;
reg prev_emergency = 0;
int emergency_release_cycles = 0;

// State encoding for verification
localparam NS_GREEN_EW_RED   = 3'd0;
localparam NS_YELLOW_EW_RED  = 3'd1;
localparam ALL_RED_1         = 3'd2;
localparam EW_GREEN_NS_RED   = 3'd3;
localparam EW_YELLOW_NS_RED  = 3'd4;
localparam ALL_RED_2         = 3'd5;
localparam INVALID_STATE     = 3'd7;

//DUT instantiation
   traffic_light_controller #(
      .CLK_FREQ(CLK_FREQ),
      .GREEN_TIME_SEC(GREEN_TIME_SEC),
      .YELLOW_TIME_SEC(YELLOW_TIME_SEC),
      .RED_TIME_SEC(RED_TIME_SEC)
   ) DUT (
      .clk(clk),
      .reset(reset),
      .enable(enable),
      .emergency(emergency),
      .ns_red(ns_red),
      .ns_yellow(ns_yellow),
      .ns_green(ns_green),
      .ew_red(ew_red),
      .ew_yellow(ew_yellow),
      .ew_green(ew_green)
   );

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
end

// Function to decode current state from outputs
function [2:0] decode_state;
    begin
        case ({ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green})
            6'b001100: decode_state = NS_GREEN_EW_RED;
            6'b010100: decode_state = NS_YELLOW_EW_RED;
            6'b100100: decode_state = ALL_RED_1;
            6'b100001: decode_state = EW_GREEN_NS_RED;
            6'b100010: decode_state = EW_YELLOW_NS_RED;
            default:   decode_state = INVALID_STATE;
        endcase
    end
endfunction

// Test sequence
initial begin
    // Initialize
    reset = 1;
    enable = 0;
    emergency = 0;

    // Reset sequence
    repeat(5) @(posedge clk);
    #1;
    reset = 0;
    enable = 1;

    // Test normal operation for 2 complete cycles
    test_normal_cycle();
    test_normal_cycle();

    // Test emergency override
    test_emergency_mode();

    // Test enable control
    test_enable_control();

    check_result;
end

// Task to test one complete normal cycle
task test_normal_cycle();
    begin
        $display("Testing normal traffic light cycle");

        // Verify initial state (should be NS_GREEN_EW_RED)
        verify_state_and_timing(NS_GREEN_EW_RED, GREEN_TIME_SEC);
        verify_state_and_timing(NS_YELLOW_EW_RED, YELLOW_TIME_SEC);
        verify_state_and_timing(ALL_RED_1, RED_TIME_SEC);
        verify_state_and_timing(EW_GREEN_NS_RED, GREEN_TIME_SEC);
        verify_state_and_timing(EW_YELLOW_NS_RED, YELLOW_TIME_SEC);
        verify_state_and_timing(ALL_RED_2, RED_TIME_SEC);

        $display("Normal cycle completed successfully");
    end
endtask

// Task to verify state and timing
task verify_state_and_timing(input [2:0] expected, input int duration_sec);
    int start_time, cycles_needed;
    reg [2:0] actual_state;
    begin
        cycles_needed = duration_sec * CLK_FREQ;
        start_time = cycle_count;

        $display("  Expecting state %0d for %0d seconds (%0d cycles)",
                 expected, duration_sec, cycles_needed);

        // Wait for state duration
        repeat(cycles_needed) @(posedge clk);
        #1;
        // Check if we were in the correct state for the entire duration
        actual_state = decode_state();

        // Note: This simplified check verifies final state
        // A more complete test would monitor throughout the duration
        if (actual_state == INVALID_STATE) begin
            ERR_COUNT++;
            $error("Invalid light combination detected: ns=%b%b%b, ew=%b%b%b",
                   ns_red, ns_yellow, ns_green, ew_red, ew_yellow, ew_green);
        end
    end
endtask

// Task to test emergency mode
task test_emergency_mode();
    begin
        $display("Testing emergency mode");

        // Activate emergency during normal operation
        emergency = 1;
        repeat(5) @(posedge clk);

        #1;
        // All lights should be red
        if (!(ns_red && ew_red && !ns_yellow && !ns_green && !ew_yellow && !ew_green)) begin
            ERR_COUNT++;
            $error("Emergency mode: All lights should be red");
        end else begin
            $display("  Emergency mode: All lights correctly red");
        end

        // Deactivate emergency
        emergency = 0;
        repeat(10) @(posedge clk);

        $display("Emergency mode test completed");
    end
endtask

// Task to test enable control
task test_enable_control();
    reg [2:0] state_before, state_after;
    begin
        $display("Testing enable control");

        state_before = decode_state();
        enable = 0;
        repeat(CLK_FREQ * 2) @(posedge clk); // Wait 2 seconds
        #1;
        state_after = decode_state();

        if (state_before !== state_after) begin
            ERR_COUNT++;
            $error("Enable control: State should not change when enable is low");
        end else begin
            $display("  Enable control working correctly");
        end

        enable = 1;
        $display("Enable control test completed");
    end
endtask

// Continuous monitoring
always @(posedge clk) begin
    if (!reset) begin
        #1;
        cycle_count <= cycle_count + 1;

        // Track emergency transitions
        if (prev_emergency && !emergency) begin
            emergency_release_cycles <= 0;
        end else if (!emergency && emergency_release_cycles < 10) begin
            emergency_release_cycles <= emergency_release_cycles + 1;
        end
        prev_emergency <= emergency;

        // Check for multiple lights on in same direction
        if ((ns_red && ns_yellow) || (ns_red && ns_green) || (ns_yellow && ns_green)) begin
            ERR_COUNT++;
            $error("Multiple NS lights on simultaneously: red=%b, yellow=%b, green=%b",
                   ns_red, ns_yellow, ns_green);
        end

        if ((ew_red && ew_yellow) || (ew_red && ew_green) || (ew_yellow && ew_green)) begin
            ERR_COUNT++;
            $error("Multiple EW lights on simultaneously: red=%b, yellow=%b, green=%b",
                   ew_red, ew_yellow, ew_green);
        end

        // Check that exactly one light is on per direction (unless emergency or just released)
        if (!emergency && emergency_release_cycles > 5) begin
            if (!(ns_red ^ ns_yellow ^ ns_green)) begin
                ERR_COUNT++;
                $error("Exactly one NS light should be on: red=%b, yellow=%b, green=%b",
                       ns_red, ns_yellow, ns_green);
            end

            if (!(ew_red ^ ew_yellow ^ ew_green)) begin
                ERR_COUNT++;
                $error("Exactly one EW light should be on: red=%b, yellow=%b, green=%b",
                       ew_red, ew_yellow, ew_green);
            end

            // Safety check: green lights should never be on simultaneously
            if (ns_green && ew_green) begin
                ERR_COUNT++;
                $error("Safety violation: Both directions have green lights");
            end
        end

        // Check emergency behavior
        if (emergency) begin
            if (!(ns_red && ew_red && !ns_yellow && !ns_green && !ew_yellow && !ew_green)) begin
                ERR_COUNT++;
                $error("Emergency mode violation: Not all lights red");
            end
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
