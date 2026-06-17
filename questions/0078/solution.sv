module conv_1d #(
    parameter DATA_WIDTH = 8,
    parameter KERNEL_SIZE = 3
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  kernel_valid,
    input  wire [DATA_WIDTH-1:0] kernel_data,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire                  out_ready,
    output reg                   kernel_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH*2+$clog2(KERNEL_SIZE)-1:0] out_data,
    output reg                   out_last
);

    localparam OUT_WIDTH = DATA_WIDTH * 2 + $clog2(KERNEL_SIZE);
    localparam CNT_WIDTH = $clog2(KERNEL_SIZE + 1);

    localparam IDLE        = 2'd0;
    localparam LOAD_KERNEL = 2'd1;
    localparam RUN         = 2'd2;
    localparam EMIT        = 2'd3;

    reg [1:0] state;
    // window[0] = oldest sample, window[KERNEL_SIZE-1] = newest sample
    reg [DATA_WIDTH-1:0] kernel [0:KERNEL_SIZE-1];
    reg [DATA_WIDTH-1:0] window [0:KERNEL_SIZE-1];
    reg [CNT_WIDTH-1:0]  k_idx;
    reg [CNT_WIDTH-1:0]  w_count;   // samples currently captured (saturates)
    reg pending_last;

    // Convolution over the window that WILL exist after shifting in_data in:
    //   sw[i] = window[i+1] for i < K-1, sw[K-1] = in_data
    //   out = sum_i sw[i] * kernel[i]   (matches input[idx+k]*kernel[k])
    reg [OUT_WIDTH-1:0] conv_next;
    integer j;
    always @(*) begin
        conv_next = {OUT_WIDTH{1'b0}};
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
            if (j < KERNEL_SIZE - 1)
                conv_next = conv_next + window[j+1] * kernel[j];
            else
                conv_next = conv_next + in_data * kernel[j];
        end
    end

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            kernel_ready <= 1'b0;
            in_ready     <= 1'b0;
            out_valid    <= 1'b0;
            out_data     <= {OUT_WIDTH{1'b0}};
            out_last     <= 1'b0;
            k_idx        <= {CNT_WIDTH{1'b0}};
            w_count      <= {CNT_WIDTH{1'b0}};
            pending_last <= 1'b0;
            for (k = 0; k < KERNEL_SIZE; k = k + 1) begin
                kernel[k] <= {DATA_WIDTH{1'b0}};
                window[k] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 1'b0;
                    out_last  <= 1'b0;
                    if (start) begin
                        state        <= LOAD_KERNEL;
                        kernel_ready <= 1'b1;
                        k_idx        <= {CNT_WIDTH{1'b0}};
                        w_count      <= {CNT_WIDTH{1'b0}};
                        for (k = 0; k < KERNEL_SIZE; k = k + 1)
                            window[k] <= {DATA_WIDTH{1'b0}};
                    end
                end

                LOAD_KERNEL: begin
                    if (kernel_valid && kernel_ready) begin
                        kernel[k_idx] <= kernel_data;
                        k_idx <= k_idx + 1'b1;
                        if (k_idx == KERNEL_SIZE - 1) begin
                            kernel_ready <= 1'b0;
                            state        <= RUN;
                            in_ready     <= 1'b1;
                        end
                    end
                end

                RUN: begin
                    if (in_valid && in_ready) begin
                        // Shift in_data into the window (newest at top index)
                        for (k = 0; k < KERNEL_SIZE - 1; k = k + 1)
                            window[k] <= window[k+1];
                        window[KERNEL_SIZE-1] <= in_data;

                        if (w_count < KERNEL_SIZE)
                            w_count <= w_count + 1'b1;

                        if (w_count >= KERNEL_SIZE - 1) begin
                            // This sample completes a full window -> emit
                            in_ready     <= 1'b0;
                            state        <= EMIT;
                            out_valid    <= 1'b1;
                            out_data     <= conv_next;
                            out_last     <= in_last;
                            pending_last <= in_last;
                        end else if (in_last) begin
                            // Fewer than KERNEL_SIZE samples: no output
                            in_ready <= 1'b0;
                            state    <= IDLE;
                        end
                    end
                end

                EMIT: begin
                    if (out_valid && out_ready) begin
                        out_valid <= 1'b0;
                        out_last  <= 1'b0;
                        if (pending_last) begin
                            state <= IDLE;
                        end else begin
                            state    <= RUN;
                            in_ready <= 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
