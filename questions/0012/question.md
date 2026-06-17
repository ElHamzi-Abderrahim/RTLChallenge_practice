# 4-bit Shift Register

## Problem Statement

Design a 4-bit serial-in, parallel-out shift register that shifts data from the serial input to the parallel output on each clock cycle. The shift register should support asynchronous reset functionality.

### Module Interface

**Module Name**: `shift_register`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `x_i` | Input | 1 | Serial input data |
| `sr_o` | Output | 4 | 4-bit parallel output |

### Functional Requirements

1. **Serial-In, Parallel-Out**: Accept serial data input and provide parallel data output
2. **Left Shift Operation**: Shift data left on each clock cycle (MSB shifts out, new data at LSB)
3. **Asynchronous Reset**: Reset immediately clears all register bits to 0
4. **4-bit Width**: Register stores 4 bits of data
5. **Edge Triggered**: Register updates on positive clock edge

### Shift Register Behavior

- **Reset State**: `sr_o = 4'b0000`
- **Normal Operation**: `sr_o = {sr_o[2:0], x_i}` (shift left, new bit at LSB)
- **Data Flow**: `x_i` → `sr_o[0]` → `sr_o[1]` → `sr_o[2]` → `sr_o[3]` → (shifted out)

### Example Operation

```
Clock:  _____/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:  ‾‾‾‾‾‾‾‾\____________________________________________
x_i:    <      1     ><  0   ><  1   ><   1  ><  0  ><  0   >
sr_o:   <0000        ><0001  ><0010  ><0101  ><1011 ><0110  >
```

**Detailed Shift Sequence** to shift in pattern `1011` (MSB first):

| Clock | x_i | sr_o[3:0] | Description |
|-------|-----|-----------|-------------|
| Reset | X   | 0000      | Reset state |
| 1     | 1   | 0001      | Shift in first bit (1) |
| 2     | 0   | 0010      | Shift in second bit (0) |
| 3     | 1   | 0101      | Shift in third bit (1) |
| 4     | 1   | 1011      | Shift in fourth bit (1) |
| 5     | X   | 0110      | Continue shifting (MSB lost) |

## Constraints
NA