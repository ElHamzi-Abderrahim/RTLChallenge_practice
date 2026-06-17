# Median Calculator

## Problem Statement

Design a module that calculates the median of an input sequence using valid/ready handshake protocol. The median is the middle value when the sequence is sorted.

### Module Interface
- **Module Name**: `median_calc`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 9) - Must be odd for simplicity
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new calculation (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_median[DATA_WIDTH-1:0]`: Median value

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 9 | Maximum sequence length |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare to receive sequence
3. **Input Phase**: Store all input values
4. **Sort Phase**: Sort the values (can reuse bubble sort)
5. **Output**: Return middle element (arr[n/2])

### Example

```
Input: [3, 1, 4, 1, 5, 9, 2]
Sorted: [1, 1, 2, 3, 4, 5, 9]
Median: arr[3] = 3 (middle of 7 elements)

Input: [5, 2, 8]
Sorted: [2, 5, 8]
Median: arr[1] = 5 (middle of 3 elements)
```

### Hints

- Store all values, then sort using bubble sort
- Median is at index n/2 (integer division)
- For even count, can return arr[n/2] or arr[(n-1)/2]
- Consider partial sorting - only need to find middle element

## Constraint
- Correctly implement valid/ready handshake
- Handle variable input sizes up to MAX_SIZE
