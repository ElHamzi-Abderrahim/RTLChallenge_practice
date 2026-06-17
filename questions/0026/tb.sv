`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter ACTIVE_HIGH = 1
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [3:0] bcd_digit;
reg enable;
wire [6:0] segments;
wire digit_valid;

int ERR_COUNT = 0;

//DUT instantiation
   seven_segment_driver #(
      .ACTIVE_HIGH(ACTIVE_HIGH)
   ) DUT (
      .bcd_digit(bcd_digit),
      .enable(enable),
      .segments(segments),
      .digit_valid(digit_valid)
   );

// Expected segment patterns for active high displays
// segments[6:0] = {g,f,e,d,c,b,a}
reg [6:0] expected_patterns [0:9];

initial begin
    // Initialize expected patterns (active high)
    expected_patterns[0] = 7'b0111111; // 0: a,b,c,d,e,f
    expected_patterns[1] = 7'b0000110; // 1: b,c
    expected_patterns[2] = 7'b1011011; // 2: a,b,g,e,d
    expected_patterns[3] = 7'b1001111; // 3: a,b,g,c,d
    expected_patterns[4] = 7'b1100110; // 4: f,g,b,c
    expected_patterns[5] = 7'b1101101; // 5: a,f,g,c,d
    expected_patterns[6] = 7'b1111101; // 6: a,f,g,e,d,c
    expected_patterns[7] = 7'b0000111; // 7: a,b,c
    expected_patterns[8] = 7'b1111111; // 8: a,b,c,d,e,f,g
    expected_patterns[9] = 7'b1101111; // 9: a,b,c,d,f,g
end

// Test sequence
initial begin
    integer i;
    // Initialize
    bcd_digit = 0;
    enable = 1;

    #10; // Allow settling time

    // Test all valid digits (0-9)
    $display("Testing valid BCD digits (0-9)");
    for (i = 0; i <= 9; i = i + 1) begin
        test_digit(i, 1);
        #10;
    end

    // Test invalid digits (10-15)
    $display("Testing invalid BCD digits (10-15)");
    for (i = 10; i <= 15; i = i + 1) begin
        test_invalid_digit(i);
        #10;
    end

    // Test enable functionality
    test_enable_control();

    check_result;
end

// Task to test a valid digit
task test_digit;
    input integer digit;
    input reg enabled;
    reg [6:0] expected;
    begin
        bcd_digit = digit;
        enable = enabled;
        #5; // Allow combinational delay

        expected = ACTIVE_HIGH ? expected_patterns[digit] : ~expected_patterns[digit];

        if (!enabled) begin
            expected = ACTIVE_HIGH ? 7'b0000000 : 7'b1111111;
        end

        $display("Testing digit %0d (enable=%b): segments=0x%02X, expected=0x%02X",
                 digit, enable, segments, expected);

        if (segments !== expected) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv Digit %0d: segment pattern mismatch", digit);
            $display("ERROR: tb.sv   Got:      %07b (0x%02X)", segments, segments);
            $display("ERROR: tb.sv   Expected: %07b (0x%02X)", expected, expected);
        end

        if (enabled && digit <= 9) begin
            if (!digit_valid) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv Digit %0d: digit_valid should be high for valid digits", digit);
            end
        end else begin
            if (digit_valid) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv Digit %0d: digit_valid should be low when disabled or invalid", digit);
            end
        end

        // Verify individual segments make sense for the digit
        if (enabled && digit <= 9) begin
            verify_digit_segments(digit, segments);
        end
    end
endtask

// Task to test invalid digits
task test_invalid_digit;
    input integer digit;
    reg [6:0] expected_off;
    begin
        bcd_digit = digit;
        enable = 1;
        #5;

        expected_off = ACTIVE_HIGH ? 7'b0000000 : 7'b1111111;

        $display("Testing invalid digit %0d: segments=0x%02X", digit, segments);

        if (segments !== expected_off) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv Invalid digit %0d: should display blank (all segments off)", digit);
        end

        if (digit_valid) begin
            ERR_COUNT = ERR_COUNT + 1;
            $display("ERROR: tb.sv Invalid digit %0d: digit_valid should be low", digit);
        end
    end
endtask

// Task to test enable control
task test_enable_control();
    integer i;
    reg [6:0] expected_off;
    begin
        $display("Testing enable control");

        expected_off = ACTIVE_HIGH ? 7'b0000000 : 7'b1111111;

        // Test enable=0 with various digits
        for (i = 0; i <= 5; i = i + 1) begin
            bcd_digit = i;
            enable = 0;
            #5;

            if (segments !== expected_off) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv Enable control: segments should be off when enable=0 (digit %0d)", i);
            end

            if (digit_valid) begin
                ERR_COUNT = ERR_COUNT + 1;
                $display("ERROR: tb.sv Enable control: digit_valid should be low when enable=0 (digit %0d)", i);
            end
        end

        $display("  - Enable control working correctly");
    end
endtask

// Task to verify segment patterns make logical sense
task verify_digit_segments;
    input integer digit;
    input [6:0] seg_pattern;
    begin
        // Basic sanity checks for common digits
        // segments[6:0] = {g,f,e,d,c,b,a}
        case (digit)
            0: begin
                // Digit 0 should have outer segments (a,b,c,d,e,f) but not center (g)
                if (ACTIVE_HIGH && seg_pattern[6]) begin // g segment is bit 6
                    ERR_COUNT = ERR_COUNT + 1;
                    $display("ERROR: tb.sv Digit 0: center segment (g) should be off");
                end
            end
            1: begin
                // Digit 1 should only have right side segments (b,c) - bits 1,2
                if (ACTIVE_HIGH) begin
                    if (seg_pattern[6] || seg_pattern[5] || seg_pattern[4] || seg_pattern[3] || seg_pattern[0]) begin // g,f,e,d,a
                        ERR_COUNT = ERR_COUNT + 1;
                        $display("ERROR: tb.sv Digit 1: should only have right side segments (b,c)");
                    end
                end
            end
            7: begin
                // Digit 7 should have top and right side (a,b,c) - bits 0,1,2
                if (ACTIVE_HIGH) begin
                    if (seg_pattern[6] || seg_pattern[5] || seg_pattern[4] || seg_pattern[3]) begin // g,f,e,d
                        ERR_COUNT = ERR_COUNT + 1;
                        $display("ERROR: tb.sv Digit 7: should only have top and right side segments (a,b,c)");
                    end
                end
            end
            8: begin
                // Digit 8 should have all segments
                if (ACTIVE_HIGH && segments !== 7'b1111111) begin
                    ERR_COUNT = ERR_COUNT + 1;
                    $display("ERROR: tb.sv Digit 8: should have all segments on");
                end
            end
        endcase
    end
endtask

// Monitor for unexpected changes
reg [3:0] prev_bcd_digit;
reg prev_enable;
always @(*) begin
    if (bcd_digit !== prev_bcd_digit || enable !== prev_enable) begin
        #1; // Small delay to allow outputs to settle
        prev_bcd_digit = bcd_digit;
        prev_enable = enable;
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