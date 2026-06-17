module factorial #(
    parameter DATA_WIDTH = 32,
    parameter INPUT_WIDTH = 5
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   in_valid,
    input  wire [INPUT_WIDTH-1:0] in_n,
    input  wire                   out_ready,
    output reg                    in_ready,
    output reg                    out_valid,
    output reg  [DATA_WIDTH-1:0]  out_factorial
);

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] accumulator;
    reg [INPUT_WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            in_ready      <= 1'b1;
            out_valid     <= 1'b0;
            out_factorial <= {DATA_WIDTH{1'b0}};
            accumulator   <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
            counter       <= {INPUT_WIDTH{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    if (in_valid && in_ready) begin
                        in_ready <= 1'b0;

                        // Handle special cases
                        if (in_n <= 1) begin
                            // 0! = 1, 1! = 1
                            state         <= DONE;
                            out_valid     <= 1'b1;
                            out_factorial <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                        end else begin
                            state       <= COMPUTE;
                            accumulator <= {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                            counter     <= in_n;
                        end
                    end
                end

                COMPUTE: begin
                    // accumulator = accumulator * counter
                    accumulator <= accumulator * counter;
                    counter     <= counter - 1;

                    if (counter <= 2) begin
                        // Last multiplication
                        state         <= DONE;
                        out_valid     <= 1'b1;
                        out_factorial <= accumulator * counter;
                    end
                end

                DONE: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        in_ready  <= 1'b1;
                        state     <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
