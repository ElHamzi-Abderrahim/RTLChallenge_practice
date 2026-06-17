# Decimation Filter

## Problem Statement

Design a decimation filter module that combines anti-aliasing filtering with downsampling to reduce the sampling rate of a digital signal. This is a critical component in multi-rate digital signal processing systems.

### Module Interface

**Module Name**: `decimation_filter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Synchronous reset (active high) |
| `data_in` | Input | `[DATA_WIDTH-1:0]` | Input data sample (signed) |
| `data_valid_in` | Input | 1 | Input data valid signal |
| `data_out` | Output | `[DATA_WIDTH-1:0]` | Decimated output (signed) |
| `data_valid_out` | Output | 1 | Output data valid signal |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Bit-width of input/output data |
| `DECIMATION_FACTOR` | 4 | Downsampling ratio |

### Functional Requirements

1. **Anti-Aliasing Filter**: 4-tap FIR low-pass filter before decimation
2. **Downsampling**: Output every Nth sample where N = DECIMATION_FACTOR
3. **Valid Signal Handling**: Proper control of data flow with valid signals
4. **Synchronous Reset**: Clear all internal state when reset is asserted
5. **Rate Control**: Output rate is input rate divided by DECIMATION_FACTOR

### Filter and Decimation Process

1. **FIR Filter**: Apply coefficients [1, 3, 3, 1] (normalized by 8)
2. **Sample Counter**: Count input samples modulo DECIMATION_FACTOR
3. **Output Control**: Generate output only when counter reaches DECIMATION_FACTOR-1

### Filter Equation

```
filtered[n] = (1*x[n] + 3*x[n-1] + 3*x[n-2] + 1*x[n-3]) / 8
y[k] = filtered[k*DECIMATION_FACTOR]
```

Where:
- filtered[n] is the anti-aliasing filtered signal
- y[k] is the decimated output
- k increments only when a decimated sample is output

### Example Operation

For DECIMATION_FACTOR = 4 with input sequence [8, 16, 24, 32, 40, 48, 56, 64]:

**Input samples**: 8, 16, 24, 32, 40, 48, 56, 64
**Filtered samples**: 1, 4, 9, 16, 21, 28, 35, 44
**Decimated output**: 16 (at n=3), 44 (at n=7)
**Valid output pulses**: at input samples 3, 7, 11, 15, ...

### Timing Diagram

```
clk:           __/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\
reset:         ‾‾‾\___________________________________________________________________
data_valid_in: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
data_in:       <     8       ><  16  ><  24  ><  32  ><  40  ><  48  ><  56  ><  64  
data_valid_out:__________________________________/‾‾‾\___________________________/‾‾‾\
data_out:      <               0                 ><             16               >< 44

```

## Constraints
DECIMATION_FACTOR must be ≥ 2 and should be a power of 2 for optimal performance