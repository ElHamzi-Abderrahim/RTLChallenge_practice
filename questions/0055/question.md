# Memory Arbiter

## Problem Statement

Design a memory arbiter that handles requests from multiple masters (requestors) to a shared SRAM. The arbiter must use fixed priority arbitration and properly generate memory interface timing.

**Important**: You MUST instantiate the `sram_rw_model` module (defined in tb.sv) inside your design. The testbench will verify that you use the memory correctly.

### Module Interface
- **Module Name**: `mem_arbiter`
- **Parameters**:
  - `NUM_MASTERS` (default: 4) - Number of requesting masters
  - `ADDR_WIDTH` (default: 8)
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - **Per-master request interface**:
    - `req[NUM_MASTERS-1:0]`: Request signals from each master
    - `req_wr[NUM_MASTERS-1:0]`: Write enable (1=write, 0=read) per master
    - `req_addr[NUM_MASTERS*ADDR_WIDTH-1:0]`: Packed addresses from all masters
    - `req_wdata[NUM_MASTERS*DATA_WIDTH-1:0]`: Packed write data from all masters
- **Outputs**:
  - **Per-master grant interface**:
    - `gnt[NUM_MASTERS-1:0]`: Grant signals (one-hot, indicates which master won)
    - `gnt_rdata[NUM_MASTERS*DATA_WIDTH-1:0]`: Read data returned to each master
    - `gnt_rvalid[NUM_MASTERS-1:0]`: Read data valid per master

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `NUM_MASTERS` | 4 | Number of masters |
| `ADDR_WIDTH` | 8 | Address width |
| `DATA_WIDTH` | 8 | Data width |

### Provided Memory Model (in tb.sv)

You must instantiate this module inside your design:

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

**Memory Behavior**:
- Write: `req=1, wr=1, addr=A, wdata=D` -> immediate write
- Read: `req=1, wr=0, addr=A` -> next cycle: `rvalid=1, rdata=D`
- 1-cycle read latency

### Functional Requirements

1. **Instantiate Memory**: Your design MUST instantiate `sram_rw_model` internally
2. **Fixed Priority Arbitration**:
   - Master 0 has highest priority, Master NUM_MASTERS-1 has lowest
   - When multiple masters request, serve the highest priority one first
3. **Grant Behavior**:
   - Assert `gnt[i]` when master i's request is being served
   - For writes: grant on same cycle as write completes
   - For reads: also assert `gnt_rvalid[i]=1` when data returns
4. **Request Handling**:
   - Masters hold `req` high until they see their `gnt`
   - Once granted, master deasserts `req` on next cycle

### Address/Data Packing Convention

For packed signals:
```
req_addr = {master[N-1]_addr, ..., master[1]_addr, master[0]_addr}
```
To extract master i's address: `req_addr[i*ADDR_WIDTH +: ADDR_WIDTH]`

### Design Template

```verilog
module mem_arbiter #(
    parameter NUM_MASTERS = 4,
    parameter ADDR_WIDTH  = 8,
    parameter DATA_WIDTH  = 8
)(
    input  wire                              clk,
    input  wire                              rst_n,
    input  wire [NUM_MASTERS-1:0]            req,
    input  wire [NUM_MASTERS-1:0]            req_wr,
    input  wire [NUM_MASTERS*ADDR_WIDTH-1:0] req_addr,
    input  wire [NUM_MASTERS*DATA_WIDTH-1:0] req_wdata,
    output wire [NUM_MASTERS-1:0]            gnt,
    output wire [NUM_MASTERS*DATA_WIDTH-1:0] gnt_rdata,
    output wire [NUM_MASTERS-1:0]            gnt_rvalid
);

    // Internal signals for memory interface
    reg                   mem_req;
    reg                   mem_wr;
    reg  [ADDR_WIDTH-1:0] mem_addr;
    reg  [DATA_WIDTH-1:0] mem_wdata;
    wire [DATA_WIDTH-1:0] mem_rdata;
    wire                  mem_rvalid;

    // Instantiate the SRAM model (REQUIRED!)
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

    // Your arbitration logic here...

endmodule
```

### Example Operation

With NUM_MASTERS=4:
- Masters 0, 1, 2 all request simultaneously
- Arbiter grants master 0 first (highest priority)
- After master 0 completes, grants master 1
- After master 1 completes, grants master 2

### Hints

- Use a priority encoder to select the highest priority requester
- Track which master initiated a read to route the response correctly
- Writes complete in one cycle; reads take two cycles (request + response)
- Be careful with the read response routing

## Constraint
- Your design MUST instantiate `sram_rw_model` from tb.sv
- All requests must eventually be served (no starvation for single requests)
- The testbench will verify proper arbitration and memory access
