# Duplicate Detector

## Problem Statement

Design a module that checks if an input sequence contains any duplicate values using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `dup_detect`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new check (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_has_dup`: 1 if duplicates exist, 0 otherwise

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum sequence length |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare to receive sequence
3. **Input Phase**: Store all input values
4. **Check Phase**: Check if any two elements are equal
5. **Output**: Report if duplicates were found

### Example

```
Input: [1, 2, 3, 2, 5]
Output: has_dup = 1 (because 2 appears twice)

Input: [1, 2, 3, 4, 5]
Output: has_dup = 0 (all unique)
```

### Hints

- Store all values in a buffer
- Compare each pair of elements (i, j) where i < j
- Can also check during input: compare new value with all stored values
- Stop early if duplicate found

## Constraint
- Correctly implement valid/ready handshake
- Must detect any duplicate pair
