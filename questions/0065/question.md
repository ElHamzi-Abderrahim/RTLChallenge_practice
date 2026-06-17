# Sequence Reverser

## Problem Statement

Design a sequence reverser that accepts a sequence of values and outputs them in reverse order using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `seq_reverse`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `MAX_SIZE` (default: 8) - Maximum sequence length
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new sequence (pulse)
  - `in_valid`: Input data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input value
  - `in_last`: Last input value indicator
  - `out_ready`: Downstream is ready to accept output
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH-1:0]`: Reversed output value
  - `out_last`: Last output value indicator

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 8 | Maximum sequence length |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- `in_last` marks the final input element
- `out_last` marks the final output element

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: When `start` asserted, prepare to receive input
3. **Input Phase**: Accept values until `in_last` is seen
4. **Output Phase**: Output values in reverse order
5. **Completion**: Assert `out_last` with final element

### Example

```
Input sequence:  [A, B, C, D, E]
Output sequence: [E, D, C, B, A]

Input sequence:  [1, 2, 3]
Output sequence: [3, 2, 1]
```

### State Machine

```
IDLE -> INPUT -> OUTPUT -> IDLE
         ^          |
         |__________|
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
in_data   ════│   1   │   2   │   3   │   4   │══════════════════
              └───────┴───────┴───────┴───────┘
                                      ┌───────┐
in_last   ────────────────────────────┘       └──────────────────

                                      ┌───────────────────────────
out_valid ────────────────────────────┘
                                      ┌───────┬───────┬───────┬──
out_data  ════════════════════════════│   4   │   3   │   2   │ 1
                                      └───────┴───────┴───────┴──
                                                              ┌──
out_last  ────────────────────────────────────────────────────┘
```

### Hints

- Use a register array to store input values
- Track the count of received elements
- Output from index (count-1) down to 0
- No computation needed, just storage and indexing

## Constraint
- Correctly implement valid/ready handshake
- Support sequences up to MAX_SIZE elements
- Output must be exact reverse of input
