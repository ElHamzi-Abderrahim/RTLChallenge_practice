# 1D Convolution Engine

## Problem Statement

Design a 1D convolution engine that computes the convolution of an input signal with a kernel using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `conv_1d`
- **Parameters**:
  - `DATA_WIDTH` (default: 8)
  - `KERNEL_SIZE` (default: 3)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start new convolution (pulse)
  - `kernel_valid`: Kernel data is valid
  - `kernel_data[DATA_WIDTH-1:0]`: Kernel coefficient
  - `in_valid`: Input signal data is valid
  - `in_data[DATA_WIDTH-1:0]`: Input signal value
  - `in_last`: Last input value
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `kernel_ready`: Ready to accept kernel
  - `in_ready`: Ready to accept input
  - `out_valid`: Output data is valid
  - `out_data[DATA_WIDTH*2+$clog2(KERNEL_SIZE)-1:0]`: Convolution result
  - `out_last`: Last output value

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit width of data values |
| `KERNEL_SIZE` | 3 | Number of kernel coefficients |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Start**: Load kernel, then process input
3. **Kernel Phase**: Load KERNEL_SIZE coefficients
4. **Convolution**: Compute output[i] = sum(input[i+k] * kernel[k])
5. **Output**: Valid convolution (no zero-padding)

### 1D Convolution

```
For kernel [k0, k1, k2] and signal [s0, s1, s2, s3, s4]:

output[0] = s0*k0 + s1*k1 + s2*k2
output[1] = s1*k0 + s2*k1 + s3*k2
output[2] = s2*k0 + s3*k1 + s4*k2

Number of outputs = input_length - kernel_size + 1
```

### Example

```
Kernel: [1, 2, 1]
Input:  [1, 2, 3, 4, 5]

Output[0] = 1*1 + 2*2 + 3*1 = 8
Output[1] = 2*1 + 3*2 + 4*1 = 12
Output[2] = 3*1 + 4*2 + 5*1 = 16

Output: [8, 12, 16]
```

### Hints

- First load all kernel coefficients
- Use a shift register for input window
- Multiply-accumulate for each output
- Output width must accommodate full precision

## Constraint
- Correctly implement valid/ready handshake
- Handle variable input lengths
