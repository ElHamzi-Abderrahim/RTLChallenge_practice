# Factorial Calculator

## Problem Statement

Design a factorial calculator that computes N! (N factorial) using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `factorial`
- **Parameters**:
  - `DATA_WIDTH` (default: 32)
  - `INPUT_WIDTH` (default: 5) - Width of input N
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input data is valid
  - `in_n[INPUT_WIDTH-1:0]`: Input value N
  - `out_ready`: Downstream is ready to accept result
- **Outputs**:
  - `in_ready`: Ready to accept new input
  - `out_valid`: Output result is valid
  - `out_factorial[DATA_WIDTH-1:0]`: Result N!

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 32 | Bit width of result |
| `INPUT_WIDTH` | 5 | Bit width of input (max N = 2^5-1 = 31) |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge

### Functional Requirements

1. **Reset**: On reset, go to idle state, ready to accept input
2. **Input**: Accept N when handshake occurs
3. **Compute**: Calculate N! = N × (N-1) × ... × 2 × 1
4. **Output**: Present result with valid signal
5. **Edge Cases**:
   - 0! = 1
   - 1! = 1

### Factorial Definition

```
N! = N × (N-1) × (N-2) × ... × 2 × 1

Special cases:
  0! = 1
  1! = 1

Examples:
  5! = 5 × 4 × 3 × 2 × 1 = 120
  6! = 720
  10! = 3,628,800
  12! = 479,001,600
```

### Example Waveform

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
              ┌───────┐
in_valid  ────┘       └──────────────────────────────────────────
              ┌───────┐
in_ready  ────┘       └──────────────────────────────────────────
              ┌───────┐
in_n      ════│   5   │══════════════════════════════════════════
              └───────┘
                                              ┌───────┐
out_valid ────────────────────────────────────┘       └──────────
          ────────────────────────────────────────────┐   ┌──────
out_ready                                             └───┘
                                              ┌───────┐
out_factorial ════════════════════════════════│  120  │══════════
                                              └───────┘
```

### Hints

- Use a state machine: IDLE -> COMPUTE -> DONE
- Keep an accumulator (starts at 1) and counter (starts at N)
- Each cycle: accumulator = accumulator × counter; counter = counter - 1
- Stop when counter reaches 0 or 1
- Handle 0! and 1! as special cases

## Constraint
- Correctly implement valid/ready handshake on both input and output
- Results may overflow for large N (that's acceptable)
