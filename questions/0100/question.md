# Argmax Unit

## Problem Statement

Design an Argmax unit that finds the index of the maximum value in an input sequence. Argmax is commonly used in neural network classifiers to determine the predicted class.

### Argmax Operation

```
argmax([v0, v1, v2, ...]) = index of maximum value

Example:
  argmax([0.1, 0.7, 0.2]) = 1  (index of 0.7)
```

### Module Interface
- **Module Name**: `argmax_unit`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new search (pulse)
  - `in_valid`: Input is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_argmax[7:0]`: Index of maximum value
  - `out_max[DATA_WIDTH-1:0]`: Maximum value

### Functional Requirements

1. **Reset/Start**: Initialize tracking variables
2. **Search**: Track max value and its index
3. **Output**: Report index and value of maximum

### Example

```
Classification scores: [10, 50, 30, 20, 40]
Classes:               [ 0,  1,  2,  3,  4]

Processing:
  idx=0, val=10: max=10, argmax=0
  idx=1, val=50: max=50, argmax=1
  idx=2, val=30: max=50, argmax=1
  idx=3, val=20: max=50, argmax=1
  idx=4, val=40: max=50, argmax=1

Output: argmax=1, max=50 (class 1 predicted)
```

### Design Template

```verilog
module argmax_unit #(
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
    output wire [7:0]            out_argmax,
    output wire [DATA_WIDTH-1:0] out_max
);

    // Your implementation here...

endmodule
```

### Hints

- Track current index as inputs arrive
- Update argmax when new maximum found
- Handle ties: keep first occurrence (lower index)

## Constraint
- Correctly implement valid/ready handshake
- First occurrence wins on ties
