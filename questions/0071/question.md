# Two Sum Finder

## Problem Statement

Design a module that finds two numbers in an input sequence that sum to a target value, using valid/ready handshake protocol. This is the classic "Two Sum" problem.

### Module Interface
- **Module Name**: `two_sum`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new search (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `target[DATA_WIDTH-1:0]`: Target sum value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_found`: 1 if pair found, 0 otherwise
  - `out_idx1[7:0]`: Index of first number
  - `out_idx2[7:0]`: Index of second number

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum sequence length |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Accept target value and prepare to receive sequence
3. **Input Phase**: Store all input values
4. **Search Phase**: Find two indices i, j where arr[i] + arr[j] = target
5. **Output**: Report if found and the indices (i < j)

### Example

```
Target: 9
Input:  [2, 7, 11, 15]

Search: 2 + 7 = 9 ✓

Output: found=1, idx1=0, idx2=1
```

### Hints

- Store all values in a buffer during input phase
- Use nested loops to check all pairs (i, j) where i < j
- Return first pair found or not found after checking all
- O(n²) brute force is acceptable for hardware

## Constraint
- Correctly implement valid/ready handshake
- Report first valid pair with idx1 < idx2
