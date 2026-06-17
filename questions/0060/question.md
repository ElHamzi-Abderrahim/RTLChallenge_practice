# Register File Max Finder

## Problem Statement

Design a max finder that scans through a register file (stored in SRAM) and finds the maximum value and its index.

**Important**: You MUST instantiate the `sram_model` module (defined in tb.sv) inside your design.

### Module Interface
- **Module Name**: `regfile_max`
- **Parameters**:
  - `ADDR_WIDTH` (default: 4) - Number of registers = 2^ADDR_WIDTH
  - `DATA_WIDTH` (default: 8) - Data width per register
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start max search (scans from addr 0 to count-1)
  - `count[ADDR_WIDTH-1:0]`: Number of registers to search
  - `write_en`: Write enable for register file
  - `write_addr[ADDR_WIDTH-1:0]`: Write address
  - `write_data[DATA_WIDTH-1:0]`: Write data
- **Outputs**:
  - `busy`: Search in progress
  - `done`: Search complete (pulse)
  - `max_val[DATA_WIDTH-1:0]`: Maximum value found
  - `max_idx[ADDR_WIDTH-1:0]`: Index of maximum value

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ADDR_WIDTH` | 4 | Address width |
| `DATA_WIDTH` | 8 | Data width |

### Provided Memory Model

```verilog
module sram_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rd_en,
    input  wire                  wr_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] wdata,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg                   rvalid
);
```

### Functional Requirements

1. **Write**: When `write_en=1` and not busy, write to register file
2. **Max Search**: When `start=1`:
   - Read registers 0 to count-1
   - Track maximum value and its index
   - Handle ties: keep first occurrence (lower index)
3. **Output**: Report max value and index when done

### Example Operation

```
Registers: reg[0]=50, reg[1]=30, reg[2]=90, reg[3]=20

start=1, count=4

Result: max_val=90, max_idx=2
```

### Design Template

```verilog
module regfile_max #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] count,
    input  wire                  write_en,
    input  wire [ADDR_WIDTH-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0] write_data,
    output wire                  busy,
    output wire                  done,
    output wire [DATA_WIDTH-1:0] max_val,
    output wire [ADDR_WIDTH-1:0] max_idx
);

    // Memory interface
    reg                   mem_rd_en;
    reg                   mem_wr_en;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    sram_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_sram (
        .clk(clk),
        .rd_en(mem_rd_en),
        .wr_en(mem_wr_en),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .rdata(mem_rdata),
        .rvalid(mem_rvalid)
    );

    // Your implementation here...

endmodule
```

### Hints

- State machine: IDLE -> READ -> WAIT -> COMPARE -> (loop) -> DONE
- Track current_max and current_max_idx
- Initialize max to 0 (or first value)
- Handle count=0 edge case

## Constraint
- Your design MUST instantiate `sram_model` from tb.sv
