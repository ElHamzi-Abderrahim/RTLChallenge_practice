module dual_edge_dff #(
    parameter DATA_WIDTH = 8
)(
    input  wire                                clk,
    input  wire                                rst_n,
    input  wire [DATA_WIDTH-1:0]               data_in,
    output wire [DATA_WIDTH-1:0]               data_out
);

    reg [DATA_WIDTH-1:0] data_out_p, data_out_n, data_out_ff ;

    assign data_out_ff  = (clk) ? data_out_p : data_out_n ; // implement a mux
    
    assign data_out     = (rst_n) ? data_out_ff : {DATA_WIDTH{1'b0}} ; // mux for asynchronous reset

    always_ff @( posedge clk, negedge rst_n ) begin : pos_edge_ff
        if (!rst_n) begin
            data_out_p <= {DATA_WIDTH{1'b0}};
        end else begin
            data_out_p <= data_in ;
        end
    end
    
    always_ff @( negedge clk, negedge rst_n ) begin : neg_edge_ff
        if (!rst_n) begin
            data_out_n <= {DATA_WIDTH{1'b0}};
        end else begin
            data_out_n <= data_in ;
        end
    end

endmodule
