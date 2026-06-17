# Merge Two Sorted Streams

## Problem Statement

Design a module that merges two sorted input streams into a single sorted output stream using valid/ready handshake protocol. This is similar to the merge step in merge sort.

### Module Interface
- **Module Name**: `merge_sorted`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_a_valid`: Stream A input is valid
  - `in_a_data[DATA_WIDTH-1:0]`: Stream A data
  - `in_a_last`: Last element of stream A
  - `in_b_valid`: Stream B input is valid
  - `in_b_data[DATA_WIDTH-1:0]`: Stream B data
  - `in_b_last`: Last element of stream B
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_a_ready`: Ready to accept stream A
  - `in_b_ready`: Ready to accept stream B
  - `out_valid`: Output is valid
  - `out_data[DATA_WIDTH-1:0]`: Merged sorted output
  - `out_last`: Last element of merged output

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |

### Valid/Ready Handshake Protocol

- Input A transfer occurs when `in_a_valid && in_a_ready`
- Input B transfer occurs when `in_b_valid && in_b_ready`
- Output transfer occurs when `out_valid && out_ready`
- Both inputs are assumed to be sorted in ascending order

### Functional Requirements

1. **Reset**: On reset, go to idle, ready for both inputs
2. **Merge**: Compare heads of both streams, output smaller one
3. **Stream End**: When one stream ends, output remaining from other
4. **Output**: `out_last` asserts when both streams are exhausted
5. **Assumption**: Both input streams are sorted ascending

### Merge Algorithm

```
merge(A, B):
  while A not empty AND B not empty:
    if head(A) <= head(B):
      output head(A), advance A
    else:
      output head(B), advance B

  output remaining elements from non-empty stream
```

### Example

```
Stream A: [1, 3, 5, 7]
Stream B: [2, 4, 6]

Output:   [1, 2, 3, 4, 5, 6, 7]

Step-by-step:
  Compare 1 vs 2: output 1 (from A)
  Compare 3 vs 2: output 2 (from B)
  Compare 3 vs 4: output 3 (from A)
  Compare 5 vs 4: output 4 (from B)
  Compare 5 vs 6: output 5 (from A)
  Compare 7 vs 6: output 6 (from B)
  B empty, output 7 (from A)
```

### Hints

- Hold current values from each stream until consumed
- Compare when both streams have valid data
- Track which streams have ended
- Use registers to hold "pending" data from each stream
- Output is valid when you have data to output and decision is made

## Constraint
- Correctly implement valid/ready handshake on all ports
- Output must be sorted (assuming sorted inputs)
- Handle unequal stream lengths
