# Fibonacci Generator

## Problem Statement

Design a Fibonacci sequence generator that outputs Fibonacci numbers one at a time using a valid/ready handshake protocol.

### Module Interface
- **Module Name**: `fib_gen`
- **Parameters**:
  - `DATA_WIDTH` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start generating from F(0)
  - `out_ready`: Downstream is ready to accept data
- **Outputs**:
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH-1:0]`: Current Fibonacci number
  - `out_index[7:0]`: Current index (0, 1, 2, ...)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 16 | Bit width of Fibonacci numbers |

### Valid/Ready Handshake Protocol

- Data transfers when `out_valid && out_ready` on clock edge
- Producer asserts `out_valid` when data is available
- Consumer asserts `out_ready` when it can accept data
- Producer holds data stable while `out_valid` is high
- Transfer occurs only when both signals are high

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: When `start` asserted, begin outputting F(0)=0
3. **Sequence**: Output F(0), F(1), F(2), ... with handshake
4. **Overflow**: Continue outputting (wrap around) when overflow occurs
5. **Continuous**: Keep generating until reset or new start

### Fibonacci Sequence

```
F(0) = 0
F(1) = 1
F(n) = F(n-1) + F(n-2) for n >= 2

Sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...
```

### Example Waveform

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
              ┌───────┐
start     ────┘       └──────────────────────────────────────────
                      ┌──────────────────────────────────────────
out_valid ────────────┘
          ────────────────────────────┐       ┌──────────────────
out_ready                             └───────┘
                      ┌───────┬───────┬───────┐       ┌──────────
out_data  ════════════│   0   │   1   │   1   │═══════│   2
                      └───────┴───────┴───────┘       └──────────
                          ↑               ↑               ↑
                      transfer        transfer        transfer
```

### Design Template

```verilog
module fib_gen #(
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  out_ready,
    output wire                  out_valid,
    output wire [DATA_WIDTH-1:0] out_data,
    output wire [7:0]            out_index
);

    // Your implementation here...

endmodule
```

### Hints

- Keep two registers: fib_prev (F(n-1)) and fib_curr (F(n))
- Update only on successful handshake (valid && ready)
- Handle first two values (0, 1) as special cases
- Use index counter to track position

## Constraint
- Correctly implement valid/ready handshake
- Output must be stable while valid is high
