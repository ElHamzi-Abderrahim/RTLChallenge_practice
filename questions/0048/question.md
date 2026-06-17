# Digital Differentiator

## Problem Statement

Design a digital differentiator module that computes the discrete-time derivative of the input signal. This filter calculates the difference between consecutive samples, effectively acting as a high-pass filter that emphasizes rapid changes in the signal.

### Module Interface

**Module Name**: `digital_differentiator`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Synchronous reset (active high) |
| `data_in` | Input | `[DATA_WIDTH-1:0]` | Input data sample (signed) |
| `data_out` | Output | `[DATA_WIDTH:0]` | Differentiated output (signed, with extra bit for range) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit-width of input data |

### Functional Requirements

1. **Difference Operation**: Compute y[n] = x[n] - x[n-1]
2. **Delay Element**: Store the previous input sample
3. **Signed Arithmetic**: Handle signed input and output data
4. **Synchronous Reset**: Clear all internal state when reset is asserted
5. **Range Extension**: Output has one extra bit to handle overflow from subtraction

### Difference Equation

```
y[n] = x[n] - x[n-1]
```

Where:
- y[n] is the current output (difference)
- x[n] is the current input
- x[n-1] is the previous input sample

### Example Operation

For DATA_WIDTH = 8 with input sequence [10, 20, 15, 25, 30]:
- Clock 0: x[0]=10, x[-1]=0, output = 10 - 0 = 10
- Clock 1: x[1]=20, x[0]=10, output = 20 - 10 = 10
- Clock 2: x[2]=15, x[1]=20, output = 15 - 20 = -5
- Clock 3: x[3]=25, x[2]=15, output = 25 - 15 = 10
- Clock 4: x[4]=30, x[3]=25, output = 30 - 25 = 5

data_out should be updated at the rising edge of clock.

### Use Cases

1. **Edge Detection**: Emphasizes rapid transitions in signals
2. **High-Pass Filtering**: Removes DC and low-frequency components
3. **Rate of Change**: Measures how quickly a signal is changing

## Constraints
NA