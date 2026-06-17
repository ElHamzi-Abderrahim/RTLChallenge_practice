# Dual Edge Flip Flop

## Problem Statement

Design a dual-edge triggered flip-flop that captures input data on both rising and falling edges of the clock. The module should be parameterizable to handle different data widths.

### Module Interface
- **Module Name**: `dual_edge_dff`
- **Parameter**: `DATA_WIDTH` (default: 8 bits)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset signal
  - `data_in[DATA_WIDTH-1:0]`: Input data
- **Output**:
  - `data_out[DATA_WIDTH-1:0]`: Output data

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Width of input/output data |

### Functional Requirements

1. **Dual Edge Trigger**: Capture data on both rising and falling clock edges
2. **Reset Behavior**: On reset, output initializes to 0
3. **Data Capture**: Update output with input data on each clock edge
4. **Parameterizable Width**: Support any width from 1 to 32 bits
5. **Synthesizable Design**: Must be implementable in hardware

### Example Operation

For DATA_WIDTH = 4:
- Reset: `data_out = 4'b0000`
- Rising edge: `data_out` = current `data_in`
- Falling edge: `data_out` = current `data_in`
- Effective frequency doubling compared to single-edge flip-flop

clk:        ____/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
rst_n:      __________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
data_in:    <     4     ><2 ><1 ><2 ><0 ><3 ><4 ><1 ><2 >
data_out:   <     0     ><4 ><2 ><1 ><2 ><0 ><3 ><4 ><1 >


## Constraint
NA