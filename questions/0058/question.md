# Memory Copy Controller

## Problem Statement

Design a memory copy controller (similar to DMA) that copies data from one address range to another within SRAM.

**Important**: You MUST instantiate the `sram_rw_model` module (defined in tb.sv) inside your design.

### Module Interface
- **Module Name**: `mem_copy_ctrl`
- **Parameters**:
  - `ADDR_WIDTH` (default: 8)
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start copy operation
  - `src_addr[ADDR_WIDTH-1:0]`: Source start address
  - `dst_addr[ADDR_WIDTH-1:0]`: Destination start address
  - `length[ADDR_WIDTH-1:0]`: Number of words to copy (1 to 2^ADDR_WIDTH)
- **Outputs**:
  - `busy`: Operation in progress
  - `done`: Operation complete (pulse)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ADDR_WIDTH` | 8 | Address width |
| `DATA_WIDTH` | 8 | Data width |

### Provided Memory Model

```verilog
module sram_rw_model #(
    parameter ADDR_WIDTH = 8,
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

1. **Copy Operation**: When `start=1`:
   - Copy `length` words from src_addr to dst_addr
   - mem[dst_addr+i] = mem[src_addr+i] for i = 0 to length-1
2. **Busy Signal**: Assert while operation is in progress
3. **Done Signal**: Pulse high for one cycle when complete
4. **Overlap Handling**: Source and destination can overlap (copy low-to-high)

### Example Operation

```
src_addr=0x10, dst_addr=0x20, length=4

Before: mem[0x10..0x13] = {AA, BB, CC, DD}
After:  mem[0x20..0x23] = {AA, BB, CC, DD}
```

### Timing

- Read has 1-cycle latency
- Each word copy takes ~3 cycles (read + wait + write)
- Total time: ~3 * length cycles

### Design Template

```verilog
module mem_copy_ctrl #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] src_addr,
    input  wire [ADDR_WIDTH-1:0] dst_addr,
    input  wire [ADDR_WIDTH-1:0] length,
    output wire                  busy,
    output wire                  done
);

    // Memory interface
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    sram_rw_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
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

- State machine: IDLE -> READ -> WAIT_READ -> WRITE -> (loop or DONE)
- Track current offset from start
- Latch parameters when start is asserted
- Handle length=0 edge case

## Constraint
- Your design MUST instantiate `sram_rw_model` from tb.sv
