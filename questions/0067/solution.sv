module moving_max #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_SIZE = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  out_ready,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_max
);

    localparam PTR_WIDTH = $clog2(WINDOW_SIZE);
    localparam CNT_WIDTH = $clog2(WINDOW_SIZE + 1);

    // Circular buffer holding the most recent WINDOW_SIZE samples
    reg [DATA_WIDTH-1:0] buffer [0:WINDOW_SIZE-1];
    reg [PTR_WIDTH-1:0]  wr_ptr;
    reg [CNT_WIDTH-1:0]  count;  // Number of valid entries (saturates at WINDOW_SIZE)

    wire in_handshake  = in_valid && in_ready;
    wire out_handshake = out_valid && out_ready;

    // Combinationally compute the max over the window AFTER the incoming
    // sample is written: slot wr_ptr takes in_data, evicting whatever was
    // there. When the window is not yet full, wr_ptr == count and the valid
    // indices are 0..count (the count old entries plus the new one).
    reg [DATA_WIDTH-1:0] next_max;
    reg [DATA_WIDTH-1:0] vi;
    integer i;

    always @(*) begin
        next_max = {DATA_WIDTH{1'b0}};
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
            vi = (i == wr_ptr) ? in_data : buffer[i];
            if (i <= count) begin
                if (vi > next_max)
                    next_max = vi;
            end
        end
    end

    integer k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr    <= {PTR_WIDTH{1'b0}};
            count     <= {CNT_WIDTH{1'b0}};
            in_ready  <= 1'b1;
            out_valid <= 1'b0;
            out_max   <= {DATA_WIDTH{1'b0}};
            for (k = 0; k < WINDOW_SIZE; k = k + 1)
                buffer[k] <= {DATA_WIDTH{1'b0}};
        end else if (start) begin
            wr_ptr    <= {PTR_WIDTH{1'b0}};
            count     <= {CNT_WIDTH{1'b0}};
            in_ready  <= 1'b1;
            out_valid <= 1'b0;
            for (k = 0; k < WINDOW_SIZE; k = k + 1)
                buffer[k] <= {DATA_WIDTH{1'b0}};
        end else begin
            if (out_handshake)
                out_valid <= 1'b0;

            if (in_handshake) begin
                buffer[wr_ptr] <= in_data;
                wr_ptr <= (wr_ptr == WINDOW_SIZE - 1) ? {PTR_WIDTH{1'b0}} : wr_ptr + 1'b1;
                if (count < WINDOW_SIZE)
                    count <= count + 1'b1;

                out_max   <= next_max;
                out_valid <= 1'b1;
                in_ready  <= 1'b0;
            end else if (!out_valid || out_handshake) begin
                in_ready <= 1'b1;
            end
        end
    end

endmodule
