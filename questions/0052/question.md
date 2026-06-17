# Parity Generator/Checker

## Problem Statement

Design a parameterizable combinational module that generates and checks parity bits for error detection. The module should support both even and odd parity modes.

### Module Interface
- **Module Name**: `parity_gen_check`
- **Parameters**:
  - `DATA_WIDTH` (default: 8 bits)
  - `PARITY_TYPE` (default: 0 for even parity, 1 for odd parity)
- **Inputs**:
  - `data_in[DATA_WIDTH-1:0]`: Input data
  - `mode`: Operation mode (0 = generate parity, 1 = check parity)
  - `parity_in`: Input parity bit (used only in check mode)
- **Outputs**:
  - `parity_out`: Generated parity bit (valid in generate mode)
  - `error`: Error flag (1 if parity check fails, valid in check mode)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit-width of input data |
| `PARITY_TYPE` | 0 | 0 = Even parity, 1 = Odd parity |

### Functional Requirements

1. **Generate Mode (mode=0)**:
   - Calculate parity bit for the input data
   - For even parity: parity_out = XOR of all data bits (result has even number of 1s including parity)
   - For odd parity: parity_out = ~(XOR of all data bits) (result has odd number of 1s including parity)

2. **Check Mode (mode=1)**:
   - Verify if the received data + parity_in is valid
   - error = 1 if parity check fails, 0 if valid

3. **Combinational Logic**: Pure combinational implementation (no clock required)

### Example Operation

For DATA_WIDTH = 8, PARITY_TYPE = 0 (Even Parity):

**Generate Mode (mode=0)**:
| data_in     | parity_out | Explanation |
|-------------|------------|-------------|
| 8'b00000000 | 0          | 0 ones -> even, parity=0 |
| 8'b00000001 | 1          | 1 one -> odd, need parity=1 to make even |
| 8'b00000011 | 0          | 2 ones -> even, parity=0 |
| 8'b11111111 | 0          | 8 ones -> even, parity=0 |
| 8'b10101010 | 0          | 4 ones -> even, parity=0 |
| 8'b10101011 | 1          | 5 ones -> odd, parity=1 |

**Check Mode (mode=1)**:
| data_in     | parity_in | error | Explanation |
|-------------|-----------|-------|-------------|
| 8'b00000001 | 1         | 0     | 1+1=2 ones (even) -> valid |
| 8'b00000001 | 0         | 1     | 1+0=1 one (odd) -> error |
| 8'b11110000 | 0         | 0     | 4+0=4 ones (even) -> valid |
| 8'b11110000 | 1         | 1     | 4+1=5 ones (odd) -> error |

### Hints

- XOR reduction operator (^) can compute parity of all bits
- Odd parity is simply the inverse of even parity
- In check mode, include parity_in in the XOR calculation

## Constraint
NA
