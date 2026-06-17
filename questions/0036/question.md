# PWM Generator

## Problem Statement

Design a parameterizable Pulse Width Modulation (PWM) generator that produces a square wave output with variable duty cycle. PWM is commonly used in motor control, LED dimming, and DAC applications.

### Module Interface

**Module Name**: `pwm_generator`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Active high synchronous reset |
| `enable` | Input | 1 | Enable signal for PWM generation |
| `duty_cycle` | Input | `[COUNTER_WIDTH-1:0]` | Duty cycle value (0 to PWM_PERIOD-1) |
| `pwm_out` | Output | 1 | PWM output signal |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `COUNTER_WIDTH` | 8 | Width of internal counter |
| `PWM_PERIOD` | 256 | PWM period (2^COUNTER_WIDTH) |

### Functional Requirements

1. **Variable Duty Cycle**: Output high for duty_cycle clocks, low for remainder of period
2. **Synchronous Reset**: Reset counter and output when reset is asserted
3. **Enable Control**: PWM only operates when enable is high
4. **Period Control**: Complete PWM cycle every PWM_PERIOD clock cycles
5. **Parameterizable**: Support different counter widths and periods
6. **Edge Cases**: Handle duty_cycle = 0 (always low) and duty_cycle >= PWM_PERIOD (always high)

### Example Operation

For COUNTER_WIDTH = 4, PWM_PERIOD = 16:
- duty_cycle = 4: Output high for 4 clocks, low for 12 clocks (25% duty cycle)
- duty_cycle = 8: Output high for 8 clocks, low for 8 clocks (50% duty cycle)
- duty_cycle = 12: Output high for 12 clocks, low for 4 clocks (75% duty cycle)
- duty_cycle = 0: Always low (0% duty cycle)
- duty_cycle = 16: Always high (100% duty cycle)

## Constraints
- PWM_PERIOD should be <= 2^COUNTER_WIDTH
- All operations on positive clock edge
- Output should be low during reset