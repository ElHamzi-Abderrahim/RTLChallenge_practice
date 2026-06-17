# Clock Divider

## Problem Statement

Design a parameterizable clock divider module that generates an output clock with frequency equal to input clock frequency divided by a specified division factor. The output should have a 50% duty cycle when possible.

### Module Interface

**Module Name**: `clock_divider`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk_in` | Input | 1 | Input clock signal |
| `reset` | Input | 1 | Active high synchronous reset |
| `enable` | Input | 1 | Enable signal for clock divider |
| `clk_out` | Output | 1 | Divided output clock |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DIVIDE_FACTOR` | 2 | Clock division factor (must be >= 2) |

### Functional Requirements

1. **Clock Division**: Output frequency = Input frequency / DIVIDE_FACTOR
2. **50% Duty Cycle**: For even division factors, maintain 50% duty cycle
3. **Synchronous Reset**: When reset is high, output should be low
4. **Enable Control**: When enable is low, output should be low
5. **Parameterizable**: Support division factors from 2 to 1024
6. **Edge Alignment**: Output transitions aligned with positive edge of input clock

### Example Operation

For DIVIDE_FACTOR = 4:
- Input clock period = T
- Output clock period = 4T
- Output high for 2T, low for 2T

For DIVIDE_FACTOR = 3:
- Input clock period = T
- Output clock period = 3T
- Output toggles every 1.5T (approximate 50% duty cycle)

## Constraints
- DIVIDE_FACTOR must be >= 2
- Reset and enable are synchronous to clk_in