module population_counter #(
    parameter INPUT_WIDTH = 8,
    parameter COUNT_WIDTH = 3
)(
    input  wire [INPUT_WIDTH-1:0]    data_in,
    output wire [COUNT_WIDTH-1:0]    count_out
);

    integer i;
    reg [COUNT_WIDTH-1:0] count;
    
    always @(*) begin
        count = {COUNT_WIDTH{1'b0}};
        for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
            count = count + data_in[i];
        end
    end
    
    assign count_out = count;

endmodule
