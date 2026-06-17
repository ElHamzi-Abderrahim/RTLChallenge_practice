# Dual Edge Detector

## Problem Statement

Design a dual edge detector module that detects both rising and falling edges of an input signal. The module should output a single-cycle pulse for each type of edge detected.

### Module Interface

**Module Name**: `dual_edge_detector`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Reset signal |
| `a_i` | Input | 1 | Input signal to monitor for edges |
| `rising_edge_o` | Output | 1 | Single-cycle pulse on rising edge of a_i |
| `falling_edge_o` | Output | 1 | Single-cycle pulse on falling edge of a_i |

### Functional Requirements

1. **Rising Edge Detection**: Detect transition from 0 to 1 on `a_i`
2. **Falling Edge Detection**: Detect transition from 1 to 0 on `a_i`
3. **Single-Cycle Pulse**: Output pulses last exactly one clock cycle
4. **Synchronous Operation**: All edge detection is synchronized to clock
5. **Reset Functionality**: Reset clears all internal state and outputs

### Example Operation

**Edge Detection Logic:**
- Rising Edge: `rising_edge_o = a_i & ~a_i_prev`
- Falling Edge: `falling_edge_o = ~a_i & a_i_prev`
- Where `a_i_prev` is the previous value of `a_i` (captured on previous clock edge)

```
Clock:          ____/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:          ‾‾‾‾‾‾‾‾‾‾‾‾‾\______________________________________
a_i:            __________/‾‾‾‾‾‾‾‾‾‾‾\___________/‾‾‾‾‾‾‾\_________
rising_edge_o:  ____________/‾‾‾\___________________/‾‾‾\___________
falling_edge_o: ____________________________/‾‾‾\___________/‾‾‾\___
```

## Constraints
NA