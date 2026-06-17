# Peak Detector

## Problem Statement

Design a module that detects local peaks (local maxima) in an input sequence using valid/ready handshake protocol. A peak is a value greater than both its neighbors.

### Module Interface
- **Module Name**: `peak_detect`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new sequence (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_is_peak`: 1 if middle value is a peak
  - `out_value[DATA_WIDTH-1:0]`: The value (peak or not)
  - `out_index[7:0]`: Index in original sequence

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare for new sequence
3. **Peak Detection**: Value at index i is peak if arr[i-1] < arr[i] > arr[i+1]
4. **Edges**: First and last values cannot be peaks
5. **Output**: For each value (except first/last), output peak status

### Example

```
Input:  [1, 5, 2, 8, 3, 7, 4]
Index:   0  1  2  3  4  5  6

Peaks:   5 (index 1): 1 < 5 > 2 ✓
         8 (index 3): 2 < 8 > 3 ✓
         7 (index 5): 3 < 7 > 4 ✓

Output: (5, 1, peak), (2, 2, not), (8, 3, peak), (3, 4, not), (7, 5, peak)
```

### Hints

- Need to buffer 3 values: prev, curr, next
- Output for middle value when next value arrives
- Handle sequence end specially (last value triggers output for previous)
- First and last elements are not outputted as peaks

## Constraint
- Correctly implement valid/ready handshake
- Correctly identify all local maxima
