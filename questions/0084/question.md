# Longest Consecutive Sequence

## Problem Statement

Design a module that finds the length of the longest consecutive elements sequence in an unsorted array using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `longest_consec`
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
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_length[7:0]`: Length of longest consecutive sequence

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum array size |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Input Phase**: Store all input values
3. **Sort Phase**: Sort the values
4. **Scan Phase**: Find longest run of consecutive values
5. **Output**: Report length of longest consecutive sequence

### Algorithm

```
1. Sort the array
2. Initialize: current_len = 1, max_len = 1
3. For i = 1 to n-1:
     if arr[i] == arr[i-1]:
       continue  // Skip duplicates
     elif arr[i] == arr[i-1] + 1:
       current_len++
     else:
       max_len = max(max_len, current_len)
       current_len = 1
4. Return max(max_len, current_len)
```

### Example

```
Input: [100, 4, 200, 1, 3, 2]
Sorted: [1, 2, 3, 4, 100, 200]

Scan:
  1 -> 2: consecutive, len=2
  2 -> 3: consecutive, len=3
  3 -> 4: consecutive, len=4
  4 -> 100: break, max=4, len=1
  100 -> 200: break, max=4, len=1

Output: length = 4 (sequence: 1,2,3,4)
```

### Design Template

```verilog
module longest_consec #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire                  out_ready,
    output wire                  in_ready,
    output wire                  out_valid,
    output wire [7:0]            out_length
);

    // Your implementation here...

endmodule
```

### Hints

- Reuse sorting logic from bubble sort (0064)
- After sorting, linear scan finds consecutive runs
- Handle duplicates - don't count as extending sequence
- Track both current run length and maximum found

## Constraint
- Correctly implement valid/ready handshake
- Handle duplicates correctly (skip, don't break sequence)
- Empty input should return 0
