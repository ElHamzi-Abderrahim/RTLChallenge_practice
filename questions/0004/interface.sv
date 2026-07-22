module ripple_counter #(
    parameter COUNTER_WIDTH = 4
)(
    input  wire                                clk,
    input  wire                                rst_n,
    output wire [COUNTER_WIDTH-1:0]            count_out
);

    reg [COUNTER_WIDTH-1:0] count_out_reg ;

    always_ff @( posedge clk, negedge rst_n ) begin
        if(!rst_n) begin
            count_out_reg <= {COUNTER_WIDTH{1'b0}} ;
        end else begin
            count_out_reg <= (count_out_reg == {COUNTER_WIDTH{1'b1}}) ? {COUNTER_WIDTH{1'b0}} : count_out_reg+1 ;
        end
    end

    assign count_out = count_out_reg ;

endmodule
