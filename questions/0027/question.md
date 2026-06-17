# 4-Bit Up/Down Counter

## Problem Statement

Up/down counters are versatile digital components that can increment or decrement their output based on control signals. These counters are commonly used in applications requiring bidirectional counting such as position encoders, digital potentiometers, and reversible sequence generators.

Design a 4-bit up/down counter that can count from 0 to 15 in either direction based on a control input. The counter should support synchronous reset and handle overflow/underflow conditions by wrapping around to maintain continuous operation.
It should saturated at ceiling 4'b1111 and floor 4'b0000 withour overflow.

### Module Interface

**Module Name**: `UpDownCounter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock input |
| `rst` | Input | 1 | Reset input (active high) |
| `up_down` | Input | 1 | Direction control (1=up, 0=down) |
| `count` | Output | 4 | 4-bit counter output |

### Functional Requirements

1. **Up Counting**: When up_down=1, increment count on each clock edge
2. **Down Counting**: When up_down=0, decrement count on each clock edge
3. **Synchronous Reset**: When rst=1, counter resets to 0 on next clock edge
4. **Overflow Handling**: Count wraps from 15 to 0 when counting up
5. **Underflow Handling**: Count wraps from 0 to 15 when counting down
6. **Continuous Operation**: Counter operates on every clock cycle

### Example Operation

**Up Counting Sequence:**

```
Clock:    ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
rst:      ‾‾‾\_______________________________________
up_down:  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
count:    X  >< 0    ><  1   >< 2    >< 3    >< 4   
```

**Down Counting Sequence:**

```
Clock:    ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
rst:      ___________________________________________
up_down:  ___________________________________________
count:    15 >< 14   >< 13   >< 12   >< 11   >< 10  
```

**Wrap-around Behavior:**
- **Up Overflow**: 14 → 15 → 0 → 1 → 2 → ...
- **Down Underflow**: 2 → 1 → 0 → 15 → 14 → ...

**Direction Change:**
```
Clock:    ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
up_down:  ‾‾‾‾‾‾‾\___________________________________
count:    5  >< 6    >< 5    >< 4    >< 3    >< 2
```

## Constraints
NA