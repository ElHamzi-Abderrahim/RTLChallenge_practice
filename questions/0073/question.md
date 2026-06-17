# Min-Max Finder

## Problem Statement

Design a module that finds both the minimum and maximum values in an input sequence using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `min_max`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new search (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_min[DATA_WIDTH-1:0]`: Minimum value found
  - `out_max[DATA_WIDTH-1:0]`: Maximum value found

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare to receive sequence
3. **Input Phase**: Track min and max as values arrive
4. **Output**: Report minimum and maximum values

### Example

```
Input: [5, 2, 8, 1, 9, 3]
Output: min = 1, max = 9
```

### Hints

- Track running min and max during input
- Initialize min to maximum possible value (all 1s)
- Initialize max to minimum possible value (all 0s)
- Update on each input: if (in_data < min) min = in_data
- No need to store the entire sequence

## Constraint
- Correctly implement valid/ready handshake
- Must handle single element correctly
