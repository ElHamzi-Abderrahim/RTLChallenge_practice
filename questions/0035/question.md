# Barrel Shifter

## Problem Statement

Design a parameterizable barrel shifter that can perform left shift, right shift, and rotation operations on input data. A barrel shifter is a combinatorial circuit that can shift or rotate an n-bit input by any number of positions in a single clock cycle.

### Module Interface

**Module Name**: `barrel_shifter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `data_in` | Input | `[DATA_WIDTH-1:0]` | Input data to be shifted |
| `shift_amt` | Input | `[SHIFT_WIDTH-1:0]` | Number of positions to shift |
| `shift_dir` | Input | 1 | Shift direction (0=left, 1=right) |
| `shift_type` | Input | 1 | Shift type (0=logical, 1=rotate) |
| `data_out` | Output | `[DATA_WIDTH-1:0]` | Shifted output data |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Width of input/output data |
| `SHIFT_WIDTH` | 3 | Width of shift amount (log2(DATA_WIDTH)) |

### Functional Requirements

1. **Left Logical Shift**: Fill with zeros from the right
2. **Right Logical Shift**: Fill with zeros from the left
3. **Left Rotate**: Bits shifted out from left reappear on the right
4. **Right Rotate**: Bits shifted out from right reappear on the left
5. **Parameterizable Width**: Support different data widths
6. **Single Cycle**: All operations complete in one combinatorial delay
7. **Full Range**: Support shifts from 0 to DATA_WIDTH-1 positions

### Example Operation

For DATA_WIDTH = 8, data_in = 8'b10110101:

**Left Operations (shift_dir = 0)**:
- shift_amt = 2, shift_type = 0 (logical): 8'b11010100
- shift_amt = 2, shift_type = 1 (rotate): 8'b11010110

**Right Operations (shift_dir = 1)**:
- shift_amt = 3, shift_type = 0 (logical): 8'b00010110
- shift_amt = 3, shift_type = 1 (rotate): 8'b10110110

## Constraints
- SHIFT_WIDTH should be ceil(log2(DATA_WIDTH))
- All operations are combinatorial (no clock required)
- Shift amounts >= DATA_WIDTH should be handled gracefully