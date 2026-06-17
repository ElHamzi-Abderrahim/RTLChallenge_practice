# Matrix Transpose

## Problem Statement

Design a matrix transpose module that receives an NxN matrix row by row and outputs the transposed matrix row by row using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `matrix_transpose`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MATRIX_SIZE` (default: 4) - N for NxN matrix
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new transpose (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Matrix element (row-major order)
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH-1:0]`: Transposed element (row-major order)
  - `out_last`: Last output element

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MATRIX_SIZE` | 4 | Matrix dimension (NxN) |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Prepare to receive N×N elements
3. **Input Phase**: Receive elements in row-major order
4. **Transpose**: Swap rows and columns
5. **Output Phase**: Output transposed matrix in row-major order

### Matrix Transpose

```
Input (row-major):      Transposed:
[a b c]                 [a d g]
[d e f]  transpose ->   [b e h]
[g h i]                 [c f i]

Input stream:  a, b, c, d, e, f, g, h, i
Output stream: a, d, g, b, e, h, c, f, i
```

### Example (3x3)

```
Input:  [[1, 2, 3],
         [4, 5, 6],
         [7, 8, 9]]

Stream in:  1, 2, 3, 4, 5, 6, 7, 8, 9
Stream out: 1, 4, 7, 2, 5, 8, 3, 6, 9

Output: [[1, 4, 7],
         [2, 5, 8],
         [3, 6, 9]]
```

### Hints

- Store entire matrix in 2D register array
- Input index: row = idx / N, col = idx % N
- Output transposed: read [col][row] instead of [row][col]
- Output count N×N elements total

## Constraint
- Correctly implement valid/ready handshake
- Must transpose correctly for any NxN size
