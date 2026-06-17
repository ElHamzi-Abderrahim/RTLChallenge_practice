module carry_lookahead_adder #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0]    a_in,
    input  wire [WIDTH-1:0]    b_in,
    input  wire                c_in,
    output wire [WIDTH-1:0]    sum_out,
    output wire                c_out
);

    wire [WIDTH-1:0] g;  // Generate signals
    wire [WIDTH-1:0] p;  // Propagate signals
    wire [WIDTH:0] c;    // Carry signals
    
    // Generate and Propagate for each bit
    assign g = a_in & b_in;
    assign p = a_in ^ b_in;
    
    // Carry chain
    assign c[0] = c_in;
    
    generate
        genvar i;
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_gen
            if (i == 0) begin
                assign c[i+1] = g[i] | (p[i] & c[i]);
            end else if (i == 1) begin
                assign c[i+1] = g[i] | (p[i] & g[i-1]) | (p[i] & p[i-1] & c[0]);
            end else if (i == 2) begin
                assign c[i+1] = g[i] | (p[i] & g[i-1]) | (p[i] & p[i-1] & g[i-2]) | 
                               (p[i] & p[i-1] & p[i-2] & c[0]);
            end else if (i == 3) begin
                assign c[i+1] = g[i] | (p[i] & g[i-1]) | (p[i] & p[i-1] & g[i-2]) | 
                               (p[i] & p[i-1] & p[i-2] & g[i-3]) | 
                               (p[i] & p[i-1] & p[i-2] & p[i-3] & c[0]);
            end else begin
                // For WIDTH > 4, use simplified carry chain
                assign c[i+1] = g[i] | (p[i] & c[i]);
            end
        end
    endgenerate
    
    // Sum calculation
    assign sum_out = p ^ c[WIDTH-1:0];
    
    // Output carry
    assign c_out = c[WIDTH];
  
endmodule
