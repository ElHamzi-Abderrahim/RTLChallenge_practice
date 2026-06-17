# Debounce Circuit

## Problem Statement

Design a button debounce circuit that eliminates mechanical bounce from switch inputs. When a mechanical button is pressed or released, the contacts can bounce for several milliseconds, creating multiple unwanted transitions. The debounce circuit should output a clean, single transition.

### Module Interface

**Module Name**: `debounce`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Active high asynchronous reset |
| `button_in` | Input | 1 | Raw button input (bouncy) |
| `button_out` | Output | 1 | Debounced button output |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `CLK_FREQ` | 50000000 | System clock frequency in Hz |
| `DEBOUNCE_TIME_MS` | 20 | Debounce time in milliseconds |

### Functional Requirements

1. **Debounce Timing**: Input must be stable for DEBOUNCE_TIME_MS before output changes
2. **Clean Output**: Output only changes after input has been stable for the debounce period
3. **Both Edges**: Debounce both rising and falling edges of input
4. **Immediate Response**: Once debounced, output immediately follows stable input
5. **Reset Behavior**: Output should match input state during reset
6. **Parameterizable**: Support different clock frequencies and debounce times

### Example Operation

For DEBOUNCE_TIME_MS = 20ms:
1. Button pressed (1→0): Input bounces for 15ms, then stable low
2. After 20ms of stable low input, output goes low
3. Button released (0→1): Input bounces for 10ms, then stable high
4. After 20ms of stable high input, output goes high

Calculation: DEBOUNCE_CYCLES = (CLK_FREQ * DEBOUNCE_TIME_MS) / 1000

## Constraints
- Input can have unlimited bouncing within debounce period
- Output should never glitch or have intermediate transitions
- Counter should reset when input changes during debounce period
- All operations synchronous to system clock