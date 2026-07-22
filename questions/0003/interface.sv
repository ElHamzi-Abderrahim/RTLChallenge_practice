module ring_counter #(
    parameter COUNTER_WIDTH = 4
)(
    input  wire                                clk,
    input  wire                                rst_n,
    output wire [COUNTER_WIDTH-1:0]            count_out
);

    logic [COUNTER_WIDTH-1:0] count_out_reg ;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            count_out_reg <= 'b1 ;
        end
        else begin
            for(integer i=1; i < COUNTER_WIDTH; i = i+1) begin
                count_out_reg[i] <= count_out_reg[i-1] ;
            end

            count_out_reg[0] <= count_out_reg[COUNTER_WIDTH-1] ;
        end
    end

    assign count_out = count_out_reg ;


endmodule
