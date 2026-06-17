# Mode Finder

## Problem Statement

Design a module that finds the mode (most frequently occurring element) in an input sequence using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `mode_finder`
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
  - `out_mode[DATA_WIDTH-1:0]`: Most frequent value
  - `out_count[7:0]`: Frequency of mode

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum sequence length |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Input Phase**: Store all input values
3. **Count Phase**: Count frequency of each unique value
4. **Find Phase**: Find value with maximum count
5. **Output**: Return mode and its frequency

### Example

```
Input: [1, 3, 2, 3, 4, 3, 2, 3]

Frequencies:
  1: appears 1 time
  2: appears 2 times
  3: appears 4 times
  4: appears 1 time

Output: mode=3, count=4
```

### Design Template

```verilog
module mode_finder #(
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
    output wire [DATA_WIDTH-1:0] out_mode,
    output wire [7:0]            out_count
);

    // Your implementation here...

endmodule
```

### Hints

- Store all values, then count occurrences of each
- Can sort first, then count consecutive equal values
- Track maximum count and corresponding value
- If multiple modes exist, return any one of them

## Constraint
- Correctly implement valid/ready handshake
- Handle single-element sequences
- If tie exists, return any mode
