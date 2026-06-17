module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input  wire                      wr_clk,
    input  wire                      wr_rst_n,
    input  wire                      wr_en,
    input  wire [DATA_WIDTH-1:0]     wr_data,
    output wire                      wr_full,

    input  wire                      rd_clk,
    input  wire                      rd_rst_n,
    input  wire                      rd_en,
    output wire [DATA_WIDTH-1:0]     rd_data,
    output wire                      rd_empty
);
// your implementation here

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
     
    // Memory array
    reg [DATA_WIDTH-1:0] memory [0:FIFO_DEPTH-1];
    
    // Gray code pointers
    reg [ADDR_WIDTH:0] wr_ptr_gray, wr_ptr_gray_next;
    reg [ADDR_WIDTH:0] rd_ptr_gray, rd_ptr_gray_next;
    
    // Binary pointers
    reg [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_bin_next;
    reg [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_bin_next;
    
    // Synchronized pointers
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    
    // Binary to Gray conversion function
    function [ADDR_WIDTH:0] bin2gray;
        input [ADDR_WIDTH:0] bin;
        begin
            bin2gray = bin ^ (bin >> 1);
        end
    endfunction
    
    // Gray to Binary conversion function
    function [ADDR_WIDTH:0] gray2bin;
        input [ADDR_WIDTH:0] gray;
        integer i;
        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH-1; i >= 0; i = i - 1) begin
                gray2bin[i] = gray2bin[i+1] ^ gray[i];
            end
        end
    endfunction
    
    // Write clock domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin <= {(ADDR_WIDTH+1){1'b0}};
            wr_ptr_gray <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            wr_ptr_bin <= wr_ptr_bin_next;
            wr_ptr_gray <= wr_ptr_gray_next;
        end
    end
    
    always @(*) begin
        wr_ptr_bin_next = wr_ptr_bin;
        wr_ptr_gray_next = wr_ptr_gray;
        
        if (wr_en && !wr_full) begin
            wr_ptr_bin_next = wr_ptr_bin + 1'b1;
            wr_ptr_gray_next = bin2gray(wr_ptr_bin_next);
        end
    end
    
    // Write to memory
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            // reset memory 
            integer i;
            for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
                memory[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
        if (wr_en && !wr_full) begin
            memory[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
        end
        end
    end
    
    // Synchronize read pointer to write clock domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= {(ADDR_WIDTH+1){1'b0}};
            rd_ptr_gray_sync2 <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end
    
    // Full flag generation
    assign wr_full = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], 
                                       rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});
    
    // Read clock domain
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin <= {(ADDR_WIDTH+1){1'b0}};
            rd_ptr_gray <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            rd_ptr_bin <= rd_ptr_bin_next;
            rd_ptr_gray <= rd_ptr_gray_next;
        end
    end
    
    always @(*) begin
        rd_ptr_bin_next = rd_ptr_bin;
        rd_ptr_gray_next = rd_ptr_gray;
        
        if (rd_en && !rd_empty) begin
            rd_ptr_bin_next = rd_ptr_bin + 1'b1;
            rd_ptr_gray_next = bin2gray(rd_ptr_bin_next);
        end
    end
    
    // Synchronize write pointer to read clock domain
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_sync1 <= {(ADDR_WIDTH+1){1'b0}};
            wr_ptr_gray_sync2 <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end
    
    // Empty flag generation
    assign rd_empty = (rd_ptr_gray == wr_ptr_gray_sync2);
    
    // Read from memory
    assign rd_data = memory[rd_ptr_bin[ADDR_WIDTH-1:0]];

endmodule
