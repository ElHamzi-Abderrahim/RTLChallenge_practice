# Dot Product Calculator

## Problem Statement

Design a module that computes the dot product of two input vectors using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `dot_product`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new calculation (pulse)
  - `vec_a_valid`: Vector A element is valid
  - `vec_a_data[DATA_WIDTH-1:0]`: Vector A element
  - `vec_a_last`: Last element of vector A
  - `vec_b_valid`: Vector B element is valid
  - `vec_b_data[DATA_WIDTH-1:0]`: Vector B element
  - `vec_b_last`: Last element of vector B
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `vec_a_ready`: Ready to accept vector A element
  - `vec_b_ready`: Ready to accept vector B element
  - `out_valid`: Output result is valid
  - `out_result[DATA_WIDTH*2+7:0]`: Dot product result

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of vector elements |
| `MAX_SIZE` | 8 | Maximum vector length |

### Dot Product Formula

```
dot_product(A, B) = sum(A[i] * B[i]) for i = 0 to n-1

Where A and B are vectors of the same length n.
```

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Input Phase A**: Receive all elements of vector A
3. **Input Phase B**: Receive all elements of vector B
4. **Compute Phase**: Multiply corresponding elements and sum
5. **Output**: Return dot product result

### Example

```
Vector A: [1, 2, 3, 4]
Vector B: [5, 6, 7, 8]

Dot Product = 1*5 + 2*6 + 3*7 + 4*8
            = 5 + 12 + 21 + 32
            = 70
```

### Design Template

```verilog
module dot_product #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 8
)(
    input  wire                             clk,
    input  wire                             rst_n,
    input  wire                             start,
    input  wire                             vec_a_valid,
    input  wire [DATA_WIDTH-1:0]            vec_a_data,
    input  wire                             vec_a_last,
    input  wire                             vec_b_valid,
    input  wire [DATA_WIDTH-1:0]            vec_b_data,
    input  wire                             vec_b_last,
    input  wire                             out_ready,
    output wire                             vec_a_ready,
    output wire                             vec_b_ready,
    output wire                             out_valid,
    output wire [DATA_WIDTH*2+7:0]          out_result
);

    // Your implementation here...

endmodule
```

### Hints

- Store vector A first, then receive vector B
- Multiply-accumulate as vector B arrives
- Output width must handle full precision of n multiplications
- Both vectors must have the same length

## Constraint
- Correctly implement valid/ready handshake
- Vectors must have equal length
- Handle empty vectors (result = 0)
