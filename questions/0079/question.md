# Binary Search

## Problem Statement

Design a binary search module that searches for a target value in a sorted array using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `binary_search`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new search (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Sorted array element
  - `in_last`: Last input value
  - `target[DATA_WIDTH-1:0]`: Value to search for
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_found`: 1 if target found, 0 otherwise
  - `out_index[7:0]`: Index where target was found (if found)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum array size |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Capture target, prepare to receive sorted array
3. **Input Phase**: Store sorted array elements
4. **Search Phase**: Perform binary search for target
5. **Output**: Report if found and at which index

### Binary Search Algorithm

```
binary_search(arr, target):
  left = 0
  right = n - 1

  while left <= right:
    mid = (left + right) / 2
    if arr[mid] == target:
      return (true, mid)
    elif arr[mid] < target:
      left = mid + 1
    else:
      right = mid - 1

  return (false, 0)
```

### Example

```
Sorted Array: [2, 5, 8, 12, 16, 23, 38, 56]
Target: 23

Step 1: mid=3, arr[3]=12 < 23, left=4
Step 2: mid=5, arr[5]=23 == 23, Found!

Output: found=1, index=5
```

### Hints

- First load the entire sorted array
- Track left and right boundaries
- Compute mid = (left + right) >> 1
- O(log n) comparisons needed

## Constraint
- Correctly implement valid/ready handshake
- Input array must be sorted (ascending)
