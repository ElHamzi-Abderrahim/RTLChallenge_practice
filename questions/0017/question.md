# Parallel-to-Serial Converter

## Problem Statement

Parallel-to-serial converters are fundamental components in digital communication systems, commonly used in data transmission interfaces, serial communication protocols, and bandwidth reduction applications. These converters take parallel data and transmit it serially, one bit at a time, enabling efficient data transfer over single-wire connections.

Design a 4-bit parallel-to-serial converter that accepts 4-bit parallel data and outputs it serially. The converter should include control signals to indicate when data is available for loading and when valid serial data is being output.

### Module Interface

**Module Name**: `parallel_to_serial`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `empty_o` | Output | 1 | Empty flag (ready to accept new parallel data) |
| `parallel_i` | Input | 4 | 4-bit parallel input data |
| `serial_o` | Output | 1 | Serial output data |
| `valid_o` | Output | 1 | Valid flag (serial data is valid) |

### Functional Requirements

1. **Asynchronous Reset**: All internal registers reset to 0 when reset is asserted
2. **Parallel Load**: When `empty_o` is high, parallel data is loaded on next clock edge
3. **Serial Shift**: After loading, data shifts out LSB-first over 4 clock cycles
4. **Empty Signal**: `empty_o` is high when converter is ready for new data
5. **Valid Signal**: `valid_o` is high when serial output contains valid data
6. **Automatic Cycling**: After 4 bits are shifted out, converter becomes empty again

### Example Operation

**Loading and shifting 4'b1010:**

```
Clock:       ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:       ‾‾‾‾\______________________________________________________________________
parallel_i:  <  X   ><        1010         ><             1111          ><    1100     >
empty_o:     ‾‾‾‾‾‾‾‾‾‾‾\_______________________/‾‾‾‾‾‾‾\_______________________________
valid_o:     ________________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_____________________
serial_o:    <      0   ><  1   ><  0   ><  1   ><  0   ><  1   ><  1   ><  1   ><  1  >  
```

**Detailed timing:**
- Clock 1: `empty_o=1`, parallel data 1010 is loaded
- Clock 2: `empty_o=0`, `valid_o=1`, `serial_o=0` (LSB first)
- Clock 3: `valid_o=1`, `serial_o=1`
- Clock 4: `valid_o=1`, `serial_o=0`
- Clock 5: `valid_o=1`, `serial_o=1`
- Clock 6: `empty_o=1`, `valid_o=0`, ready for new data

## Constraints
NA