module simple_mux #(
    parameter DATA_WIDTH = 8,
    parameter SELECT_WIDTH = 2
)(
    input  wire [DATA_WIDTH*(2**SELECT_WIDTH)-1:0] data_in,
    input  wire [SELECT_WIDTH-1:0]                 sel,
    output wire [DATA_WIDTH-1:0]                   data_out
);

`define METHOD_2 

// using indexed part selection
`ifdef METHOD_1
assign data_out = data_in[sel*DATA_WIDTH +: DATA_WIDTH] ; 

// using a synthesisable code
`elsif METHOD_2
wire [DATA_WIDTH-1:0] data_in_array [SELECT_WIDTH**2-1:0] ;
genvar i ;

generate
    for (i=0; i < 2**SELECT_WIDTH; i = i+1) begin
        assign data_in_array[i] = data_in[(DATA_WIDTH*(i+1)) - 1 : DATA_WIDTH*i] ;
    end
endgenerate

assign data_out = data_in_array[sel];


`endif






endmodule
