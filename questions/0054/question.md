# Lookup Table Interpolator

## Problem Statement

Design a lookup table interpolator that uses a ROM module (defined in `tb.sv`) to perform linear interpolation between table entries. This is commonly used in sine wave generators, function approximation, and signal processing.

**Important**: You MUST instantiate the `rom_model` module (defined in tb.sv) inside your design. The testbench will verify that you use the ROM correctly.

### Module Interface
- **Module Name**: `lut_interpolator`
- **Parameters**:
  - `ADDR_WIDTH` (default: 4) - ROM has 2^ADDR_WIDTH entries
  - `DATA_WIDTH` (default: 8) - Data precision
  - `FRAC_BITS` (default: 4) - Fractional bits for interpolation
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start signal (pulse high for one cycle)
  - `phase[ADDR_WIDTH+FRAC_BITS-1:0]`: Input phase with fractional part
- **Outputs**:
  - `done`: Operation complete signal
  - `result[DATA_WIDTH-1:0]`: Interpolated output value

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ADDR_WIDTH` | 4 | ROM address width (16 entries) |
| `DATA_WIDTH` | 8 | Data bit width |
| `FRAC_BITS` | 4 | Fractional bits for sub-sample precision |

### Provided ROM Model (in tb.sv)

You must instantiate this module inside your design:

```verilog
module rom_model #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] rdata
);
```

**ROM Behavior**:
- Combinational read (0-cycle latency)
- When `rd_en=1`, data appears on `rdata` same cycle
- ROM is pre-initialized with quarter-wave sine values

### Functional Requirements

1. **Instantiate ROM**: Your design MUST instantiate `rom_model` internally
2. **Phase Input**: The input `phase` has:
   - Upper `ADDR_WIDTH` bits: integer part (ROM address)
   - Lower `FRAC_BITS` bits: fractional part (for interpolation)
3. **Linear Interpolation**:
   - Read ROM[addr] and ROM[addr+1] (two consecutive entries)
   - Interpolate: result = ROM[addr] + frac * (ROM[addr+1] - ROM[addr])
   - Handle wrap-around: if addr = MAX, then addr+1 wraps to 0
4. **Timing**: Assert `done` when result is valid

### Example Operation

For ADDR_WIDTH=4, DATA_WIDTH=8, FRAC_BITS=4:
```
ROM contents (example): ROM[0]=0, ROM[1]=25, ROM[2]=50, ...

Input: phase = 8'b0001_1000 (addr=1, frac=8/16=0.5)
  - ROM[1] = 25
  - ROM[2] = 50
  - result = 25 + 0.5 * (50 - 25) = 37 (truncated)

Input: phase = 8'b0000_0100 (addr=0, frac=4/16=0.25)
  - ROM[0] = 0
  - ROM[1] = 25
  - result = 0 + 0.25 * (25 - 0) = 6 (truncated)
```

### Interpolation Formula

```
frac = phase[FRAC_BITS-1:0]
addr = phase[ADDR_WIDTH+FRAC_BITS-1:FRAC_BITS]

y0 = ROM[addr]
y1 = ROM[(addr + 1) % 2^ADDR_WIDTH]

result = y0 + ((y1 - y0) * frac) >> FRAC_BITS
```

### Design Template

```verilog
module lut_interpolator #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter FRAC_BITS  = 4
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire                           start,
    input  wire [ADDR_WIDTH+FRAC_BITS-1:0] phase,
    output wire                           done,
    output wire [DATA_WIDTH-1:0]          result
);

    // Internal signals for ROM interface
    reg                   rom_rd_en;
    reg  [ADDR_WIDTH-1:0] rom_addr;
    wire [DATA_WIDTH-1:0] rom_rdata;

    // Instantiate the ROM model (REQUIRED!)
    rom_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rom (
        .clk(clk),
        .rd_en(rom_rd_en),
        .addr(rom_addr),
        .rdata(rom_rdata)
    );

    // Your control logic here...

endmodule
```

### Hints

- Use a state machine: IDLE -> READ_Y0 -> READ_Y1 -> COMPUTE -> DONE
- For the multiplication, consider using fixed-point arithmetic
- The difference (y1 - y0) can be negative, handle sign extension
- Truncation towards zero is acceptable for this exercise

## Constraint
- Your design MUST instantiate `rom_model` from tb.sv
- The testbench will fail if the ROM is not instantiated or used properly
