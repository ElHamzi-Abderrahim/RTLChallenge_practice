module mem_interface (
  input       wire        clk,
  input       wire        reset,

  input       wire        req_i,
  input       wire        req_rnw_i,    // 1 - read, 0 - write
  input       wire[3:0]   req_addr_i,
  input       wire[31:0]  req_wdata_i,
  output      wire        req_ready_o,
  output      wire[31:0]  req_rdata_o
);

reg [31:0] memory [0:15];
reg [2:0] delay_counter;
reg [3:0] addr_reg;
reg rnw_reg;
reg busy;
reg req_prev;

wire req_edge;
assign req_edge = req_i & ~req_prev;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        delay_counter <= 3'd0;
        addr_reg <= 4'd0;
        rnw_reg <= 1'b0;
        busy <= 1'b0;
        req_prev <= 1'b0;
        memory[0] <= 32'd0;
        memory[1] <= 32'd0;
        memory[2] <= 32'd0;
        memory[3] <= 32'd0;
        memory[4] <= 32'd0;
        memory[5] <= 32'd0;
        memory[6] <= 32'd0;
        memory[7] <= 32'd0;
        memory[8] <= 32'd0;
        memory[9] <= 32'd0;
        memory[10] <= 32'd0;
        memory[11] <= 32'd0;
        memory[12] <= 32'd0;
        memory[13] <= 32'd0;
        memory[14] <= 32'd0;
        memory[15] <= 32'd0;
    end else begin
        req_prev <= req_i;

        if (req_edge) begin
            busy <= 1'b1;
            delay_counter <= 3'd3;
            addr_reg <= req_addr_i;
            rnw_reg <= req_rnw_i;
        end else if (busy) begin
            if (delay_counter == 3'd0) begin
                if (!rnw_reg) begin
                    memory[addr_reg] <= req_wdata_i;
                end
                busy <= 1'b0;
            end else begin
                delay_counter <= delay_counter - 1'b1;
            end
        end
    end
end

assign req_ready_o = (busy && delay_counter == 3'd0);
assign req_rdata_o = memory[addr_reg];

endmodule
