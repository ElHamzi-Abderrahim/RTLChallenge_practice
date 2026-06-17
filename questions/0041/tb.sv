`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter TEST_DATA_1 = 8'h55,  // 01010101
    parameter TEST_DATA_2 = 8'hAA,  // 10101010
    parameter TEST_DATA_3 = 8'hF0   // 11110000
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [7:0] data_in;
wire [12:0] encoded_out;
wire [4:0] parity_bits;

int ERR_COUNT = 0;

//DUT instantiation
   hamming_encoder DUT (
      .data_in(data_in),
      .encoded_out(encoded_out),
      .parity_bits(parity_bits)
   );

// Reference function to calculate SECDED Hamming(13,8) code
function [12:0] calc_secded_hamming;
    input [7:0] data;
    reg d7, d6, d5, d4, d3, d2, d1, d0;
    reg p3, p2, p1, p0, p4;
    begin
        d0 = data[0];
        d1 = data[1];
        d2 = data[2];
        d3 = data[3];
        d4 = data[4];
        d5 = data[5];
        d6 = data[6];
        d7 = data[7];

        // Hamming parity calculations
        p0 = d0 ^ d1 ^ d3 ^ d4 ^ d6;  // positions 0,2,4,6,8,10
        p1 = d0 ^ d2 ^ d3 ^ d5 ^ d6;  // positions 1,2,5,6,9,10
        p2 = d1 ^ d2 ^ d3 ^ d7;        // positions 3,4,5,6,11
        p3 = d4 ^ d5 ^ d6 ^ d7;        // positions 7,8,9,10,11

        // Overall parity for SECDED
        p4 = p0 ^ p1 ^ d0 ^ p2 ^ d1 ^ d2 ^ d3 ^ p3 ^ d4 ^ d5 ^ d6 ^ d7;

        // Assemble: P4 D7 D6 D5 D4 P3 D3 D2 D1 P2 D0 P1 P0
        calc_secded_hamming = {p4, d7, d6, d5, d4, p3, d3, d2, d1, p2, d0, p1, p0};
    end
endfunction

// Test sequence
initial begin
    $display("Testing SECDED Hamming(13,8) encoder");

    // Test input vector values
    test_single_value(TEST_DATA_1);
    test_single_value(TEST_DATA_2);
    test_single_value(TEST_DATA_3);

    // Test all possible inputs (sample subset for 8-bit)
    test_sample_inputs();

    // Verify parity properties
    verify_parity_properties();

    // Test bit position mapping
    test_bit_positions();

    check_result;
end

// Task to test single value
task test_single_value;
    input [7:0] test_val;
    reg [12:0] expected_encoded;
    reg [4:0] expected_parity;
    begin
        data_in = test_val;
        #5;

        expected_encoded = calc_secded_hamming(test_val);
        expected_parity = {expected_encoded[12], expected_encoded[7], expected_encoded[3], expected_encoded[1:0]};

        $display("Testing data 0x%02X", test_val);
        $display("  Expected: encoded=0x%04X, parity=0x%02X", expected_encoded, expected_parity);
        $display("  Got:      encoded=0x%04X, parity=0x%02X", encoded_out, parity_bits);

        if (encoded_out !== expected_encoded) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Encoded output mismatch for data 0x%02X", test_val);
        end

        if (parity_bits !== expected_parity) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("Parity bits mismatch for data 0x%02X", test_val);
        end
    end
endtask

// Task to test sample inputs (256 values would be too many for quick test)
task test_sample_inputs;
    integer i;
    reg [12:0] expected_encoded;
    reg [4:0] expected_parity;
    reg [7:0] extracted_data;
    begin
        $display("Testing sample 8-bit input combinations");

        for (i = 0; i < 256; i = i + 17) begin  // Sample every 17th value
            data_in = i[7:0];
            #5;

            expected_encoded = calc_secded_hamming(i[7:0]);
            expected_parity = {expected_encoded[12], expected_encoded[7], expected_encoded[3], expected_encoded[1:0]};

            if (encoded_out !== expected_encoded) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Encoded output mismatch for data 0x%02X", i);
            end

            if (parity_bits !== expected_parity) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Parity bits mismatch for data 0x%02X", i);
            end

            // Verify data bits are preserved in correct positions
            extracted_data = {encoded_out[11], encoded_out[10], encoded_out[9], encoded_out[8],
                             encoded_out[6], encoded_out[5], encoded_out[4], encoded_out[2]};
            if (extracted_data !== data_in) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Data bits not preserved correctly in encoded output");
            end

            #5;
        end

        $display("  Sample inputs tested");
    end
endtask

// Task to verify parity properties
task verify_parity_properties;
    integer i;
    reg d7, d6, d5, d4, d3, d2, d1, d0;
    reg p3, p2, p1, p0, p4;
    reg parity_check_0, parity_check_1, parity_check_2, parity_check_3, parity_check_overall;
    begin
        $display("Verifying parity properties");

        for (i = 0; i < 256; i = i + 23) begin  // Sample every 23rd value
            data_in = i[7:0];
            #5;

            // Extract bits for parity checking
            p0 = encoded_out[0];
            p1 = encoded_out[1];
            d0 = encoded_out[2];
            p2 = encoded_out[3];
            d1 = encoded_out[4];
            d2 = encoded_out[5];
            d3 = encoded_out[6];
            p3 = encoded_out[7];
            d4 = encoded_out[8];
            d5 = encoded_out[9];
            d6 = encoded_out[10];
            d7 = encoded_out[11];
            p4 = encoded_out[12];

            // Check parity equations (should all be 0 for even parity)
            parity_check_0 = p0 ^ d0 ^ d1 ^ d3 ^ d4 ^ d6;
            parity_check_1 = p1 ^ d0 ^ d2 ^ d3 ^ d5 ^ d6;
            parity_check_2 = p2 ^ d1 ^ d2 ^ d3 ^ d7;
            parity_check_3 = p3 ^ d4 ^ d5 ^ d6 ^ d7;
            parity_check_overall = p4 ^ p0 ^ p1 ^ d0 ^ p2 ^ d1 ^ d2 ^ d3 ^ p3 ^ d4 ^ d5 ^ d6 ^ d7;

            if (parity_check_0 !== 1'b0) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Parity check 0 failed for data 0x%02X", i);
            end

            if (parity_check_1 !== 1'b0) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Parity check 1 failed for data 0x%02X", i);
            end

            if (parity_check_2 !== 1'b0) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Parity check 2 failed for data 0x%02X", i);
            end

            if (parity_check_3 !== 1'b0) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Parity check 3 failed for data 0x%02X", i);
            end

            if (parity_check_overall !== 1'b0) begin
                ERR_COUNT = ERR_COUNT + 1;
                $error("Overall parity check failed for data 0x%02X", i);
            end
        end

        $display("  All parity properties verified");
    end
endtask

// Task to test bit position mapping
task test_bit_positions;
    begin
        $display("Testing bit position mapping");

        // Test with known pattern
        data_in = 8'b10101100;
        #5;

        // Check data bit positions (P4 D7 D6 D5 D4 P3 D3 D2 D1 P2 D0 P1 P0)
        if (encoded_out[11] !== data_in[7]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D7 not at correct position");
        end

        if (encoded_out[10] !== data_in[6]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D6 not at correct position");
        end

        if (encoded_out[9] !== data_in[5]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D5 not at correct position");
        end

        if (encoded_out[8] !== data_in[4]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D4 not at correct position");
        end

        if (encoded_out[6] !== data_in[3]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D3 not at correct position");
        end

        if (encoded_out[5] !== data_in[2]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D2 not at correct position");
        end

        if (encoded_out[4] !== data_in[1]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D1 not at correct position");
        end

        if (encoded_out[2] !== data_in[0]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("D0 not at correct position");
        end

        // Verify parity bit positions
        if (parity_bits[4] !== encoded_out[12]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("P4 not at correct position");
        end

        if (parity_bits[3] !== encoded_out[7]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("P3 not at correct position");
        end

        if (parity_bits[2] !== encoded_out[3]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("P2 not at correct position");
        end

        if (parity_bits[1] !== encoded_out[1]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("P1 not at correct position");
        end

        if (parity_bits[0] !== encoded_out[0]) begin
            ERR_COUNT = ERR_COUNT + 1;
            $error("P0 not at correct position");
        end

        $display("  Bit position mapping verified");
    end
endtask

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
