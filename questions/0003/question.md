# Parameterizable Ring Counter

## Problem Statement

Design a parameterizable ring counter that shifts a single '1' bit through a series of flip-flops. The module should be configurable to handle different counter widths through a parameter.

### Module Interface
- **Module Name**: `ring_counter`
- **Parameter**: `COUNTER_WIDTH` (default: 4 bits)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset signal
- **Output**:
  - `count_out[COUNTER_WIDTH-1:0]`: Ring counter output

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `COUNTER_WIDTH` | 4 | Number of bits in the ring counter |

### Functional Requirements

1. **Ring Structure**: Single '1' bit circulates through counter positions
2. **Reset Behavior**: On reset, counter initializes to first position (count_out = 1)
3. **Clock Edge**: Counter advances on positive clock edge
4. **Parameterizable Width**: Support any width from 2 to 16 bits
5. **Circular Operation**: After reaching MSB position, '1' returns to LSB position

### Example Operation

For COUNTER_WIDTH = 4:
- Reset: `count_out = 4'b0001`
- Clock 1: `count_out = 4'b0010`
- Clock 2: `count_out = 4'b0100`
- Clock 3: `count_out = 4'b1000`
- Clock 4: `count_out = 4'b0001` (wraps around)

## Constraint
NA