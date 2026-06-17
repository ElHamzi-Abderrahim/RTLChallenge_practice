`timescale 1ns / 1ps

module tb(
    );
    //---------------------------------------------------------
    // Input Vectors - No parameters for this module
    // --------------------------------------------------------

    localparam TB_SIM_TIMEOUT = 30_000_000; //ns

reg clk;
reg reset;
reg load_i;
reg [3:0] load_val_i;
wire [3:0] count_o;
reg [3:0] expected_out;

int ERR_COUNT = 0;

//DUT instantiation
self_reload_counter DUT (
    .clk(clk),
    .reset(reset),
    .load_i(load_i),
    .load_val_i(load_val_i),
    .count_o(count_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Golden model
reg [3:0] load_ff_golden;
reg [3:0] count_ff_golden;
reg [3:0] nxt_count_golden;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        load_ff_golden <= 4'h0;
        count_ff_golden <= 4'h0;
    end else begin
        if (load_i)
            load_ff_golden <= load_val_i;
        count_ff_golden <= nxt_count_golden;
    end
end

always @(*) begin
    nxt_count_golden = load_i ? load_val_i :
                       (count_ff_golden == 4'hF) ? load_ff_golden :
                       count_ff_golden + 4'h1;
    expected_out = count_ff_golden;
end

// stimulus/test sequence
initial begin
    // Initialize inputs
    reset = 1;
    load_i = 0;
    load_val_i = 4'h0;
    #20;

    reset = 0;
    #10;

    // Test 1: Load value 5 and let it count
    load_i = 1;
    load_val_i = 4'h5;
    #10;
    load_i = 0;
    #50;

    // Test 2: Load value 3 and let it overflow back to load value
    load_i = 1;
    load_val_i = 4'h3;
    #10;
    load_i = 0;
    #200;

    // Test 3: Load value F (should restart from F after overflow)
    load_i = 1;
    load_val_i = 4'hF;
    #10;
    load_i = 0;
    #30;

    check_result;
end

// Continuous checking
always @(posedge clk) begin
    #1; // Small delay to allow outputs to settle
    if(expected_out !== count_o) begin
        ERR_COUNT = ERR_COUNT + 1;
        $error("%0tns count_o = %h, expected = %h (load_i=%b, load_val_i=%h)",
               $time, count_o, expected_out, load_i, load_val_i);
    end else begin
        $display("%0tns count_o = %h, load_i = %b, load_val_i = %h", $time, count_o, load_i, load_val_i);
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