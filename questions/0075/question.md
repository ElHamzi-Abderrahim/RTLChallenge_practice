# Run Length Encoder

## Problem Statement

Design a Run Length Encoder (RLE) that compresses consecutive identical values into (value, count) pairs using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `rle_encoder`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new encoding (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_value[DATA_WIDTH-1:0]`: Run value
  - `out_count[7:0]`: Run length
  - `out_last`: Last output pair

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare for new sequence
3. **Encoding**: Group consecutive identical values
4. **Output**: Emit (value, count) for each run

### Example

```
Input:  [A, A, A, B, B, C, C, C, C]
Output: (A, 3), (B, 2), (C, 4)

Input:  [1, 1, 2, 2, 2, 1, 1]
Output: (1, 2), (2, 3), (1, 2)
```

### Hints

- Track current run value and count
- When value changes or input ends, output the run
- Handle count overflow (max 255)
- out_last should only be set on the final output pair

## Constraint
- Correctly implement valid/ready handshake
- Output all runs correctly
