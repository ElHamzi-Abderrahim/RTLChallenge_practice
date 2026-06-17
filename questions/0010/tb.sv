`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors
    // ALU test vectors
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [7:0] a_i;
reg [7:0] b_i;
reg [2:0] op_i;
wire [7:0] alu_o;

// Expected outputs from golden model
reg [7:0] expected_out;

int ERR_COUNT = 0;

//DUT instantiation
simple_alu DUT (
    .a_i(a_i),
    .b_i(b_i),
    .op_i(op_i),
    .alu_o(alu_o)
);

// stimulus/test sequence
initial begin
    // Initialize signals
    a_i = 0;
    b_i = 0;
    op_i = 0;
    #10;

    // Test all ALU operations
    test_operation(8'h05, 8'h03, 3'b000); // ADD
    test_operation(8'h05, 8'h03, 3'b001); // SUB
    test_operation(8'h05, 8'h03, 3'b010); // AND
    test_operation(8'h05, 8'h03, 3'b011); // OR
    test_operation(8'h05, 8'h03, 3'b100); // XOR
    test_operation(8'h05, 8'h03, 3'b101); // NOT A
    test_operation(8'h05, 8'h03, 3'b110); // Left shift A
    test_operation(8'h05, 8'h03, 3'b111); // Right shift A

    // Test with different values
    test_operation(8'hFF, 8'h01, 3'b000); // ADD with overflow
    test_operation(8'h00, 8'h01, 3'b001); // SUB with underflow
    test_operation(8'hAA, 8'h55, 3'b010); // AND
    test_operation(8'hAA, 8'h55, 3'b011); // OR
    test_operation(8'hAA, 8'h55, 3'b100); // XOR

    // Test edge cases
    test_operation(8'h80, 8'h00, 3'b110); // Left shift MSB
    test_operation(8'h01, 8'h00, 3'b111); // Right shift LSB

    check_result;
end 

// Task to test ALU operation
task test_operation(input [7:0] a_val, input [7:0] b_val, input [2:0] op_val);
    a_i = a_val;
    b_i = b_val;
    op_i = op_val;
    #10;

    // Calculate expected result
    case (op_val)
        3'b000: expected_out = a_val + b_val;           // ADD
        3'b001: expected_out = a_val - b_val;           // SUB
        3'b010: expected_out = a_val & b_val;           // AND
        3'b011: expected_out = a_val | b_val;           // OR
        3'b100: expected_out = a_val ^ b_val;           // XOR
        3'b101: expected_out = ~a_val;                  // NOT A
        3'b110: expected_out = a_val << 1;              // Left shift A
        3'b111: expected_out = a_val >> 1;              // Right shift A
        default: expected_out = 8'h00;
    endcase

    if (alu_o !== expected_out) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns ALU operation failed: a=%h, b=%h, op=%b, result=%h, expected=%h",
               $time, a_val, b_val, op_val, alu_o, expected_out);
    end else begin
        $display("%0tns ALU operation passed: a=%h, b=%h, op=%b, result=%h",
                $time, a_val, b_val, op_val, alu_o);
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
