# Parameterizable Ripple Counter

## Problem Statement

Design a parameterizable ripple counter that counts from 0 to maximum value and wraps around. The module should be configurable to handle different counter widths through a parameter.

### Module Interface
- **Module Name**: `ripple_counter`
- **Parameter**: `COUNTER_WIDTH` (default: 4 bits)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset signal
- **Output**:
  - `count_out[COUNTER_WIDTH-1:0]`: Counter output value

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `COUNTER_WIDTH` | 4 | Number of bits in the counter |

### Functional Requirements

1. **Binary Counting**: Counter increments by 1 on each clock cycle
2. **Reset Behavior**: On reset, counter initializes to 0
3. **Clock Edge**: Counter advances on positive clock edge
4. **Parameterizable Width**: Support any width from 2 to 16 bits
5. **Wrap Around**: After reaching maximum value, counter returns to 0

### Example Operation

For COUNTER_WIDTH = 4:
- Reset: `count_out = 4'b0000` (0)
- Clock 1: `count_out = 4'b0001` (1)
- Clock 2: `count_out = 4'b0010` (2)
- ...
- Clock 15: `count_out = 4'b1111` (15)
- Clock 16: `count_out = 4'b0000` (0, wraps around)

## Constraint
NA