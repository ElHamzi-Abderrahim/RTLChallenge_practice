# Memory Read Controller

## Problem Statement

Design a memory read controller that uses an SRAM module (defined in `tb.sv`). Your controller must **instantiate the SRAM model inside your design** and read sequential addresses to compute an XOR checksum.

**Important**: You MUST instantiate the `sram_model` module (defined in tb.sv) inside your design. The testbench will verify that you use the memory correctly.

### Module Interface
- **Module Name**: `mem_read_ctrl`
- **Parameters**:
  - `ADDR_WIDTH` (default: 4)
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start signal (pulse high for one cycle to begin operation)
  - `num_reads[ADDR_WIDTH-1:0]`: Number of addresses to read (1 to 2^ADDR_WIDTH)
- **Outputs**:
  - `done`: Operation complete signal (pulse high when finished)
  - `checksum[DATA_WIDTH-1:0]`: XOR checksum of all read data

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ADDR_WIDTH` | 4 | Address width (memory has 2^ADDR_WIDTH locations) |
| `DATA_WIDTH` | 8 | Data width |

### Provided Memory Model (in tb.sv)

You must instantiate this module inside your design:

```verilog
module sram_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg                   rvalid
);
```

**Memory Behavior**:
- 1-cycle read latency
- When `rd_en=1`, data appears on `rdata` with `rvalid=1` on the next clock cycle
- Memory is pre-initialized with test patterns

### Functional Requirements

1. **Instantiate Memory**: Your design MUST instantiate `sram_model` internally
2. **Idle State**: Wait for `start` signal
3. **Read Sequence**: When `start` is asserted:
   - Read `num_reads` consecutive addresses starting from address 0
   - Accumulate XOR checksum of all read data
4. **Completion**: Assert `done` for one cycle when all reads complete
5. **Checksum**: Output final XOR checksum (XOR of all read data values)

### Example Operation

For ADDR_WIDTH=4, DATA_WIDTH=8, num_reads=3:
```
Memory contents: addr[0]=0xAA, addr[1]=0x55, addr[2]=0xFF

Cycle 1: start=1, num_reads=3
Cycle 2: rd_en=1, addr=0
Cycle 3: rvalid=1, rdata=0xAA, rd_en=1, addr=1
Cycle 4: rvalid=1, rdata=0x55, rd_en=1, addr=2
Cycle 5: rvalid=1, rdata=0xFF
Cycle 6: done=1, checksum=0xAA^0x55^0xFF=0x00
```

### Design Template

```verilog
module mem_read_ctrl #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [ADDR_WIDTH-1:0] num_reads,
    output wire                  done,
    output wire [DATA_WIDTH-1:0] checksum
);

    // Internal signals for memory interface
    reg                   mem_rd_en;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Instantiate the SRAM model (REQUIRED!)
    sram_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_sram (
        .clk(clk),
        .rd_en(mem_rd_en),
        .addr(mem_addr),
        .rdata(mem_rdata),
        .rvalid(mem_rvalid)
    );

    // Your control logic here...

endmodule
```

### Hints

- Use a state machine: IDLE -> READING -> DONE
- Keep track of addresses issued vs data received (pipelining)
- XOR checksum: checksum = checksum ^ new_data
- The memory has 1-cycle latency, so you can pipeline requests

## Constraint
- Your design MUST instantiate `sram_model` from tb.sv
- The testbench will fail if the memory is not instantiated or used properly
