# Insertion Sort Engine

## Problem Statement

Design a module that sorts an input sequence using the insertion sort algorithm with valid/ready handshake protocol.

### Module Interface
- **Module Name**: `insertion_sort`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new sort (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH-1:0]`: Sorted output value
  - `out_last`: Last output value indicator

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 8 | Maximum array size |

### Insertion Sort Algorithm

```
for i = 1 to n-1:
    key = arr[i]
    j = i - 1

    while j >= 0 and arr[j] > key:
        arr[j + 1] = arr[j]
        j = j - 1

    arr[j + 1] = key
```

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Input Phase**: Store all input values
3. **Sort Phase**: Apply insertion sort algorithm
4. **Output Phase**: Stream sorted values

### Example

```
Input: [5, 2, 8, 1, 9]

Insertion sort steps:
  i=1: key=2, shift 5 right, insert 2 -> [2, 5, 8, 1, 9]
  i=2: key=8, no shift needed          -> [2, 5, 8, 1, 9]
  i=3: key=1, shift 8,5,2 right, insert -> [1, 2, 5, 8, 9]
  i=4: key=9, no shift needed          -> [1, 2, 5, 8, 9]

Output: [1, 2, 5, 8, 9]
```

### Design Template

```verilog
module insertion_sort #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
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
    output wire [DATA_WIDTH-1:0] out_data,
    output wire                  out_last
);

    // Your implementation here...

endmodule
```

### Hints

- Store all values first
- For each element (i=1 to n-1), find correct position
- Shift elements right to make room
- Insert the key at correct position
- Different from bubble sort: builds sorted portion from left

## Constraint
- Correctly implement valid/ready handshake
- Output must be sorted in ascending order
