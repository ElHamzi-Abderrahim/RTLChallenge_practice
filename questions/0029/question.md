# 4-Bit Universal Shift Register

## Problem Statement

Universal shift registers are versatile digital components that can perform multiple operations including parallel load, shift left, shift right, and hold operations. These registers are commonly used in applications such as data serialization/deserialization, arithmetic operations, and data routing in digital systems.

Design a 4-bit universal shift register that supports parallel loading, bidirectional shifting, and enable control. The register should support synchronous reset and operate based on control signals to determine the specific operation to perform.

### Module Interface

**Module Name**: `Universal_Shift_Register`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock input |
| `reset` | Input | 1 | Reset input (active high) |
| `load` | Input | 1 | Parallel load control |
| `shift_left` | Input | 1 | Shift left control |
| `shift_right` | Input | 1 | Shift right control |
| `serial_in` | Input | 1 | Serial input data |
| `enable` | Input | 1 | Enable control |
| `q` | Output | 4 | 4-bit register output |

### Functional Requirements

1. **Reset Operation**: When reset=1, register resets to all zeros
2. **Parallel Load**: When load=1, load serial_in into the register (highest priority)
3. **Shift Left**: When enable=1 and shift_left=1, shift data left (circular)
4. **Shift Right**: When enable=1 and shift_right=1, shift data right (circular)
5. **Enable Control**: Operations only occur when enable=1 (except reset and load)
6. **Priority**: reset > load > shift operations

### Example Operation

**Parallel Load Operation:**
```
Clock:     ___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:     ___________________________
load:      ___________/‾‾‾‾‾‾‾\_______
serial_in:  X ><     1101     ><  X    
```

**Shift Left Operation:**
```
Clock:      ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
shift_left: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
enable:     ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
q:         1101><1011  ><0111  ><1110  >< 1101
```

**Shift Right Operation:**
```
Clock:       ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
shift_right: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
enable:      ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
q:          1101>< 1110 >< 0111 >< 1011 >< 1101
```

## Constraints
NA