# IIR Biquad Filter

## Problem Statement

Design an Infinite Impulse Response (IIR) biquadratic filter module that implements a second-order recursive digital filter. This filter provides both feedforward and feedback paths, making it more efficient than FIR filters for achieving sharp frequency responses.

### Module Interface

**Module Name**: `iir_biquad`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset (active high) |
| `data_in` | Input | `[DATA_WIDTH-1:0]` | Input data sample (signed) |
| `data_out` | Output | `[DATA_WIDTH-1:0]` | Filtered output (signed) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit-width of input/output data |

### Functional Requirements

1. **Biquad Structure**: Implement a second-order IIR filter with fixed coefficients
2. **Delay Elements**: Maintain delay lines for both input and output samples (x[n-1], x[n-2], y[n-1])
3. **MAC Operations**: Multiple multiply-accumulate operations for filter computation
4. **Saturation**: Prevent overflow by saturating the output to valid range
5. **Asynchronous Reset**: Clear all internal state when reset is asserted

### Filter Equation

```
y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2] - a1*y[n-1] - a2*y[n-2]
```

**Fixed Coefficients** (scaled by 8 for integer arithmetic):
- b0 = 1, b1 = 2, b2 = 1 (feedforward coefficients)
- a1 = 1, a2 = 0 (feedback coefficients, note: a0 = 1 is implicit)

**Simplified equation**:
```
y[n] = (x[n] + 2*x[n-1] + x[n-2] - y[n-1]) / 8
```

### Example Operation

For DATA_WIDTH = 8 with input sequence [16, 32, 48, 32]:
- Clock 0: y[0] = (16 + 0 + 0 - 0)/8 = 2
- Clock 1: y[1] = (32 + 32 + 0 - 2)/8 = 7
- Clock 2: y[2] = (48 + 64 + 16 - 7)/8 = 15
- Clock 3: y[3] = (32 + 96 + 32 - 15)/8 = 18

### Implementation Details

**Calculation Timing**:
1. On each clock cycle, compute output using **current** delay values: y[n] = (x[n] + 2*x[n-1] + x[n-2] - y[n-1]) / 8
2. Update delay elements: x[n-1] ← x[n], x[n-2] ← x[n-1], y[n-1] ← y[n]
3. The feedback term y[n-1] uses the output from the **previous** clock cycle

**Arithmetic Width**:
- Accumulator needs at least DATA_WIDTH+4 bits to prevent overflow before division
- Example for DATA_WIDTH=8: max value = 127+2*127+127-(-128) = 636 (needs 10+ bits)

**Division**:
- Divide by 8 using arithmetic right shift (>>>3) to preserve sign
- This rounds towards negative infinity for negative numbers

**Saturation Logic**:
- After division, check if result fits in DATA_WIDTH signed range
- Positive overflow: saturate to maximum positive value (2^(DATA_WIDTH-1) - 1)
- Negative overflow: saturate to minimum negative value (-2^(DATA_WIDTH-1))
- Check the top bits of the accumulator after accounting for division

### Filter Characteristics

This biquad configuration implements a low-pass filter with:
- Cutoff frequency dependent on sampling rate
- Second-order roll-off (12 dB/octave)
- Some feedback for improved response

## Constraints
- Use asynchronous reset with sensitivity to both clock and reset edges
- Internal arithmetic should use wider precision (at least DATA_WIDTH+4 bits)
- Final output must be saturated to DATA_WIDTH signed range
- Delay updates should use non-blocking assignments (<=)
- Ensure y[n-1] feedback uses the calculated output from current cycle, not old register value