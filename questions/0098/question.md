# Multiply-Accumulate (MAC) Unit

## Problem Statement

Design a Multiply-Accumulate (MAC) unit, a fundamental building block in neural network accelerators. The MAC computes: accumulator += (A × B).

### MAC Operation

```
MAC: acc = acc + (a × b)

Used in neural networks for:
  - Dot products
  - Convolutions
  - Matrix multiplications
```

### Module Interface
- **Module Name**: `mac_unit`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `clear`: Clear accumulator (pulse)
  - `in_valid`: Input is valid
  - `in_a[DATA_WIDTH-1:0]`: Operand A (signed)
  - `in_b[DATA_WIDTH-1:0]`: Operand B (signed)
  - `in_last`: Last operation (output result)
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_acc[DATA_WIDTH*2+7:0]`: Accumulated result

### Functional Requirements

1. **Reset/Clear**: Reset accumulator to 0
2. **Accumulate**: Multiply inputs and add to accumulator
3. **Output**: On `in_last`, output final accumulator value

### Example

```
Dot product: [1,2,3] · [4,5,6]

Step 1: clear, acc = 0
Step 2: acc += 1*4 = 4
Step 3: acc += 2*5 = 14
Step 4: acc += 3*6 = 32 (in_last)

Output: acc = 32
```

### Design Template

```verilog
module mac_unit #(
    parameter DATA_WIDTH = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         clear,
    input  wire                         in_valid,
    input  wire signed [DATA_WIDTH-1:0] in_a,
    input  wire signed [DATA_WIDTH-1:0] in_b,
    input  wire                         in_last,
    input  wire                         out_ready,
    output wire                         in_ready,
    output wire                         out_valid,
    output wire signed [DATA_WIDTH*2+7:0] out_acc
);

    // Your implementation here...

endmodule
```

### Hints

- Product width = 2 × DATA_WIDTH
- Accumulator needs extra bits to prevent overflow
- Clear accumulator on `clear` signal
- Output after `in_last` asserted

## Constraint
- Correctly implement valid/ready handshake
- Handle signed multiplication
- Accumulator width must prevent overflow
