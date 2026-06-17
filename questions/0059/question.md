# Scratchpad Accumulator

## Problem Statement

Design a scratchpad accumulator that reads values from SRAM, accumulates (adds) them, and writes the result back to a specified location.

**Important**: You MUST instantiate the `sram_rw_model` module (defined in tb.sv) inside your design.

### Module Interface
- **Module Name**: `scratchpad_acc`
- **Parameters**:
  - `ADDR_WIDTH` (default: 4)
  - `DATA_WIDTH` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start accumulation
  - `src_addr[ADDR_WIDTH-1:0]`: Start address of values to accumulate
  - `count[ADDR_WIDTH-1:0]`: Number of values to accumulate (1 to 2^ADDR_WIDTH)
  - `dst_addr[ADDR_WIDTH-1:0]`: Destination address to store result
- **Outputs**:
  - `busy`: Operation in progress
  - `done`: Operation complete (pulse)
  - `result[DATA_WIDTH-1:0]`: Accumulated sum (also written to dst_addr)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ADDR_WIDTH` | 4 | Address width |
| `DATA_WIDTH` | 16 | Data width (wider for accumulation) |

### Provided Memory Model 

```verilog
module sram_rw_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
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

1. **Accumulate**: Sum mem[src_addr] + mem[src_addr+1] + ... + mem[src_addr+count-1]
2. **Store Result**: Write sum to mem[dst_addr]
3. **Output Result**: Also output sum on `result` port
4. **Overflow**: Allow natural overflow (no saturation)

### Example Operation

```
Memory: mem[0]=10, mem[1]=20, mem[2]=30, mem[3]=40

src_addr=0, count=4, dst_addr=10

Result: 10+20+30+40 = 100
mem[10] = 100
result = 100
```

### Design Template

```verilog
module scratchpad_acc #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] src_addr,
    input  wire [ADDR_WIDTH-1:0] count,
    input  wire [ADDR_WIDTH-1:0] dst_addr,
    output wire                  busy,
    output wire                  done,
    output wire [DATA_WIDTH-1:0] result
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

- State machine: IDLE -> READ -> WAIT -> ACCUMULATE -> (loop) -> WRITE -> DONE
- Use an accumulator register to sum values
- Handle count=0 edge case (result should be 0)

## Constraint
- Your design MUST instantiate `sram_rw_model` from tb.sv
