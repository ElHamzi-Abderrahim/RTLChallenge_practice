# Moving Maximum Filter

## Problem Statement

Design a moving maximum filter that outputs the maximum value within a sliding window of the last N input values using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `moving_max`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `WINDOW_SIZE` (default: 4)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Clear the window (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `out_ready`: Downstream is ready to accept output
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_max[DATA_WIDTH-1:0]`: Maximum in current window

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `WINDOW_SIZE` | 4 | Number of values in sliding window |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- Each input produces one output (max of current window)

### Functional Requirements

1. **Reset**: On reset, window is empty
2. **Start**: When `start` asserted, clear the window
3. **Window Fill**: First WINDOW_SIZE inputs fill the window
4. **Sliding**: After window is full, oldest value is replaced
5. **Output**: Always output max of values currently in window

### Example (WINDOW_SIZE = 3)

```
Input sequence:  [2, 5, 1, 8, 3, 4]
Window states:   [2]     -> max = 2
                 [2,5]   -> max = 5
                 [2,5,1] -> max = 5
                 [5,1,8] -> max = 8
                 [1,8,3] -> max = 8
                 [8,3,4] -> max = 8
Output sequence: [2, 5, 5, 8, 8, 8]
```

### Example Waveform (WINDOW_SIZE = 3)

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
          ─────────────────────────────────────────────
in_ready
          ─────────────────────────────────────────────
in_valid
              ┌───────┬───────┬───────┬───────┬───────┐
in_data   ════│   2   │   5   │   1   │   8   │   3   │
              └───────┴───────┴───────┴───────┴───────┘
          ─────────────────────────────────────────────
out_valid
              ┌───────┬───────┬───────┬───────┬───────┐
out_max   ════│   2   │   5   │   5   │   8   │   8   │
              └───────┴───────┴───────┴───────┴───────┘
```

### Hints

- Use a circular buffer to store the window
- Track write pointer and valid count
- Scan all valid entries to find maximum
- Consider edge cases when window not yet full

## Constraint
- Correctly implement valid/ready handshake
- Output must be maximum of current window contents
