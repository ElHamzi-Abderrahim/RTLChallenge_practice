# Counter Manager

## Problem Statement

Design a counter manager that maintains multiple independent counters stored in SRAM. Each counter can be incremented, read, or written to based on user commands.

**Important**: You MUST instantiate the `sram_rw_model` module (defined in tb.sv) inside your design to store the counter values.

### Module Interface
- **Module Name**: `counter_manager`
- **Parameters**:
  - `ADDR_WIDTH` (default: 4) - Number of counters = 2^ADDR_WIDTH
  - `DATA_WIDTH` (default: 8) - Counter bit width
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `cmd_valid`: Command valid signal
  - `cmd_op[1:0]`: Operation code (00=NOP, 01=INCREMENT, 10=READ, 11=WRITE)
  - `cmd_addr[ADDR_WIDTH-1:0]`: Target counter address
  - `cmd_wdata[DATA_WIDTH-1:0]`: Write data (for WRITE operation)
- **Outputs**:
  - `cmd_ready`: Ready to accept new command
  - `resp_valid`: Response valid
  - `resp_data[DATA_WIDTH-1:0]`: Read data response

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ADDR_WIDTH` | 4 | Address width (16 counters) |
| `DATA_WIDTH` | 8 | Counter bit width |

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

### Operations

| cmd_op | Operation | Description |
|--------|-----------|-------------|
| 2'b00  | NOP       | No operation |
| 2'b01  | INCREMENT | Read counter[addr], add 1, write back |
| 2'b10  | READ      | Read counter[addr], output on resp_data |
| 2'b11  | WRITE     | Write cmd_wdata to counter[addr] |

### Timing

- INCREMENT requires read-modify-write (multiple cycles)
- READ requires memory read (2 cycles with 1-cycle latency)
- WRITE completes in 1 cycle
- Assert `cmd_ready` when ready for new command
- Assert `resp_valid` when read data is available

### Example Operation

```
Cycle 1: cmd_valid=1, cmd_op=WRITE, cmd_addr=3, cmd_wdata=10
Cycle 2: cmd_ready=1 (write complete)
Cycle 3: cmd_valid=1, cmd_op=INCREMENT, cmd_addr=3
Cycle 5: cmd_ready=1 (increment complete, counter[3]=11)
Cycle 6: cmd_valid=1, cmd_op=READ, cmd_addr=3
Cycle 8: resp_valid=1, resp_data=11
```

### Design Template

```verilog
module counter_manager #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  cmd_valid,
    input  wire [1:0]            cmd_op,
    input  wire [ADDR_WIDTH-1:0] cmd_addr,
    input  wire [DATA_WIDTH-1:0] cmd_wdata,
    output wire                  cmd_ready,
    output wire                  resp_valid,
    output wire [DATA_WIDTH-1:0] resp_data
);

    // Memory interface signals
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Instantiate SRAM model (REQUIRED!)
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

    // Your state machine here...

endmodule
```

### Hints

- Use a state machine: IDLE -> READ -> (for INCREMENT: WRITE_BACK) -> DONE
- For INCREMENT: read current value, add 1, write back
- Latch the command parameters when cmd_valid is asserted
- Handle back-to-back commands properly

## Constraint
- Your design MUST instantiate `sram_rw_model` from tb.sv
- All counters start at 0 (memory initialized to 0)
