# Bubble Sort Engine

## Problem Statement

Design a bubble sort engine that accepts a sequence of numbers, sorts them in ascending order, and outputs the sorted sequence using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `bubble_sort`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 8) - Maximum array size
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start sorting (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready to accept output
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH-1:0]`: Sorted output value
  - `out_last`: Last output value indicator

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 8 | Maximum number of elements to sort |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- `in_last` marks the final input element
- `out_last` marks the final output element

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: When `start` is asserted, prepare to receive input
3. **Input Phase**: Accept values until `in_last` is seen
4. **Sort Phase**: Sort values using bubble sort algorithm
5. **Output Phase**: Output sorted values with handshake
6. **Completion**: Assert `out_last` with final element

### Bubble Sort Algorithm

```
bubble_sort(arr, n):
  for i = 0 to n-2:
    for j = 0 to n-2-i:
      if arr[j] > arr[j+1]:
        swap(arr[j], arr[j+1])

Example:
  Input:  [5, 2, 8, 1, 9]
  Output: [1, 2, 5, 8, 9]
```

### State Machine

```
IDLE -> INPUT -> SORT -> OUTPUT -> IDLE
         ^                  |
         |__________________|
              (new start)
```

### Example Waveform

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
              ┌───────┐
start     ────┘       └──────────────────────────────────────────
          ────────────────────────────────────┐
in_ready                                      └──────────────────
          ────────────────────────────┐
in_valid                              └──────────────────────────
              ┌───────┬───────┬───────┬───────┐
in_data   ════│   5   │   2   │   8   │   1   │══════════════════
              └───────┴───────┴───────┴───────┘
                                      ┌───────┐
in_last   ────────────────────────────┘       └──────────────────

                        ... sorting ...

                                      ┌───────────────────────────
out_valid ────────────────────────────┘
                                      ┌───────┬───────┬───────┬──
out_data  ════════════════════════════│   1   │   2   │   5   │ 8
                                      └───────┴───────┴───────┴──
                                                              ┌──
out_last  ────────────────────────────────────────────────────┘
```

### Hints

- Use a register array to store input values
- Track the number of elements received
- Implement bubble sort with nested loop counters
- One comparison/swap per clock cycle is acceptable
- Output elements sequentially after sorting completes

## Constraint
- Correctly implement valid/ready handshake
- Support arrays up to MAX_SIZE elements
- Must sort in ascending order
