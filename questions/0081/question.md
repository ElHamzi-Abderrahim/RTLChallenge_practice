# Stream Accumulator

## Problem Statement

Design a module that accumulates (sums) all values from an input stream and outputs the total sum using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `stream_accum`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new accumulation (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_sum[DATA_WIDTH+7:0]`: Accumulated sum (extra bits for overflow)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of input values |

### Functional Requirements

1. **Reset**: On reset, go to idle state, sum = 0
2. **Start**: Clear accumulator, prepare for new sequence
3. **Accumulate**: Add each input value to running sum
4. **Output**: When `in_last` received, output total sum

### Example

```
Input: [5, 10, 3, 7, 15]
Output: sum = 40

Calculation:
  0 + 5 = 5
  5 + 10 = 15
  15 + 3 = 18
  18 + 7 = 25
  25 + 15 = 40
```

### Design Template

```verilog
module stream_accum #(
    parameter DATA_WIDTH = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      start,
    input  wire                      in_valid,
    input  wire [DATA_WIDTH-1:0]     in_data,
    input  wire                      in_last,
    input  wire                      out_ready,
    output wire                      in_ready,
    output wire                      out_valid,
    output wire [DATA_WIDTH+7:0]     out_sum
);

    // Your implementation here...

endmodule
```

### Hints

- Use a register to hold running sum
- Clear sum on `start` signal
- Output becomes valid after `in_last` is received
- Extra output bits prevent overflow for sequences up to 256 elements

## Constraint
- Correctly implement valid/ready handshake
- Handle empty sequences (start followed by immediate in_last)
