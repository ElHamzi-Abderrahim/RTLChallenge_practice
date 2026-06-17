module stopwatch_timer (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire        clear,
    output wire [5:0]  minutes,
    output wire [5:0]  seconds,
    output wire [3:0]  tenths,
    output wire        running
);

reg [5:0] min_reg;
reg [5:0] sec_reg;
reg [3:0] tenth_reg;
reg running_reg;
reg [15:0] clk_count;

// Assume 100Hz clock frequency for faster simulation
localparam CLK_FREQ = 100;
localparam CLKS_PER_TENTH = CLK_FREQ / 10;  // 10 clocks per 0.1 second

always @(posedge clk or posedge reset) begin
    if (reset) begin
        running_reg <= 1'b0;
    end else if (start) begin
        running_reg <= 1'b1; 
    end else begin
        running_reg <= 1'b0; 
    end
end

always @(posedge clk, posedge reset) begin
    if (reset) begin
        min_reg <= 6'd0;
        sec_reg <= 6'd0;
        tenth_reg <= 4'd0;
        clk_count <= 16'd0;
    end 
    // Handle clear - resets time but not running state
    else if (clear) begin
        min_reg <= 6'd0;
        sec_reg <= 6'd0;
        tenth_reg <= 4'd0;
        clk_count <= 16'd0;
    // Handle counting when running (only if not toggling or clearing)
    end else if (start) begin
        if (clk_count == CLKS_PER_TENTH - 1) begin
            clk_count <= 16'd0;
            if (tenth_reg == 4'd9) begin
                tenth_reg <= 4'd0;
                if (sec_reg == 6'd59) begin
                    sec_reg <= 6'd0;
                    if (min_reg == 6'd59) begin
                        min_reg <= 6'd0;
                    end else begin
                        min_reg <= min_reg + 1'b1;
                    end
                end else begin
                    sec_reg <= sec_reg + 1'b1;
                end
            end else begin
                tenth_reg <= tenth_reg + 1'b1;
            end
        end else begin
            clk_count <= clk_count + 1'b1;
        end
    end
end

assign minutes = min_reg;
assign seconds = sec_reg;
assign tenths = tenth_reg;
assign running = running_reg;

endmodule
