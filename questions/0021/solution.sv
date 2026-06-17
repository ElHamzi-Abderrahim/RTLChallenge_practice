module round_robin_arbiter (
  input     wire        clk,
  input     wire        reset,

  input     wire[3:0]   req_i,
  output    reg[3:0]    gnt_o
);

reg [1:0] last_gnt;
reg [3:0] gnt_next;

// Combinational logic to compute next grant
always @(*) begin
    gnt_next = 4'b0000;

    if (|req_i) begin
        case (last_gnt)
            2'd0: begin
                if (req_i[1]) gnt_next = 4'b0010;
                else if (req_i[2]) gnt_next = 4'b0100;
                else if (req_i[3]) gnt_next = 4'b1000;
                else if (req_i[0]) gnt_next = 4'b0001;
            end
            2'd1: begin
                if (req_i[2]) gnt_next = 4'b0100;
                else if (req_i[3]) gnt_next = 4'b1000;
                else if (req_i[0]) gnt_next = 4'b0001;
                else if (req_i[1]) gnt_next = 4'b0010;
            end
            2'd2: begin
                if (req_i[3]) gnt_next = 4'b1000;
                else if (req_i[0]) gnt_next = 4'b0001;
                else if (req_i[1]) gnt_next = 4'b0010;
                else if (req_i[2]) gnt_next = 4'b0100;
            end
            2'd3: begin
                if (req_i[0]) gnt_next = 4'b0001;
                else if (req_i[1]) gnt_next = 4'b0010;
                else if (req_i[2]) gnt_next = 4'b0100;
                else if (req_i[3]) gnt_next = 4'b1000;
            end
        endcase
    end
end

// Sequential logic to register output and update last_gnt
always @(posedge clk or posedge reset) begin
    if (reset) begin
        gnt_o <= 4'b0000;
        last_gnt <= 2'b11;
    end else begin
        gnt_o <= gnt_next;
        if (|gnt_next) begin
            if (gnt_next[0]) last_gnt <= 2'd0;
            else if (gnt_next[1]) last_gnt <= 2'd1;
            else if (gnt_next[2]) last_gnt <= 2'd2;
            else if (gnt_next[3]) last_gnt <= 2'd3;
        end
    end
end

endmodule
