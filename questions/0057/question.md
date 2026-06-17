# Histogram Calculator

## Problem Statement

Design a histogram calculator that counts occurrences of input values. Each bin in the histogram is stored in SRAM and incremented when the corresponding value appears.

**Important**: You MUST instantiate the `sram_rw_model` module (defined in tb.sv) inside your design to store histogram bins.

### Module Interface
- **Module Name**: `histogram_calc`
- **Parameters**:
  - `BIN_ADDR_WIDTH` (default: 4) - Number of bins = 2^BIN_ADDR_WIDTH
  - `COUNT_WIDTH` (default: 8) - Counter bit width per bin
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `clear`: Clear all histogram bins to 0
  - `data_valid`: Input data valid
  - `data_in[BIN_ADDR_WIDTH-1:0]`: Input value (determines which bin to increment)
  - `read_req`: Request to read a bin
  - `read_addr[BIN_ADDR_WIDTH-1:0]`: Bin address to read
- **Outputs**:
  - `ready`: Ready to accept new data
  - `read_valid`: Read data valid
  - `read_data[COUNT_WIDTH-1:0]`: Bin count value

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `BIN_ADDR_WIDTH` | 4 | Bin address width (16 bins) |
| `COUNT_WIDTH` | 8 | Bits per bin counter |

### Provided Memory Model

```verilog
module sram_rw_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  req,
    input  wire                  wr,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] wdata,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg                   rvalid
);
```

### Functional Requirements

1. **Increment Bin**: When `data_valid=1`, increment bin[data_in] by 1
2. **Read Bin**: When `read_req=1`, return bin[read_addr] count
3. **Clear**: When `clear=1`, reset all bins to 0 (may take multiple cycles)
4. **Saturation**: Bins saturate at max value (don't overflow)

### Example Operation

```
Input sequence: 3, 1, 3, 3, 2, 1

Result:
  bin[0] = 0
  bin[1] = 2
  bin[2] = 1
  bin[3] = 3
```

### Design Template

```verilog
module histogram_calc #(
    parameter BIN_ADDR_WIDTH = 4,
    parameter COUNT_WIDTH    = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      clear,
    input  wire                      data_valid,
    input  wire [BIN_ADDR_WIDTH-1:0] data_in,
    input  wire                      read_req,
    input  wire [BIN_ADDR_WIDTH-1:0] read_addr,
    output wire                      ready,
    output wire                      read_valid,
    output wire [COUNT_WIDTH-1:0]    read_data
);

    // Memory interface
    reg                      mem_req;
    reg                      mem_wr;
    reg  [BIN_ADDR_WIDTH-1:0] mem_addr;
    reg  [COUNT_WIDTH-1:0]    mem_wdata;
    wire [COUNT_WIDTH-1:0]    mem_rdata;
    wire                      mem_rvalid;

    sram_rw_model #(
        .ADDR_WIDTH(BIN_ADDR_WIDTH),
        .DATA_WIDTH(COUNT_WIDTH)
    ) u_sram (
        .clk(clk),
        .req(mem_req),
        .wr(mem_wr),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .rdata(mem_rdata),
        .rvalid(mem_rvalid)
    );

    // Your implementation here...

endmodule
```

### Hints

- Incrementing a bin requires read-modify-write (3 cycles)
- Use saturation arithmetic to prevent overflow
- Clear operation can iterate through all addresses
- Prioritize operations: clear > increment > read

## Constraint
- Your design MUST instantiate `sram_rw_model` from tb.sv
- Handle saturation properly
