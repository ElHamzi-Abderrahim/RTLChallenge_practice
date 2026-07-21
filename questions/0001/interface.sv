module subtractor #(
    parameter INPUT_WIDTH = 8
)(
    input  wire [INPUT_WIDTH-1:0]              data_in_1,
    input  wire [INPUT_WIDTH-1:0]              data_in_2,
    output wire [INPUT_WIDTH-1:0]                data_out
);
    wire [INPUT_WIDTH-1:0] borrow_out, data_out_s, in1_xor_in2 ;
    wire borrow_in ;

    assign borrow_in = 1'b0 ;

    genvar i ;

    // cap to 0 when data_in_1 - data_in_2 < 0.
    assign data_out     = (data_in_2 > data_in_1) ? 'b0 : data_out_s ;

    assign in1_xor_in2[0]   = data_in_1[0] ^ data_in_2[0] ;
    assign data_out_s[0]    = in1_xor_in2[0] ^ borrow_in ;
    assign borrow_out[0]    = (~in1_xor_in2[0] & borrow_in) | (~data_in_1[0] & data_in_2[0]) ;

    generate
        for ( i=1; i<INPUT_WIDTH; i=i+1 ) begin
            assign in1_xor_in2[i]   = data_in_1[i] ^ data_in_2[i] ;
            assign data_out_s[i]    = in1_xor_in2[i] ^ borrow_out[i-1] ;
            assign borrow_out[i]    = (~in1_xor_in2[i] & borrow_out[i-1]) | (~data_in_1[i] & data_in_2[i]) ;
        end
    endgenerate

endmodule
