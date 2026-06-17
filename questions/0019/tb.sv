`timescale 1ns / 1ps

module tb();
    //---------------------------------------------------------
    // Input Vectors
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

    reg [3:0] data_i;
    wire valid_o;
    wire [1:0] pos_o;

    // Expected outputs
    reg expected_valid;
    reg [1:0] expected_pos;

    integer ERR_COUNT = 0;

    // DUT instantiation
    priority_encoder DUT (
        .data_i(data_i),
        .valid_o(valid_o),
        .pos_o(pos_o)
    );

    // Golden model - Priority encoder with LSB priority
    always @(*) begin
        // Valid when any bit is high
        expected_valid = |data_i;

        // Priority encoding: bit 0 has highest priority
        if (data_i[0]) begin
            expected_pos = 2'b00;
        end else if (data_i[1]) begin
            expected_pos = 2'b01;
        end else if (data_i[2]) begin
            expected_pos = 2'b10;
        end else if (data_i[3]) begin
            expected_pos = 2'b11;
        end else begin
            expected_pos = 2'bxx;  // Don't care when no bits are active
        end
    end

    // Stimulus/test sequence
    initial begin
        // Test 1: No active bits
        data_i = 4'b0000;
        #20;

        // Test 2: Only bit 0 active (highest priority)
        data_i = 4'b0001;
        #20;

        // Test 3: Only bit 1 active
        data_i = 4'b0010;
        #20;

        // Test 4: Bits 0 and 1 active (bit 0 has priority)
        data_i = 4'b0011;
        #20;

        // Test 5: Only bit 2 active
        data_i = 4'b0100;
        #20;

        // Test 6: Bits 0 and 2 active (bit 0 has priority)
        data_i = 4'b0101;
        #20;

        // Test 7: Bits 1 and 2 active (bit 1 has priority)
        data_i = 4'b0110;
        #20;

        // Test 8: Bits 0, 1, and 2 active (bit 0 has priority)
        data_i = 4'b0111;
        #20;

        // Test 9: Only bit 3 active (lowest priority)
        data_i = 4'b1000;
        #20;

        // Test 10: Bits 0 and 3 active (bit 0 has priority)
        data_i = 4'b1001;
        #20;

        // Test 11: Bits 1 and 3 active (bit 1 has priority)
        data_i = 4'b1010;
        #20;

        // Test 12: Bits 0, 1, and 3 active (bit 0 has priority)
        data_i = 4'b1011;
        #20;

        // Test 13: Bits 2 and 3 active (bit 2 has priority)
        data_i = 4'b1100;
        #20;

        // Test 14: Bits 0, 2, and 3 active (bit 0 has priority)
        data_i = 4'b1101;
        #20;

        // Test 15: Bits 1, 2, and 3 active (bit 1 has priority)
        data_i = 4'b1110;
        #20;

        // Test 16: All bits active (bit 0 has priority)
        data_i = 4'b1111;
        #20;

        check_result;
    end

    // Continuous checking
    always @(data_i) begin
        #1; // Small delay to allow outputs to settle

        // For the case when data_i is all zeros, pos_o is don't care
        if (data_i == 4'b0000) begin
            // Only check valid_o for all-zero case
            if (expected_valid !== valid_o) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns data_i=%b | valid_o=%b (expected=%b) pos_o=%b (don't care)",
                       $time, data_i, valid_o, expected_valid, pos_o);
            end else begin
                $display("%0tns data_i=%b | valid_o=%b pos_o=%b (don't care)",
                         $time, data_i, valid_o, pos_o);
            end
        end else begin
            // Check both valid_o and pos_o for non-zero cases
            if (expected_valid !== valid_o || expected_pos !== pos_o) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("%0tns data_i=%b | valid_o=%b (expected=%b) pos_o=%b (expected=%b)",
                       $time, data_i, valid_o, expected_valid, pos_o, expected_pos);
            end else begin
                $display("%0tns data_i=%b | valid_o=%b pos_o=%b",
                         $time, data_i, valid_o, pos_o);
            end
        end
    end

    // do not edit below
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
