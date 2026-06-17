# Round Robin Arbiter

## Problem Statement

Round robin arbiters provide fair resource allocation by cycling through requesters in order, ensuring each requester gets equal opportunity to access shared resources. Unlike priority arbiters that always favor certain requesters, round robin arbiters maintain fairness by remembering the last granted requester and starting the next arbitration from the following requester in sequence.

Design a 4-port round robin arbiter that grants access to requesters in a rotating fashion. The arbiter should maintain state to track the last granted requester and always start the next arbitration cycle from the next requester in sequence, ensuring fair access distribution over time.

### Module Interface

**Module Name**: `round_robin_arbiter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `req_i` | Input | 4 | Request signals from 4 requesters |
| `gnt_o` | Output | 4 | One-hot grant signal |

### Functional Requirements

1. **Round Robin Fairness**: Grant requests in rotating order starting from the next requester after the last granted
2. **State Tracking**: Remember the last granted requester across clock cycles
3. **One-Hot Grant**: Only one grant signal can be asserted at any time
4. **Asynchronous Reset**: Reset to initial state where next grant will be to port 0
5. **No Grant Without Request**: Only grant when there is at least one active request
6. **Immediate Next Cycle**: Grant appears on the same cycle as request evaluation

### Example Operation

**Round Robin Sequence:**
Starting condition: Last granted = none (will grant to port 0 first)

```
Clock:   ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
req_i:   ----<0001>---<0110>---<1111>---<0101>---<1000>---
gnt_o:   ----<0001>---<0010>---<0100>---<0001>---<1000>---
Last:      (none)     0         1         2         0
```

**Detailed arbitration behavior:**
- When req_i = 4'b0001: Grant to port 0 (only requester)
- When req_i = 4'b0110: Grant to port 1 (next after port 0, among requesters 1,2)
- When req_i = 4'b1111: Grant to port 2 (next after port 1, among all requesters)
- When req_i = 4'b0101: Grant to port 0 (next after port 2, wrapping around, among requesters 0,2)
- When req_i = 4'b1000: Grant to port 3 (only requester)

**Fairness Example over time:**
If all 4 ports continuously request: 0 → 1 → 2 → 3 → 0 → 1 → 2 → 3 → ...

## Constraints
NA