# Gray Code Counter

## Problem Statement

Design a parameterizable Gray code counter that generates a sequence where only one bit changes between consecutive values. Gray code (also known as reflected binary code) is useful in applications where minimizing switching noise is important.

### Module Interface

**Module Name**: `gray_counter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Active high synchronous reset |
| `enable` | Input | 1 | Enable signal for counter |
| `gray_count` | Output | `[WIDTH-1:0]` | Gray code counter output |
| `binary_count` | Output | `[WIDTH-1:0]` | Corresponding binary count |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `WIDTH` | 4 | Number of bits in the counter |

### Functional Requirements

1. **Gray Code Sequence**: Generate standard Gray code sequence
2. **Binary Output**: Provide corresponding binary count for reference
3. **Synchronous Reset**: Reset to all zeros when reset is asserted
4. **Enable Control**: Counter advances only when enable is high
5. **Parameterizable Width**: Support widths from 2 to 16 bits
6. **Rollover**: Counter wraps around after reaching maximum value

### Example Operation

For WIDTH = 3, the sequence should be:
- Binary: 000 → Gray: 000
- Binary: 001 → Gray: 001
- Binary: 010 → Gray: 011
- Binary: 011 → Gray: 010
- Binary: 100 → Gray: 110
- Binary: 101 → Gray: 111
- Binary: 110 → Gray: 101
- Binary: 111 → Gray: 100
- Then repeats from 000

Note: Only one bit changes between consecutive Gray code values.

## Constraints
- All operations on positive clock edge
- Reset is synchronous and active high
- Gray code follows standard reflected binary code pattern