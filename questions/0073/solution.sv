module min_max #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_min,
    output reg  [DATA_WIDTH-1:0] out_max
);

    localparam IDLE   = 2'd0;
    localparam INPUT  = 2'd1;
    localparam OUTPUT = 2'd2;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] curr_min;
    reg [DATA_WIDTH-1:0] curr_max;
    reg first_value;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            in_ready    <= 1'b0;
            out_valid   <= 1'b0;
            out_min     <= {DATA_WIDTH{1'b0}};
            out_max     <= {DATA_WIDTH{1'b0}};
            curr_min    <= {DATA_WIDTH{1'b1}};
            curr_max    <= {DATA_WIDTH{1'b0}};
            first_value <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    if (start) begin
                        state       <= INPUT;
                        in_ready    <= 1'b1;
                        curr_min    <= {DATA_WIDTH{1'b1}};
                        curr_max    <= {DATA_WIDTH{1'b0}};
                        first_value <= 1'b1;
                    end
                end

                INPUT: begin
                    if (in_valid && in_ready) begin
                        // Update min/max
                        if (first_value) begin
                            curr_min    <= in_data;
                            curr_max    <= in_data;
                            first_value <= 1'b0;
                        end else begin
                            if (in_data < curr_min)
                                curr_min <= in_data;
                            if (in_data > curr_max)
                                curr_max <= in_data;
                        end

                        if (in_last) begin
                            in_ready  <= 1'b0;
                            state     <= OUTPUT;
                            out_valid <= 1'b1;

                            // Set output values
                            if (first_value) begin
                                // First and last value
                                out_min <= in_data;
                                out_max <= in_data;
                            end else begin
                                out_min <= (in_data < curr_min) ? in_data : curr_min;
                                out_max <= (in_data > curr_max) ? in_data : curr_max;
                            end
                        end
                    end
                end

                OUTPUT: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        state     <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
