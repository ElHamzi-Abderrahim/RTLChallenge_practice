# Parameterizable Multiplexer

## Problem Statement

Design a parameterizable multiplexer that selects one of multiple input data streams based on a select signal. The module should be configurable for different data widths and number of inputs.

### Module Interface
- **Module Name**: `simple_mux`
- **Parameters**: `DATA_WIDTH` (default: 8), `SELECT_WIDTH` (default: 2)
- **Inputs**:
  - `data_in[DATA_WIDTH*(2**SELECT_WIDTH)-1:0]`: Concatenated input data streams
  - `select[SELECT_WIDTH-1:0]`: Select signal
- **Output**:
  - `data_out[DATA_WIDTH-1:0]`: Selected output data

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Width of each data input |
| `SELECT_WIDTH` | 2 | Width of select signal (determines number of inputs) |

### Functional Requirements

1. **Data Selection**: Select one input based on select signal value
2. **Parameterizable Inputs**: Number of inputs = 2^SELECT_WIDTH
3. **Packed Array**: All inputs packed into single array
4. **Combinational Logic**: Pure combinational implementation
5. **Input Mapping**: Input 0 at LSB, Input N at MSB of data_in array

### Example Operation

For DATA_WIDTH = 8, SELECT_WIDTH = 2 (4 inputs):
- `data_in[31:0]` = {input_3[7:0], input_2[7:0], input_1[7:0], input_0[7:0]}
- `select = 2'b00` → `data_out = input_0`
- `select = 2'b01` → `data_out = input_1`
- `select = 2'b10` → `data_out = input_2`
- `select = 2'b11` → `data_out = input_3`

## Constraint
NA