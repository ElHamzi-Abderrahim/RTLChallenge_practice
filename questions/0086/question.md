# Hamming Distance Calculator

## Problem Statement

Design a module that computes the Hamming distance between pairs of input values using valid/ready handshake protocol. The Hamming distance is the number of positions at which the corresponding bits differ.

### Module Interface
- **Module Name**: `hamming_dist`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input pair is valid
  - `in_a[DATA_WIDTH-1:0]`: First value
  - `in_b[DATA_WIDTH-1:0]`: Second value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_dist[$clog2(DATA_WIDTH+1)-1:0]`: Hamming distance

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of input values |

### Hamming Distance

```
hamming_distance(a, b) = popcount(a XOR b)

Where popcount counts the number of 1s in a binary number.
```

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Input**: Accept two values simultaneously
3. **Compute**: XOR values, count resulting 1s
4. **Output**: Return Hamming distance

### Example

```
Input A: 0b10101010 (170)
Input B: 0b01010101 (85)

XOR:     0b11111111 (255)

Hamming Distance = 8 (all bits differ)

Another example:
Input A: 0b11001100 (204)
Input B: 0b11000011 (195)

XOR:     0b00001111 (15)

Hamming Distance = 4
```

### Design Template

```verilog
module hamming_dist #(
    parameter DATA_WIDTH = 8
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire                           in_valid,
    input  wire [DATA_WIDTH-1:0]          in_a,
    input  wire [DATA_WIDTH-1:0]          in_b,
    input  wire                           out_ready,
    output wire                           in_ready,
    output wire                           out_valid,
    output wire [$clog2(DATA_WIDTH+1)-1:0] out_dist
);

    // Your implementation here...

endmodule
```

### Hints

- XOR the two inputs to find differing bits
- Count the 1s in the XOR result (population count)
- Can use iterative counting or combinational popcount
- Maximum distance equals DATA_WIDTH

## Constraint
- Correctly implement valid/ready handshake
- Output must be in range [0, DATA_WIDTH]
