# Self-Reload Counter

## Problem Statement

Self-reload counters are useful in applications requiring periodic resets to a specific value after reaching maximum count. These counters are commonly used in timers, PWM generators, and cyclic control systems where the counter needs to automatically restart from a pre-loaded value rather than zero after overflow.

Design a 4-bit self-reload counter that increments on each clock cycle and automatically reloads to a stored value when it overflows. The counter should support dynamic loading of the reload value during operation.

### Module Interface

**Module Name**: `self_reload_counter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `load_i` | Input | 1 | Load enable signal |
| `load_val_i` | Input | 4 | Value to load and use for reload, default is 0 in reset state |
| `count_o` | Output | 4 | Current counter value |

### Functional Requirements

1. **Asynchronous Reset**: Counter resets to 0 when reset is asserted
2. **Load Operation**: When `load_i` is asserted, counter takes `load_val_i` immediately
3. **Store Load Value**: The load value is stored internally for future reloads
4. **Normal Counting**: Counter increments by 1 on each clock cycle
5. **Auto-Reload**: When counter reaches maximum (15), it automatically reloads to the stored load value on next cycle

### Example Operation

**Behavior with load_val_i = 5:**

```
Clock:       ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
reset:       ‾‾‾‾\____________________________________________________________________________________________/‾‾‾‾‾‾‾\_________
load_i:      _______/‾‾‾‾‾‾‾\_______________/‾‾‾‾‾‾‾\___________________________________________________________________________
load_val_i:  <  0   ><  1   ><         10           ><            11            ><                  2                          >
count_o:     <     0    ><  1   ><  2   ><  3   ><  10  ><  11  ><  12  ><  13  ><  14  ><  15  ><  10  ><11 ><    0    ><  1  >
```

**Overflow and reload sequence:**
- After loading 5: counter = 5, 6, 7, 8, 9, A, B, C, D, E, F, 5, 6, 7, ...
- The counter continues from the stored load value (5) after reaching F

**Multiple load operations:**
- If a new value is loaded during counting, it becomes the new reload value
- Current count immediately changes to the new load value
- Future overflows will reload to this new value

## Constraints
NA