# Max Pooling Unit

## Problem Statement

Design a Max Pooling unit used in convolutional neural networks. Max pooling reduces spatial dimensions by outputting the maximum value from each pooling window.

### Max Pooling Operation

```
Input feature map window → Output: max value

Example 2x2 max pooling:
  [1, 3]
  [2, 4] → max = 4
```

### Module Interface
- **Module Name**: `max_pool`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `POOL_SIZE` (default: 4) - Number of elements per window
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new pooling window (pulse)
  - `in_valid`: Input is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value (unsigned)
  - `in_last`: Last element of window
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_max[DATA_WIDTH-1:0]`: Maximum value in window

### Functional Requirements

1. **Reset/Start**: Initialize max to minimum value
2. **Compare**: Track running maximum
3. **Output**: After `in_last`, output the max value

### Example

```
Pool window: [5, 9, 2, 7] (POOL_SIZE=4)

Step 1: start, max = 0
Step 2: compare 5, max = 5
Step 3: compare 9, max = 9
Step 4: compare 2, max = 9
Step 5: compare 7, max = 9 (in_last)

Output: max = 9
```

### Design Template

```verilog
module max_pool #(
    parameter DATA_WIDTH = 8,
    parameter POOL_SIZE = 4
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
    output wire [DATA_WIDTH-1:0] out_max
);

    // Your implementation here...

endmodule
```

### Hints

- Initialize max_reg to 0 (or minimum for signed)
- Compare: if (in_data > max_reg) max_reg <= in_data
- Simple design - streaming max finder

## Constraint
- Correctly implement valid/ready handshake
- Handle variable pool sizes
