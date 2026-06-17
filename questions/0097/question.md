# ReLU Activation Unit

## Problem Statement

Design a module that implements the ReLU (Rectified Linear Unit) activation function commonly used in neural networks. ReLU outputs the input if positive, or zero if negative.

### ReLU Function

```
ReLU(x) = max(0, x) = { x  if x > 0
                      { 0  if x <= 0
```

### Module Interface
- **Module Name**: `relu_unit`
- **Parameters**:
  - `DATA_WIDTH` (default: 16) - Signed input width
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input is valid
  - `in_data[DATA_WIDTH-1:0]`: Signed input value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output is valid
  - `out_data[DATA_WIDTH-1:0]`: ReLU output

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Compute**: Apply ReLU function
3. **Output**: Zero if negative, input value if positive

### Example

```
Input: -5 (signed)  -> Output: 0
Input: 0            -> Output: 0
Input: 10 (signed)  -> Output: 10
Input: -128         -> Output: 0
Input: 127          -> Output: 127
```

### Design Template

```verilog
module relu_unit #(
    parameter DATA_WIDTH = 16
)(
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       in_valid,
    input  wire signed [DATA_WIDTH-1:0] in_data,
    input  wire                       out_ready,
    output wire                       in_ready,
    output wire                       out_valid,
    output wire signed [DATA_WIDTH-1:0] out_data
);

    // Your implementation here...

endmodule
```

### Hints

- Check MSB for sign (1 = negative in two's complement)
- Can be purely combinational with output register
- Simple mux: negative -> 0, positive -> passthrough

## Constraint
- Correctly implement valid/ready handshake
- Input is signed (two's complement)
