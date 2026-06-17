# Traffic Light Controller

## Problem Statement

Design a traffic light controller for a simple intersection with North-South and East-West roads. The controller should manage the traffic lights according to typical traffic light sequences and timing requirements.

### Module Interface

**Module Name**: `traffic_light_controller`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Active high asynchronous reset |
| `enable` | Input | 1 | Enable traffic light operation |
| `emergency` | Input | 1 | Emergency override (all lights red) |
| `ns_red` | Output | 1 | North-South red light |
| `ns_yellow` | Output | 1 | North-South yellow light |
| `ns_green` | Output | 1 | North-South green light |
| `ew_red` | Output | 1 | East-West red light |
| `ew_yellow` | Output | 1 | East-West yellow light |
| `ew_green` | Output | 1 | East-West green light |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `CLK_FREQ` | 1000 | Clock frequency in Hz (for simulation) |
| `GREEN_TIME_SEC` | 10 | Green light duration in seconds |
| `YELLOW_TIME_SEC` | 3 | Yellow light duration in seconds |
| `RED_TIME_SEC` | 2 | All-red safety time in seconds |

### Functional Requirements

1. **Normal Sequence**: Green → Yellow → Red (with all-red safety period)
2. **Alternating Direction**: When one direction is green, the other is red
3. **Safety Period**: Brief all-red period between direction changes
4. **Emergency Mode**: When emergency is asserted, all lights turn red immediately
   - Timer should be reset to 0 during emergency
   - State machine should remain in its current state (don't change state)
   - When emergency is deasserted, the controller resumes from the current state
   - Timer starts counting from 0 again when emergency is released
   - Example: If emergency occurs during NS_GREEN_EW_RED state, when emergency is released, the controller stays in NS_GREEN_EW_RED and continues the green cycle from the beginning
5. **Reset Behavior**: Start with North-South green, East-West red
6. **Enable Control**: Traffic lights only cycle when enable is high
   - When enable is low, timer should not increment and state should not change
7. **Timing**: Each state duration based on parameter values
   - Timer increments from 0 to (CYCLES - 1) for each state

### State Sequence

1. **NS_GREEN_EW_RED**: North-South green, East-West red (GREEN_TIME_SEC)
2. **NS_YELLOW_EW_RED**: North-South yellow, East-West red (YELLOW_TIME_SEC)
3. **ALL_RED_1**: All lights red safety period (RED_TIME_SEC)
4. **EW_GREEN_NS_RED**: East-West green, North-South red (GREEN_TIME_SEC)
5. **EW_YELLOW_NS_RED**: East-West yellow, North-South red (YELLOW_TIME_SEC)
6. **ALL_RED_2**: All lights red safety period (RED_TIME_SEC)
7. **Repeat from step 1**

## Constraints
- Only one light per direction can be active at a time
- Emergency overrides all other controls (emergency has highest priority)
- State transitions only occur when timer reaches (CYCLES - 1)
- All timing based on CLK_FREQ parameter
- Timer calculation: GREEN_CYCLES = CLK_FREQ * GREEN_TIME_SEC (same for YELLOW and RED)

## Implementation Notes
- Use a state machine with 6 states as described above
- Use a counter/timer that counts from 0 to (STATE_CYCLES - 1)
- When timer reaches the terminal count, transition to next state and reset timer
- Priority order (highest to lowest):
  1. Reset: Initialize to NS_GREEN_EW_RED state with timer=0
  2. Emergency: Force all lights red, reset timer=0, preserve current state
  3. Enable: Normal operation - increment timer and transition states
  4. !Enable: Freeze timer and state (no changes)
- After emergency deasserts: The state remains unchanged, timer is still 0, and normal state outputs resume
  - The current state's normal light pattern is restored
  - Timer begins counting from 0 for the current state
  - This effectively restarts the current state's timing cycle