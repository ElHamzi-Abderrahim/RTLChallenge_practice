# 8-Bit Serial In Parallel Out Shift Register

## Problem Statement

Serial In Parallel Out (SIPO) shift registers are fundamental digital components used for serial-to-parallel data conversion. These registers are commonly used in applications such as data deserialization, parallel loading of serial data streams, and communication protocol implementations.

Design an 8-bit Serial In Parallel Out shift register that receives serial data bit by bit and outputs all 8 bits in parallel. The register should support synchronous reset and shift the serial input through the register on each clock cycle.

### Module Interface

**Module Name**: `serial_in_parallel_out`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clock` | Input | 1 | Clock input |
| `reset` | Input | 1 | Reset input (active high) |
| `serial_in` | Input | 1 | Serial input data |
| `parallel_out` | Output | 8 | 8-bit parallel output |

### Functional Requirements

1. **Serial Input**: Data is shifted in serially through the serial_in port
2. **Parallel Output**: All 8 bits are available simultaneously on parallel_out
3. **Synchronous Reset**: When reset=1, register resets to all zeros on next clock edge
4. **Shift Operation**: On each clock cycle, data shifts left, with new bit entering from the right
5. **Continuous Operation**: Register operates on every clock cycle when not in reset

### Example Operation

**Serial Data Input Sequence:**

```
Clock:     ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:     ‾‾‾\_________________________________________________________________
serial_in: ___________/‾‾‾\___/‾‾‾\___________/‾‾‾\___________________/‾‾‾\___
parallel:  <   8'd0          >< 8'd1 >< 8'd3 >< 8'd6 >< 8'd13>< 8'd26 ><8'd42>
```

## Constraints
NA