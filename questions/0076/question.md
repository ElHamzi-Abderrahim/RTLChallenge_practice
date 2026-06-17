# Difference Calculator

## Problem Statement

Design a module that outputs the difference between consecutive input values using valid/ready handshake protocol. This computes the discrete derivative of the input sequence.

### Module Interface
- **Module Name**: `diff_calc`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new sequence (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value (unsigned)
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_diff[DATA_WIDTH:0]`: Signed difference (current - previous)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of input values |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare for new sequence
3. **First Value**: Store as previous, no output
4. **Subsequent**: Output (current - previous), update previous
5. **Signed Output**: diff can be negative

### Example

```
Input:  [5, 8, 3, 10, 7]
Output: [3, -5, 7, -3]

Explanation:
  8 - 5 = 3
  3 - 8 = -5
  10 - 3 = 7
  7 - 10 = -3
```

### Hints

- Keep register for previous value
- Output is signed (one extra bit)
- No output for first input value
- Compute: out_diff = $signed({1'b0, current}) - $signed({1'b0, previous})

## Constraint
- Correctly implement valid/ready handshake
- Output must be signed difference
