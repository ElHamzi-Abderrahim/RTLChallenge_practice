# Palindrome Checker

## Problem Statement

Design a palindrome checker that determines if an input sequence reads the same forwards and backwards using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `palindrome_check`
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
  - `out_ready`: Downstream is ready to accept result
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_is_palindrome`: 1 if palindrome, 0 otherwise

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `MAX_SIZE` | 16 | Maximum sequence length |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- `in_last` marks the final input element

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: When `start` asserted, prepare to receive input
3. **Input Phase**: Accept values until `in_last` is seen
4. **Check Phase**: Compare first half with reversed second half
5. **Output**: Assert `out_is_palindrome` = 1 if palindrome

### Examples

```
Palindrome sequences:
  [1, 2, 3, 2, 1]  -> is_palindrome = 1
  [A, B, B, A]     -> is_palindrome = 1
  [5, 5, 5]        -> is_palindrome = 1
  [7]              -> is_palindrome = 1 (single element)

Non-palindrome sequences:
  [1, 2, 3, 4, 5]  -> is_palindrome = 0
  [A, B, C]        -> is_palindrome = 0
  [1, 2, 1, 2]     -> is_palindrome = 0
```

### State Machine

```
IDLE -> INPUT -> CHECK -> OUTPUT -> IDLE
```

### Example Waveform

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
              ┌───────┐
start     ────┘       └──────────────────────────────────────────
          ────────────────────────────────────────────┐
in_ready                                              └──────────
          ────────────────────────────────────┐
in_valid                                      └──────────────────
              ┌───────┬───────┬───────┬───────┬───────┐
in_data   ════│   1   │   2   │   3   │   2   │   1   │══════════
              └───────┴───────┴───────┴───────┴───────┘
                                              ┌───────┐
in_last   ────────────────────────────────────┘       └──────────

                                                      ┌───────┐
out_valid ────────────────────────────────────────────┘       └──
                                                      ┌───────┐
out_is_palindrome ════════════════════════════════════│   1   │══
                                                      └───────┘
```


### Hints

- Store all input values in a buffer
- Compare buffer[i] with buffer[n-1-i] for i = 0 to n/2
- A single element is always a palindrome
- Can check one pair per clock cycle or all at once

## Constraint
- Correctly implement valid/ready handshake
- Support sequences up to MAX_SIZE elements
