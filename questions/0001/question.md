# Parameterizable Binary Subtractor

## Problem Statement

Design a parameterizable Verilog subtractor module that performs binary subtraction of two unsigned integers. The module should be configurable to handle different bit-widths through a parameter and properly handle underflow conditions.

### Module Interface
- **Module Name**: `subtractor`
- **Parameter**: `WIDTH` (default: 8 bits)
- **Inputs**:
  - `data_in_1[WIDTH-1:0]`: Minuend (number being subtracted from)
  - `data_in_2[WIDTH-1:0]`: Subtrahend (number being subtracted)
- **Output**:
  - `data_out[WIDTH-1:0]`: Difference result (handle underflow and floor cap at 0)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `INPUT_WIDTH` | 8 | Bit-width of input operands |

### Functional Requirements

1. **Binary Subtraction**: Compute `data_in_1 - data_in_2` for unsigned binary numbers
2. **Underflow Handling**: When `data_in_2 > data_in_1`, the result should be 0 (floor cap)
3. **Parameterizable Width**: Support any width from 1 to 64 bits
4. **Combinational Logic**: Pure combinational implementation (no clock required)

### Example Operation

For WIDTH = 8:
- `data_in_1 = 8'h0A` (10), `data_in_2 = 8'h03` (3) → `data_out = 9'h007` (7)
- `data_in_1 = 8'h03` (3), `data_in_2 = 8'h0A` (10) → `data_out = 9'h000` (underflow: 3-10 = -7 → 0 (floor cap at 0))

For WIDTH = 4:
- `data_in_1 = 4'b1100` (12), `data_in_2 = 4'b0101` (5) → `data_out = 5'b00111` (7)
- `data_in_1 = 4'b0010` (2), `data_in_2 = 4'b0110` (6) → `data_out = 5'b11100` (underflow: 2-6 = -4 → 0 (floor cap at 0))

### Underflow Behavior

When the subtrahend is larger than the minuend:
- The result should be cap at floor 0.

## Constraint
NA