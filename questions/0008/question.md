# D Flip-Flop 

## Problem Statement

Design a D flip-flop module that implements three different reset behaviors: no reset, synchronous reset, and asynchronous reset. This module demonstrates different reset methodologies commonly used in digital design.

### Module Interface

**Module Name**: `d_flip_flop`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Reset signal |
| `d_i` | Input | 1 | D input to the flip-flop |
| `q_norst_o` | Output | 1 | Q output from non-resettable flip-flop |
| `q_syncrst_o` | Output | 1 | Q output from flip-flop with synchronous reset |
| `q_asyncrst_o` | Output | 1 | Q output from flip-flop with asynchronous reset |

### Functional Requirements

1. **Non-resettable Flip-flop**: Simple D flip-flop that captures `d_i` on rising clock edge
2. **Synchronous Reset**: D flip-flop that resets to 0 on rising clock edge when `reset` is asserted
3. **Asynchronous Reset**: D flip-flop that immediately resets to 0 when `reset` is asserted (independent of clock)
4. **Positive Edge Triggered**: All flip-flops trigger on positive clock edge
5. **Active High Reset**: Reset signal is active when high

### Example Operation

**Reset Behavior:**

1. **q_norst_o**: Always follows d_i on clock edge, no reset functionality
2. **q_syncrst_o**: On clock edge - if reset=1 then output=0, else output=d_i
3. **q_asyncrst_o**: Immediately resets to 0 when reset=1 (asynchronous), on clock edge (when reset=0) output=d_i

```
Clock cycle: ____/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\__
reset:       ‾‾‾‾‾‾‾‾‾‾‾‾‾\___________/‾‾‾‾‾‾‾‾‾
d_in:        ____________/‾‾‾‾‾‾‾‾‾‾‾‾\_________
q_norst_o:   XXX_________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\______
q_syncrst_o: ____________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\______
q_asyncrst_o:____________/‾‾‾‾‾‾‾‾‾‾‾‾\_________
```

## Constraints
NA