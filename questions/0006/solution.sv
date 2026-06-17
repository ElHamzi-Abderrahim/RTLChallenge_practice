module dual_edge_dff #(
    parameter DATA_WIDTH = 8 
    )(
       input  wire clk,
       input  wire rst_n,
       input  wire [DATA_WIDTH-1:0] data_in,
       output wire [DATA_WIDTH-1:0] data_out
    );
    
    reg [DATA_WIDTH-1:0] d_in_pos;
    reg [DATA_WIDTH-1:0] q_out_pos;
    reg [DATA_WIDTH-1:0] d_in_neg;
    reg [DATA_WIDTH-1:0] q_out_neg;
    wire clk_n;

    assign clk_n = ~clk; // Invert clock for negative edge latching

    
        assign d_in_pos = data_in ^ q_out_neg;
        always @ (posedge clk or negedge rst_n) begin
            if(!rst_n) 
              q_out_pos <= 0;
            else 
                q_out_pos <= d_in_pos;
        end
        
        assign d_in_neg = (data_in ^ q_out_pos);      
        always @ (posedge clk_n or negedge rst_n) begin
            if(!rst_n)
                q_out_neg <= 0;
            else 
                q_out_neg <= d_in_neg;
        end   
        
        assign data_out = q_out_pos ^ q_out_neg;


endmodule