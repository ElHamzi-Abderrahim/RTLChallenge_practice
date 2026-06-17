# GCD Calculator

## Problem Statement

Design a Greatest Common Divisor (GCD) calculator that computes the GCD of two numbers using the Euclidean algorithm with a valid/ready handshake protocol.

### Module Interface
- **Module Name**: `gcd_calc`
- **Parameters**:
  - `DATA_WIDTH` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input data is valid
  - `in_a[DATA_WIDTH-1:0]`: First operand
  - `in_b[DATA_WIDTH-1:0]`: Second operand
  - `out_ready`: Downstream is ready to accept result
- **Outputs**:
  - `in_ready`: Ready to accept new input
  - `out_valid`: Output result is valid
  - `out_gcd[DATA_WIDTH-1:0]`: GCD result

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 16 | Bit width of operands |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- Data must be stable while valid is high

### Functional Requirements

1. **Reset**: On reset, go to idle state, ready to accept input
2. **Input**: Accept two operands when handshake occurs
3. **Compute**: Calculate GCD using Euclidean algorithm
4. **Output**: Present result with valid signal
5. **Edge Cases**:
   - GCD(0, b) = b
   - GCD(a, 0) = a
   - GCD(0, 0) = 0

### Euclidean Algorithm

```
GCD(a, b):
  while b != 0:
    temp = b
    b = a mod b
    a = temp
  return a

Examples:
  GCD(48, 18) = 6
  GCD(252, 105) = 21
  GCD(100, 25) = 25
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
in_a      ════│  48   │══════════════════════════════════════════
              └───────┘
              ┌───────┐
in_b      ════│  18   │══════════════════════════════════════════
              └───────┘
                                              ┌───────┐
out_valid ────────────────────────────────────┘       └──────────
          ────────────────────────────────────────────┐   ┌──────
out_ready                                             └───┘
                                              ┌───────┐
out_gcd   ════════════════════════════════════│   6   │══════════
                                              └───────┘
```

### Hints

- Use a state machine: IDLE -> COMPUTE -> DONE
- In COMPUTE state, repeatedly apply: (a, b) <- (b, a mod b)
- Modulo can be computed with subtraction in hardware
- For faster implementation, use actual modulo operator
- Handle the case where one input is zero

## Constraint
- Correctly implement valid/ready handshake on both input and output
- Must handle edge cases with zeros
