# Parameterizable Binary Multiplier

## Problem Statement

Design a parameterizable Verilog multiplier module that performs binary multiplication of two unsigned integers. The module should be configurable to handle different bit-widths through a parameter and produce a full-precision result. This is just a simple multiplier, in ptractical work when you are dealing with larger width, you can use hardware algorithm such as booth multiplier.

### Module Interface
- **Module Name**: `multiplier`
- **Parameter**: `INPUT_WIDTH` (default: 8 bits)
- **Inputs**:
  - `data_in_1[INPUT_WIDTH-1:0]`: First unsigned input operand (multiplicand)
  - `data_in_2[INPUT_WIDTH-1:0]`: Second unsigned input operand (multiplier)
- **Output**:
  - `data_out[2*INPUT_WIDTH-1:0]`: Product result (full precision, 2×INPUT_WIDTH bits)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `INPUT_WIDTH` | 8 | Bit-width of input operands |

### Functional Requirements

1. **Binary Multiplication**: Compute `data_in_1 × data_in_2` for unsigned binary numbers
2. **Full Precision Output**: Result width is 2×INPUT_WIDTH bits to accommodate maximum product
3. **Parameterizable Width**: Support any width from 1 to 32 bits
4. **Combinational Logic**: Pure combinational implementation (no clock required)
5. **Overflow Prevention**: Full-width output prevents any information loss

### Example Operation

For INPUT_WIDTH = 8:
- `data_in_1 = 8'h0F` (15), `data_in_2 = 8'h0A` (10) → `data_out = 16'h0096` (150)
- `data_in_1 = 8'hFF` (255), `data_in_2 = 8'hFF` (255) → `data_out = 16'hFE01` (65025)

For INPUT_WIDTH = 4:
- `data_in_1 = 4'b1010` (10), `data_in_2 = 4'b0011` (3) → `data_out = 8'b00011110` (30)
- `data_in_1 = 4'b1111` (15), `data_in_2 = 4'b1111` (15) → `data_out = 8'b11100001` (225)

### Multiplication Behavior

The unsigned binary multiplication follows these principles:
- Maximum possible product = (2^INPUT_WIDTH - 1) × (2^INPUT_WIDTH - 1) = 2^(2×INPUT_WIDTH) - 2^(INPUT_WIDTH+1) + 1
- Result never exceeds 2×INPUT_WIDTH bits
- All intermediate calculations are handled automatically by Verilog
- No overflow concerns since output width accommodates maximum product

## Implementation Notes

- Use the built-in `*` operator for multiplication
- The output width is exactly 2×INPUT_WIDTH bits
- Ensure proper handling of different INPUT_WIDTH values
- All arithmetic is unsigned multiplication
- No need for special overflow handling due to full-precision output

## Testing

Your implementation will be tested with:
- Small operand multiplication (both operands < 2^(INPUT_WIDTH/2))
- Large operand multiplication (operands near maximum values)
- Various INPUT_WIDTH values (2-bit to 16-bit)
- Edge cases including zero operands and maximum values
- Corner cases like 1×N and powers of 2

## Constraint
Just use * operator