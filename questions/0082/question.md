# Prefix Sum

## Problem Statement

Design a module that computes prefix sums (cumulative sums) of an input stream using valid/ready handshake protocol. For each input value, output the running total up to and including that value.

### Module Interface
- **Module Name**: `prefix_sum`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new sequence (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH+7:0]`: Prefix sum output

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of input values |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Clear running sum, prepare for new sequence
3. **Compute**: For each input, output cumulative sum so far
4. **Streaming**: One output per input (same count)

### Example

```
Input:  [5, 3, 7, 2, 8]
Output: [5, 8, 15, 17, 25]

Calculation:
  5         -> 5
  5 + 3     -> 8
  8 + 7     -> 15
  15 + 2    -> 17
  17 + 8    -> 25
```

### Design Template

```verilog
module prefix_sum #(
    parameter DATA_WIDTH = 8
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      start,
    input  wire                      in_valid,
    input  wire [DATA_WIDTH-1:0]     in_data,
    input  wire                      out_ready,
    output wire                      in_ready,
    output wire                      out_valid,
    output wire [DATA_WIDTH+7:0]     out_data
);

    // Your implementation here...

endmodule
```

### Hints

- Maintain a running sum register
- Accept input only when output can be accepted (backpressure)
- Output is valid whenever we have a new prefix sum
- Clear sum on start signal

## Constraint
- Correctly implement valid/ready handshake
- One output for each input
- Handle backpressure correctly
