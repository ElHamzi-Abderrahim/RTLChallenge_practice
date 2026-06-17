# 4-Tap FIR Filter

## Problem Statement

Design a 4-tap Finite Impulse Response (FIR) filter module that implements a basic low-pass filtering operation. The filter should compute the weighted sum of the current input sample and the previous 3 samples using fixed coefficients.

### Module Interface

**Module Name**: `fir_filter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Synchronous reset (active high) |
| `data_in` | Input | `[DATA_WIDTH-1:0]` | Input data sample (signed) |
| `data_out` | Output | `[DATA_WIDTH+1:0]` | Filtered output (signed, with extra bits for accumulation) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit-width of input data |

### Functional Requirements

1. **4-Tap Filter**: Implement h[0] = 1, h[1] = 2, h[2] = 2, h[3] = 1 (normalized by 8)
2. **Shift Register**: Maintain a 4-sample delay line for input samples
3. **MAC Operation**: Multiply-accumulate operation for each tap
4. **Synchronous Reset**: Clear all internal registers when reset is asserted
5. **Signed Arithmetic**: Handle signed input and output data

### Filter Equation

```
y[n] = (1*x[n] + 2*x[n-1] + 2*x[n-2] + 1*x[n-3]) / 8
```

Where:
- y[n] is the current output
- x[n] is the current input
- x[n-1], x[n-2], x[n-3] are previous input samples

### Example Operation

For DATA_WIDTH = 8 with input sequence [16, 32, 48, 64]:
- Clock 0: x[0]=16, output = (1*16)/8 = 2
- Clock 1: x[1]=32, output = (1*32 + 2*16)/8 = 8
- Clock 2: x[2]=48, output = (1*48 + 2*32 + 2*16)/8 = 16
- Clock 3: x[3]=64, output = (1*64 + 2*48 + 2*32 + 1*16)/8 = 26

output should be updated at the rising edge of clock.

## Constraints
NA