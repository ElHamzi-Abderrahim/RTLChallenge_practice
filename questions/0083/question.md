# Majority Element Finder

## Problem Statement

Design a module that finds the majority element in an input sequence using the Boyer-Moore Voting Algorithm. A majority element appears more than n/2 times in a sequence of n elements.

### Module Interface
- **Module Name**: `majority_elem`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new search (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_elem[DATA_WIDTH-1:0]`: Candidate majority element
  - `out_found`: 1 if majority exists, 0 otherwise

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |

### Boyer-Moore Voting Algorithm

```
candidate = none, count = 0

for each element x:
  if count == 0:
    candidate = x
    count = 1
  elif x == candidate:
    count++
  else:
    count--

// Verify candidate (second pass)
count = 0
for each element x:
  if x == candidate:
    count++

if count > n/2:
  return (candidate, true)
else:
  return (0, false)
```

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **First Pass**: Apply Boyer-Moore voting to find candidate
3. **Second Pass**: Verify candidate appears > n/2 times
4. **Output**: Report candidate and whether majority exists

### Example

```
Input: [2, 2, 1, 1, 2, 2, 2]
n = 7, majority threshold = 4

First pass (Boyer-Moore):
  2: candidate=2, count=1
  2: candidate=2, count=2
  1: candidate=2, count=1
  1: candidate=2, count=0
  2: candidate=2, count=1
  2: candidate=2, count=2
  2: candidate=2, count=3
  Candidate = 2

Second pass (verify):
  Count of 2s = 5 > 3.5

Output: elem=2, found=1
```

### Design Template

```verilog
module majority_elem #(
    parameter DATA_WIDTH = 8
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
    output wire [DATA_WIDTH-1:0] out_elem,
    output wire                  out_found
);

    // Your implementation here...

endmodule
```

### Hints

- Store all input values for second pass verification
- Track candidate and count during first pass
- When count reaches 0, adopt new candidate
- Second pass counts occurrences of candidate
- Compare final count with n/2

## Constraint
- Correctly implement valid/ready handshake
- Must verify majority (>n/2 occurrences, not just most frequent)
