# Trailing Zero Counter

## Problem Statement

Design a module that counts the number of trailing zeros in a binary number using valid/ready handshake protocol. Trailing zeros are consecutive zeros starting from the least significant bit.

### Module Interface
- **Module Name**: `trailing_zero`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_count[$clog2(DATA_WIDTH+1)-1:0]`: Number of trailing zeros

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of input value |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Input**: Accept input value
3. **Count**: Count trailing zeros from LSB
4. **Output**: Return count of trailing zeros

### Example

```
Input: 0b01011000 (88)
       ^      ^^^
       MSB    3 trailing zeros

Output: count = 3

More examples:
  0b00000001 (1)   -> count = 0
  0b00000010 (2)   -> count = 1
  0b00000100 (4)   -> count = 2
  0b00001000 (8)   -> count = 3
  0b10000000 (128) -> count = 7
  0b00000000 (0)   -> count = 8 (all zeros)
```

### Design Template

```verilog
module trailing_zero #(
    parameter DATA_WIDTH = 8
)(
    input  wire                            clk,
    input  wire                            rst_n,
    input  wire                            in_valid,
    input  wire [DATA_WIDTH-1:0]           in_data,
    input  wire                            out_ready,
    output wire                            in_ready,
    output wire                            out_valid,
    output wire [$clog2(DATA_WIDTH+1)-1:0] out_count
);

    // Your implementation here...

endmodule
```

### Hints

- Scan from bit 0 upward until finding a 1
- Can use iterative approach or priority encoder
- For input 0, all bits are trailing zeros
- Count is in range [0, DATA_WIDTH]

## Constraint
- Correctly implement valid/ready handshake
- Handle input value 0 correctly (returns DATA_WIDTH)
