# Stopwatch Timer

## Problem Statement

Design a digital stopwatch timer that can measure elapsed time with start, stop, and reset functionality. The stopwatch should display time in minutes, seconds, and tenths of seconds, making it practical for timing applications.

### Module Interface

**Module Name**: `stopwatch_timer`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | System clock |
| `reset` | Input | 1 | Active high asynchronous reset |
| `start` | Input | 1 | Start signal |
| `clear` | Input | 1 | Clear/reset timer signal (pulse) |
| `minutes` | Output | 6 | Minutes (0-59) |
| `seconds` | Output | 6 | Seconds (0-59) |
| `tenths` | Output | 4 | Tenths of seconds (0-9) |
| `running` | Output | 1 | Timer running indicator |

**Note**: The module assumes a 100Hz clock input (10ms period).

### Functional Requirements

1. **Time Display**: Show elapsed time in MM:SS.T format (59:59.9 maximum)
2. **Start/Stop Control**: Toggle between running and stopped states
3. **Clear Function**: Reset timer to 00:00.0 at any time
4. **Rollover**: Timer rolls over to 00:00.0 after reaching 59:59.9
5. **Running Indicator**: Signal shows when timer is actively counting
6. **Pulse Inputs**: start_stop and clear are single-cycle pulses
7. **Accurate Timing**: Count 10 clock cycles per tenth of a second

### Example Operation

With 100Hz clock (10ms period):
- Each tenth of a second = 10 clock cycles
- Timer counts: 00:00.0 → 00:00.1 → ... → 00:01.0 → ...
- start_stop pulse toggles running state
- clear pulse resets to 00:00.0 regardless of running state

### Timing Diagram

Start to stop 
```
clk:         __/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___///‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\
reset:       ‾‾‾\______________________________//_____________________________________________
start_stop:  ______/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\________________________
clear:       __________________________________//_____________________________________________
running:     __________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\________________________
minutes:     <               00                //<               00                          >
seconds:     <               00                //<  00   ><  01  ><          01              >
tenths:      <    00   ><  01  ><  02  ><  03  //<  09   ><  00  ><          02              >
```

(Continueed) from stop to start and clear
```
clk:         __/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___///‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\
reset:       __________________________________//_____________________________________________
start_stop:  ______/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
clear:       __________________________________//____________________/‾‾‾‾‾‾‾‾\_______________
running:     __________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾//‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
minutes:     <               00                //<  00   ><  01  ><  01  ><  00  ><    00    
seconds:     <               01                //<  59   ><  00  ><  00  ><  00  ><    00     
tenths:      <    02   ><  03  ><  04  ><  05  //<  09   ><  00  ><  01  ><  00  ><  01  >< 02
```

## Constraints
- Maximum time display: 59 minutes, 59 seconds, 9 tenths
- All outputs should be in binary (not BCD)
- Inputs are edge-triggered pulses
- Timer continues from where it stopped when restarted