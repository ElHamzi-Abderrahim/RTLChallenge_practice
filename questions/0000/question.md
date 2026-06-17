# Parameterizable Binary Adder

## Problem Statement

Design a parameterizable Verilog adder module that performs binary addition of two unsigned integers. The module should be configurable to handle different bit-widths through a parameter.

### Module Interface

**Module Name**: `adder`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `data_in_1` | Input | `[INPUT_WIDTH-1:0]` | First unsigned input operand |
| `data_in_2` | Input | `[INPUT_WIDTH-1:0]` | Second unsigned input operand |
| `data_out` | Output | `[INPUT_WIDTH:0]` | Sum result (WIDTH+1 bits to accommodate carry-out) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `INPUT_WIDTH` | 8 | Bit-width of input operands |

### Functional Requirements

1. **Binary Addition**: Compute the sum of two unsigned binary numbers
2. **Overflow Detection**: The output width is WIDTH+1 bits to capture any carry-out/overflow
3. **Parameterizable Width**: Support any width from 1 to 64 bits
4. **Combinational Logic**: Pure combinational implementation (no clock required)

### Example Operation

For WIDTH = 8:
- `data_in_1 = 8'hFF` (255)
- `data_in_2 = 8'h01` (1)
- `data_out = 9'h100` (256)

For WIDTH = 4:
- `data_in_1 = 4'b1010` (10)
- `data_in_2 = 4'b0011` (3)
- `data_out = 5'b01101` (13)

## Constraints
NA