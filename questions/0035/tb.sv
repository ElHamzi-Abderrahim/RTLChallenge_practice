`timescale 1ns / 1ps

module tb #(
    //---------------------------------------------------------
    // Input Vectors
    parameter DATA_WIDTH = 8,
    parameter SHIFT_WIDTH = 3,
    parameter TEST_DATA_1 = 181,
    parameter SHIFT_AMT_1 = 2,
    parameter SHIFT_DIR_1 = 0,
    parameter SHIFT_TYPE_1 = 0,
    parameter TEST_DATA_2 = 181,
    parameter SHIFT_AMT_2 = 3,
    parameter SHIFT_DIR_2 = 1,
    parameter SHIFT_TYPE_2 = 0,
    parameter TEST_DATA_3 = 181,
    parameter SHIFT_AMT_3 = 1,
    parameter SHIFT_DIR_3 = 0,
    parameter SHIFT_TYPE_3 = 1
    );
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg [DATA_WIDTH-1:0] data_in;
reg [SHIFT_WIDTH-1:0] shift_amt;
reg shift_dir;
reg shift_type;
wire [DATA_WIDTH-1:0] data_out;

int ERR_COUNT = 0;

//DUT instantiation
   barrel_shifter #(
      .DATA_WIDTH(DATA_WIDTH),
      .SHIFT_WIDTH(SHIFT_WIDTH)
   ) DUT (
      .data_in(data_in),
      .shift_amt(shift_amt),
      .shift_dir(shift_dir),
      .shift_type(shift_type),
      .data_out(data_out)
   );


// stimulus/test sequence
initial begin
    // Initialize inputs
    data_in = TEST_DATA_1;
    shift_amt = SHIFT_AMT_1;
    shift_dir = SHIFT_DIR_1;
    shift_type = SHIFT_TYPE_1;
    # 20;
    data_in = TEST_DATA_2;
    shift_amt = SHIFT_AMT_2;
    shift_dir = SHIFT_DIR_2;
    shift_type = SHIFT_TYPE_2;
    # 20;
    data_in = TEST_DATA_3;
    shift_amt = SHIFT_AMT_3;
    shift_dir = SHIFT_DIR_3;
    shift_type = SHIFT_TYPE_3;
    # 20;
    check_result; //must call this task to end the simulation
end

// Golden reference functions
function [DATA_WIDTH-1:0] golden_barrel_shifter;
    input [DATA_WIDTH-1:0] data;
    input [SHIFT_WIDTH-1:0] shift;
    input dir;
    input typ;
    reg [SHIFT_WIDTH-1:0] eff_shift;
    begin
        eff_shift = shift % DATA_WIDTH;

        if (dir == 1'b0) begin
            // Left shift/rotate
            if (typ == 1'b0) begin
                // Logical left shift
                golden_barrel_shifter = data << shift;
            end else begin
                // Left rotate
                if (eff_shift == 0)
                    golden_barrel_shifter = data;
                else
                    golden_barrel_shifter = (data << eff_shift) | (data >> (DATA_WIDTH - eff_shift));
            end
        end else begin
            // Right shift/rotate
            if (typ == 1'b0) begin
                // Logical right shift
                golden_barrel_shifter = data >> shift;
            end else begin
                // Right rotate
                if (eff_shift == 0)
                    golden_barrel_shifter = data;
                else
                    golden_barrel_shifter = (data >> eff_shift) | (data << (DATA_WIDTH - eff_shift));
            end
        end
    end
endfunction

// golden solution
initial begin
forever begin
   @(data_in, shift_amt, shift_dir, shift_type, data_out);
   #1;
   if(data_out !== golden_barrel_shifter(data_in, shift_amt, shift_dir, shift_type)) begin
      ERR_COUNT = ERR_COUNT + 1;
      $error("%0tns Data_out = 0x%02X, expected = 0x%02X (data=0x%02X, shift=%0d, dir=%0d, type=%0d)",
             $time, data_out, golden_barrel_shifter(data_in, shift_amt, shift_dir, shift_type),
             data_in, shift_amt, shift_dir, shift_type);
   end else begin
      $display("%0tns Data_out = 0x%02X, Data_in = 0x%02X, shift_amt = %0d, shift_dir = %0d, shift_type = %0d",
               $time, data_out, data_in, shift_amt, shift_dir, shift_type);
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
