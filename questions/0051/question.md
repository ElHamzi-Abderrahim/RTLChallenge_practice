# Gray to Binary Converter

## Problem Statement

Design a parameterizable combinational module that converts a Gray code input to its equivalent binary representation. Gray code is a binary numeral system where two successive values differ in only one bit, making it useful for error reduction in digital communications and rotary encoders.

### Module Interface
- **Module Name**: `gray_to_binary`
- **Parameter**: `WIDTH` (default: 4 bits)
- **Inputs**:
  - `gray_in[WIDTH-1:0]`: Gray code input
- **Output**:
  - `binary_out[WIDTH-1:0]`: Binary equivalent output

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `WIDTH` | 4 | Bit-width of input and output |

### Functional Requirements

1. **Gray to Binary Conversion**: Convert Gray code to standard binary representation
2. **Parameterizable Width**: Support any width from 1 to 32 bits
3. **Combinational Logic**: Pure combinational implementation (no clock required)

### Conversion Algorithm

The conversion from Gray code to binary follows this rule:
- `binary[MSB] = gray[MSB]` (MSB is the same)
- `binary[i] = binary[i+1] XOR gray[i]` for all other bits (from MSB-1 down to 0)

Alternatively: `binary[i] = XOR of all gray bits from position i to MSB`

### Example Operation

For WIDTH = 4:
| Gray Code | Binary |
|-----------|--------|
| 4'b0000   | 4'b0000 (0) |
| 4'b0001   | 4'b0001 (1) |
| 4'b0011   | 4'b0010 (2) |
| 4'b0010   | 4'b0011 (3) |
| 4'b0110   | 4'b0100 (4) |
| 4'b0111   | 4'b0101 (5) |
| 4'b0101   | 4'b0110 (6) |
| 4'b0100   | 4'b0111 (7) |
| 4'b1100   | 4'b1000 (8) |
| 4'b1101   | 4'b1001 (9) |
| 4'b1111   | 4'b1010 (10) |
| 4'b1110   | 4'b1011 (11) |
| 4'b1010   | 4'b1100 (12) |
| 4'b1011   | 4'b1101 (13) |
| 4'b1001   | 4'b1110 (14) |
| 4'b1000   | 4'b1111 (15) |

### Hints

- This is the inverse operation of Binary to Gray conversion (question 0015)
- The XOR cascade can be implemented with a generate block or a simple loop
- Each output bit depends on all input bits from that position to the MSB

## Constraint
NA
