# Running Sum Calculator

## Problem Statement

Design a running sum calculator that outputs the cumulative sum of input values using valid/ready handshake protocol. Each output is the sum of all inputs received so far.

### Module Interface
- **Module Name**: `running_sum`
- **Parameters**:
  - `DATA_WIDTH` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Reset the accumulator (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `out_ready`: Downstream is ready to accept output
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_sum[DATA_WIDTH-1:0]`: Running sum

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 16 | Bit width of data values |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- Each input produces one output (running sum so far)

### Functional Requirements

1. **Reset**: On reset, sum = 0, ready to accept input
2. **Start**: When `start` asserted, reset sum to 0
3. **Operation**: For each input, output sum of all inputs so far
4. **Overflow**: Allow natural overflow (wrap around)

### Example

```
Input sequence:  [5, 3, 7, 2]
Output sequence: [5, 8, 15, 17]

Explanation:
  Input 5  -> Sum = 0 + 5 = 5
  Input 3  -> Sum = 5 + 3 = 8
  Input 7  -> Sum = 8 + 7 = 15
  Input 2  -> Sum = 15 + 2 = 17
```

### Example Waveform

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
          ─────────────────────────────────────────────
in_ready
          ─────────────────────────────────────────────
in_valid
              ┌───────┬───────┬───────┬───────┐
in_data   ════│   5   │   3   │   7   │   2   │════════
              └───────┴───────┴───────┴───────┘
          ─────────────────────────────────────────────
out_valid
              ┌───────┬───────┬───────┬───────┐
out_sum   ════│   5   │   8   │  15   │  17   │════════
              └───────┴───────┴───────┴───────┘
```

### Hints

- Keep an accumulator register for the running sum
- Output is valid immediately after input is accepted
- Can use combinational logic for in_ready (ready when out_ready or no pending output)
- Consider using a simple state machine or pipeline register

## Constraint
- Correctly implement valid/ready handshake
- Output must be the cumulative sum of all inputs since start/reset
