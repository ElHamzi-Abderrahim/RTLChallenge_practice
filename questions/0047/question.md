# Moving Average Filter

## Problem Statement

Design a configurable moving average filter that computes the average of the last N input samples. This is a common digital signal processing operation used for noise reduction and signal smoothing.

### Module Interface

**Module Name**: `moving_average`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Synchronous reset (active high) |
| `data_in` | Input | `[DATA_WIDTH-1:0]` | Input data sample (unsigned) |
| `data_out` | Output | `[DATA_WIDTH-1:0]` | Averaged output (unsigned) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit-width of input data |
| `WINDOW_SIZE` | 4 | Number of samples to average |

### Functional Requirements

1. **Sliding Window**: Maintain a window of the last WINDOW_SIZE input samples
2. **Average Calculation**: Compute the arithmetic mean of samples in the window
3. **Circular Buffer**: Efficiently implement the sliding window using a circular buffer
4. **Synchronous Reset**: Clear all internal state when reset is asserted
5. **Power-of-2 Window**: WINDOW_SIZE must be a power of 2 for efficient division

### Filter Operation

```
y[n] = (x[n] + x[n-1] + ... + x[n-WINDOW_SIZE+1]) / WINDOW_SIZE
```

Where:
- y[n] is the current output
- x[n] is the current input
- Division by WINDOW_SIZE is implemented as right shift

### Example Operation

For WINDOW_SIZE = 4 with input sequence [8, 16, 24, 32, 40]:
- Clock 0: window=[8,0,0,0], output = 8/4 = 2
- Clock 1: window=[16,8,0,0], output = 24/4 = 6
- Clock 2: window=[24,16,8,0], output = 48/4 = 12
- Clock 3: window=[32,24,16,8], output = 80/4 = 20
- Clock 4: window=[40,32,24,16], output = 112/4 = 28
output should be updated at the rising edge of clock.

## Constraints
WINDOW_SIZE must be a power of 2 (2, 4, 8, 16, etc.)