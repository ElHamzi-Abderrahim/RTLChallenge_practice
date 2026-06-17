# Bitonic Sequence Detector

## Problem Statement

Design a module that determines if an input sequence is bitonic using valid/ready handshake protocol. A bitonic sequence first monotonically increases and then monotonically decreases (or is entirely increasing or entirely decreasing).

### Module Interface
- **Module Name**: `bitonic_detect`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new check (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_is_bitonic`: 1 if sequence is bitonic, 0 otherwise
  - `out_peak_idx[7:0]`: Index of peak element (if bitonic)

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum sequence length |

### Bitonic Sequence Definition

A sequence is bitonic if:
1. It first increases then decreases, OR
2. It only increases (peak at end), OR
3. It only decreases (peak at start), OR
4. It's constant (all same values)

No element can appear after a decrease if another increase follows.

### Example

```
Bitonic:     [1, 3, 5, 7, 6, 4, 2]  (increases to 7, then decreases)
             Peak at index 3 (value 7)

Bitonic:     [1, 2, 3, 4, 5]        (only increases)
             Peak at index 4

Not Bitonic: [1, 3, 2, 4, 1]        (increases, decreases, increases again)
```

### Design Template

```verilog
module bitonic_detect #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    input  wire                  out_ready,
    output wire                  in_ready,
    output wire                  out_valid,
    output wire                  out_is_bitonic,
    output wire [7:0]            out_peak_idx
);

    // Your implementation here...

endmodule
```

### Hints

- Track state: INCREASING, DECREASING
- Once DECREASING, cannot go back to INCREASING
- Store the peak index when transition occurs
- Handle equal adjacent values (can be part of either phase)

## Constraint
- Correctly implement valid/ready handshake
- Handle edge cases: single element, all same values
- Equal adjacent values allowed in both phases
