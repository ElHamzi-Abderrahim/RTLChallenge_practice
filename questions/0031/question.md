# Johnson Counter

## Problem Statement

Design a parameterizable Johnson counter (also known as a twisted ring counter) that generates a sequence where only one bit changes at each clock cycle. The Johnson counter is a type of shift register where the inverted output of the last flip-flop is fed back to the input of the first flip-flop.

### Module Interface

**Module Name**: `johnson_counter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Active high synchronous reset |
| `enable` | Input | 1 | Enable signal for counter operation |
| `count_out` | Output | `[WIDTH-1:0]` | Current counter state |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `WIDTH` | 4 | Number of bits in the counter |

### Functional Requirements

1. **Johnson Counter Sequence**: Generate the standard Johnson counter sequence
2. **Synchronous Reset**: When reset is high, counter should reset to all zeros
3. **Enable Control**: Counter only advances when enable is high
4. **Parameterizable Width**: Support widths from 2 to 16 bits
5. **Clock Edge**: All operations on positive clock edge

### Example Operation

For WIDTH = 4, the sequence should be:
- State 0: `4'b0000`
- State 1: `4'b0001`
- State 2: `4'b0011`
- State 3: `4'b0111`
- State 4: `4'b1111`
- State 5: `4'b1110`
- State 6: `4'b1100`
- State 7: `4'b1000`
- Then repeats from State 0

Total sequence length = 2 * WIDTH states

## Constraints
NA