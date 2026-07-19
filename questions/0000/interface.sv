module adder #(
    parameter INPUT_WIDTH = 8
)(
    input  wire [INPUT_WIDTH-1:0]              data_in_1,
    input  wire [INPUT_WIDTH-1:0]              data_in_2,
    output wire [INPUT_WIDTH:0]                data_out
);
    
    wire carry_in;
    wire carry_out[INPUT_WIDTH-1:0] ;

    assign carry_in = 1'b0 ;
    assign data_out[0]     = (data_in_1[0] ^ data_in_2[0]) ^ carry_in ;
    assign carry_out[0]    = (data_in_1[0] & data_in_2[0]) | ((data_in_1[0] ^ data_in_2[0]) & carry_in) ;
    
    `define GENERATE_BLOCK
    `ifdef GENERATE_BLOCK
    genvar i;
    generate
        for(i=1; i<INPUT_WIDTH; i=i+1) begin : binary_adder_gen
            assign data_out[i]     = (data_in_1[i] ^ data_in_2[i]) ^ carry_out[i-1] ;
            assign carry_out[i]    = (data_in_1[i] & data_in_2[i]) | ((data_in_1[i] ^ data_in_2[i]) & carry_out[i-1]);
        end
    endgenerate
    
    assign data_out[INPUT_WIDTH] = carry_out[INPUT_WIDTH-1] ;
    `endif

    `ifdef ALWAYS_BLOCK
    always_comb begin : binary_adder_alwayscomb
        for(integer i=1; i<INPUT_WIDTH; i=i+1) begin
            data_out[i]     = (data_in_1[i] ^ data_in_2[i]) ^ carry_out[i-1] ;
            carry_out[i]    = (data_in_1[i] & data_in_2[i]) | ((data_in_1[i] ^ data_in_2[i]) & carry_out[i-1]);
        end
        data_out[INPUT_WIDTH] = carry_out[INPUT_WIDTH-1] ;
    end
    `endif

endmodule