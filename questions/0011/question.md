# Odd Counter

## Problem Statement

Design an 8-bit counter that counts only odd numbers. The counter should start at 1 and increment by 2 on each clock cycle, producing the sequence: 1, 3, 5, 7, 9, 11, ... and so on.

### Module Interface

**Module Name**: `odd_counter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `cnt_o` | Output | 8 | 8-bit counter output (odd numbers only) |

### Functional Requirements

1. **Odd Number Sequence**: Counter produces only odd numbers (1, 3, 5, 7, ...)
2. **Increment by 2**: Counter increments by 2 on each rising clock edge
3. **Asynchronous Reset**: Reset immediately sets counter to 1 when asserted
4. **8-bit Counter**: Counter uses 8-bit output, wrapping around after 255
5. **Initial Value**: Counter starts at 1 after reset

### Counter Behavior

- **Reset State**: `cnt_o = 8'h01` (1)
- **Normal Operation**: `cnt_o = cnt_o + 2` on each clock edge
- **Sequence**: 1 → 3 → 5 → 7 → 9 → 11 → ... → 253 → 255 → 1 (wrap around)

### Example Operation

```
Clock:    ____/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:    ‾‾‾‾‾‾‾‾\___________________________________________
cnt_o:    <    0      ><  1   ><   3  ><  5   >< 7    >< 9   >
```

**Wrap-around Behavior:** Since the counter is 8-bit and increments by 2, at `cnt_o = 255` (8'hFF), next value is `1` (8'h01), maintaining the odd-only property even after overflow.

## Constraints
NA