# UART Transmitter

## Problem Statement

Design a UART (Universal Asynchronous Receiver-Transmitter) transmitter module that converts parallel data into serial format for transmission. The UART protocol is widely used for serial communication between devices.

### Module Interface

**Module Name**: `uart_transmitter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Active high synchronous reset |
| `tx_start` | Input | 1 | Start transmission signal (pulse) |
| `tx_data` | Input | 8 | Data byte to transmit |
| `tx_out` | Output | 1 | UART serial output |
| `tx_busy` | Output | 1 | Transmission busy flag (high during transmission) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `CLK_FREQ` | 50000000 | System clock frequency in Hz |
| `BAUD_RATE` | 9600 | UART baud rate in bits per second |

### Functional Requirements

1. **UART Frame Format**: Start bit (0) + 8 data bits (LSB first) + stop bit (1)
2. **Baud Rate Generation**: Each bit period = CLK_FREQ / BAUD_RATE clock cycles
3. **State Machine**: Use a finite state machine with states for:
   - IDLE: Wait for tx_start signal
   - START_BIT: Send start bit (0)
   - DATA_BITS: Send 8 data bits LSB first
   - STOP_BIT: Send stop bit (1)
4. **Busy Signal**: Assert tx_busy during transmission, deassert when idle
5. **Idle State**: tx_out should be high (1) when not transmitting
6. **Start Control**: Begin transmission when tx_start is pulsed high
7. **No Overrun**: Ignore tx_start when tx_busy is asserted

### Example Operation

For transmitting 8'h55 (01010101 binary):
```
Cycle: IDLE -> START -> DATA[0] -> DATA[1] -> ... -> DATA[7] -> STOP -> IDLE
Bits:   1      0        1          0                    1         1      1
        ^      ^        ^
      idle   start   LSB first
```

### Timing Diagram

```
clk      :  _/‾\_/‾\_/‾\_/‾\_/‾\_...
tx_start :  __/‾‾‾\_______________...
tx_busy  :  ____/‾‾‾‾‾‾‾‾‾‾‾‾\__...
tx_out   :  ‾‾‾‾\____/‾\_/‾\_/‾‾...
```

## Constraints

- Data is transmitted LSB (Least Significant Bit) first
- Start bit = 0, Stop bit = 1
- Idle line state = 1
- All operations synchronous to system clock
- Reset is synchronous
- Each bit period lasts exactly CLKS_PER_BIT clock cycles
- tx_busy is high during transmission and low when idle

## Implementation Hints

- Use a counter to track clock cycles within each bit period
- Use a bit index counter (0-7) to track which data bit is being transmitted
- Store tx_data in a register when tx_start is asserted
- The output should maintain its value for the entire bit period
