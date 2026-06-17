# Binary to BCD Converter

## Problem Statement

Design a binary to Binary Coded Decimal (BCD) converter that transforms binary numbers into their BCD representation. BCD encoding represents each decimal digit using 4 bits, making it useful for decimal displays and decimal arithmetic operations.

### Module Interface

**Module Name**: `binary_to_bcd`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Active high synchronous reset |
| `start` | Input | 1 | Start conversion signal |
| `binary_in` | Input | `[BINARY_WIDTH-1:0]` | Binary input value |
| `bcd_out` | Output | `[BCD_WIDTH-1:0]` | BCD output (packed) |
| `valid` | Output | 1 | High when module is idle and output is valid |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `BINARY_WIDTH` | 8 | Width of binary input |
| `BCD_DIGITS` | 3 | Number of BCD digits (for decimal places) |
| `BCD_WIDTH` | 12 | Total BCD width (BCD_DIGITS * 4) |

### Functional Requirements

1. **BCD Encoding**: Each decimal digit encoded in 4 bits (0-9)
2. **Sequential Conversion**: Use shift-and-add-3 algorithm or similar
3. **Range Support**: Handle binary inputs up to 10^BCD_DIGITS - 1
4. **Start Control**: Begin conversion on start signal assertion when valid is high
5. **Valid Signal**: High when module is idle (ready for new conversion, output is valid)
6. **Packed Output**: BCD digits packed into single output vector
7. **Reset Behavior**: Clear outputs and return to idle state

### Example Operation

**Example 1: BINARY_WIDTH = 8, BCD_DIGITS = 3**
- Binary input: 8'b11001000 (200 decimal)
- BCD output: 12'b0010_0000_0000 (2-0-0 in BCD)
- Binary input: 8'b11111111 (255 decimal)
- BCD output: 12'b0010_0101_0101 (2-5-5 in BCD)

**Example 2: BINARY_WIDTH = 6, BCD_DIGITS = 2**
- Binary input: 6'b100011 (35 decimal)
- BCD output: 8'b0011_0101 (3-5 in BCD)
- Binary input: 6'b111111 (63 decimal)
- BCD output: 8'b0110_0011 (6-3 in BCD)

**Example 3: BINARY_WIDTH = 4, BCD_DIGITS = 2**
- Binary input: 4'b1001 (9 decimal)
- BCD output: 8'b0000_1001 (0-9 in BCD)
- Binary input: 4'b1111 (15 decimal)
- BCD output: 8'b0001_0101 (1-5 in BCD)

### BCD Digit Packing

For BCD_DIGITS = 3 (BCD_WIDTH = 12):
- bcd_out[11:8] = hundreds digit
- bcd_out[7:4] = tens digit
- bcd_out[3:0] = ones digit

For BCD_DIGITS = 2 (BCD_WIDTH = 8):
- bcd_out[7:4] = tens digit
- bcd_out[3:0] = ones digit

## Constraints
- Binary input range: 0 to (10^BCD_DIGITS - 1)
- Each BCD digit must be 0-9 (4'b0000 to 4'b1001)
- Conversion should complete within reasonable clock cycles
- Use synchronous design with clock and reset