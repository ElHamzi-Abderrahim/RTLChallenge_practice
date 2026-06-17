# Thermometer to Binary Decoder

## Problem Statement

Design a thermometer-to-binary decoder that converts thermometer code into standard binary representation. Thermometer code is used in ADCs, DACs, and high-speed digital systems where only one bit changes at a time, providing better noise immunity.

### Module Interface

**Module Name**: `thermometer_to_binary`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `thermo_in` | Input | `[THERMO_WIDTH-1:0]` | Thermometer code input |
| `binary_out` | Output | `[BINARY_WIDTH-1:0]` | Binary code output |
| `valid` | Output | 1 | Valid thermometer code indicator |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `THERMO_WIDTH` | 7 | Width of thermometer input (2^BINARY_WIDTH - 1) |
| `BINARY_WIDTH` | 3 | Width of binary output |

### Functional Requirements

1. **Thermometer Code**: Input has consecutive 1s from LSB (e.g., 0001111 for value 4)
2. **Binary Conversion**: Convert to standard binary representation
3. **Valid Detection**: Check for proper thermometer code format
4. **Zero Handling**: All zeros input produces zero output
5. **Error Detection**: Invalid thermometer patterns set valid=0
6. **Priority Logic**: Use priority encoder for efficient implementation

### Thermometer Code Definition

Valid thermometer codes have the pattern: `00...0011...11`
- All 1s are consecutive from the LSB
- All 0s are consecutive from the MSB
- No isolated 1s or 0s in the middle

### Example Operation

For THERMO_WIDTH = 7, BINARY_WIDTH = 3:
- thermo_in: 7'b0000000 → binary_out: 3'b000 (0), valid: 1
- thermo_in: 7'b0000001 → binary_out: 3'b001 (1), valid: 1
- thermo_in: 7'b0000011 → binary_out: 3'b010 (2), valid: 1
- thermo_in: 7'b0000111 → binary_out: 3'b011 (3), valid: 1
- thermo_in: 7'b0001111 → binary_out: 3'b100 (4), valid: 1
- thermo_in: 7'b1111111 → binary_out: 3'b111 (7), valid: 1
- thermo_in: 7'b0001011 → binary_out: 3'bxxx, valid: 0 (invalid pattern)

### Conversion Algorithm

The binary output equals the number of 1s in the thermometer input:
- Count the number of consecutive 1s from LSB
- This count is the binary equivalent
- Validate that the pattern is proper thermometer code

## Constraints
- THERMO_WIDTH = 2^BINARY_WIDTH - 1 (for full range)
- Valid thermometer codes only
- Combinational implementation
- Handle edge cases (all 0s, all 1s)