module ipv4_checksum (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        in_valid,
    input  wire [15:0] in_data,
    input  wire        in_last,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire [15:0] out_checksum,
    output wire        out_valid_hdr
);

    // State machine
    localparam IDLE   = 2'd0;
    localparam SUM    = 2'd1;
    localparam FOLD   = 2'd2;
    localparam OUTPUT = 2'd3;

    reg [1:0] state, next_state;

    // Accumulator (32 bits to handle carries)
    reg [31:0] sum_reg;
    wire [31:0] folded_sum;
    wire [16:0] fold_once;

    // State transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start)
                    next_state = SUM;
            end
            SUM: begin
                if (in_valid && in_ready && in_last)
                    next_state = FOLD;
            end
            FOLD: begin
                if (sum_reg[31:16] == 16'd0)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
        endcase
    end

    // Accumulator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg <= 32'd0;
        end else if (start) begin
            sum_reg <= 32'd0;
        end else if (state == SUM && in_valid && in_ready) begin
            sum_reg <= sum_reg + {16'd0, in_data};
        end else if (state == FOLD && sum_reg[31:16] != 16'd0) begin
            // Fold carries
            sum_reg <= {16'd0, sum_reg[15:0]} + {16'd0, sum_reg[31:16]};
        end
    end

    // Output assignments
    assign in_ready      = (state == SUM);
    assign out_valid     = (state == OUTPUT);
    assign out_checksum  = ~sum_reg[15:0];
    assign out_valid_hdr = (sum_reg[15:0] == 16'hFFFF);

endmodule
