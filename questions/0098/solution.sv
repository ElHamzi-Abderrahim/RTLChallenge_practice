module mac_unit #(
    parameter DATA_WIDTH = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         clear,
    input  wire                         in_valid,
    input  wire signed [DATA_WIDTH-1:0] in_a,
    input  wire signed [DATA_WIDTH-1:0] in_b,
    input  wire                         in_last,
    input  wire                         out_ready,
    output wire                         in_ready,
    output wire                         out_valid,
    output wire signed [DATA_WIDTH*2+7:0] out_acc
);

    localparam ACC_WIDTH = DATA_WIDTH * 2 + 8;

    // State machine
    localparam IDLE   = 2'd0;
    localparam MAC    = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state, next_state;

    // Accumulator
    reg signed [ACC_WIDTH-1:0] acc_reg;
    wire signed [DATA_WIDTH*2-1:0] product;

    assign product = in_a * in_b;

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
                if (clear)
                    next_state = MAC;
            end
            MAC: begin
                if (in_valid && in_ready && in_last)
                    next_state = OUTPUT;
            end
            OUTPUT: begin
                if (out_valid && out_ready)
                    next_state = IDLE;
            end
        endcase
    end

    // MAC operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg <= {ACC_WIDTH{1'b0}};
        end else if (clear) begin
            acc_reg <= {ACC_WIDTH{1'b0}};
        end else if (state == MAC && in_valid && in_ready) begin
            acc_reg <= acc_reg + {{(ACC_WIDTH-DATA_WIDTH*2){product[DATA_WIDTH*2-1]}}, product};
        end
    end

    // Output assignments
    assign in_ready  = (state == MAC);
    assign out_valid = (state == OUTPUT);
    assign out_acc   = acc_reg;

endmodule
