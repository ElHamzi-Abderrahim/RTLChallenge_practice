# Priority Encoder

## Problem Statement

Priority encoders are fundamental components in digital systems, commonly used in interrupt controllers, arbitration logic, resource allocation, exception handling, and finding the first set bit in data structures. These encoders scan an input vector and output the binary position of the highest-priority (or lowest-priority) active bit, making them essential for prioritizing multiple concurrent requests.

Design a 4-bit priority encoder that identifies the position of the highest-priority active bit in the input vector. The encoder should use LSB-first priority (bit 0 has highest priority) and provide a valid signal indicating when at least one input bit is active.

### Module Interface

**Module Name**: `priority_encoder`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `data_i` | Input | 4 | Input data vector to encode |
| `valid_o` | Output | 1 | Valid flag (at least one bit in data_i is high) |
| `pos_o` | Output | 2 | Binary position of highest-priority active bit |

### Functional Requirements

1. **Priority Selection**: Identify the position of the highest-priority active bit
2. **LSB Priority**: Bit 0 has highest priority, bit 3 has lowest priority
3. **Valid Signal**: Assert `valid_o` when any input bit is high
4. **Binary Output**: Output the 2-bit binary position of the selected bit
5. **Combinational Logic**: Pure combinational implementation (no clock required)

### Example Operation

**Priority Encoding Behavior:**
- When multiple bits are high, select the lowest index (highest priority)
- `valid_o = 0` when all input bits are zero
- `pos_o` indicates the binary position of the selected bit

**Truth Table:**

| data_i | valid_o | pos_o | Description |
|--------|---------|-------|-------------|
| 0000   | 0       | XX    | No active bits |
| 0001   | 1       | 00    | Bit 0 active (highest priority) |
| 0010   | 1       | 01    | Bit 1 active |
| 0011   | 1       | 00    | Bit 0 has priority over bit 1 |
| 0100   | 1       | 10    | Bit 2 active |
| 0101   | 1       | 00    | Bit 0 has highest priority |
| 0110   | 1       | 01    | Bit 1 has priority over bit 2 |
| 0111   | 1       | 00    | Bit 0 has highest priority |
| 1000   | 1       | 11    | Bit 3 active (lowest priority) |
| 1001   | 1       | 00    | Bit 0 has priority |
| 1010   | 1       | 01    | Bit 1 has priority |
| 1011   | 1       | 00    | Bit 0 has priority |
| 1100   | 1       | 10    | Bit 2 has priority |
| 1101   | 1       | 00    | Bit 0 has priority |
| 1110   | 1       | 01    | Bit 1 has priority |
| 1111   | 1       | 00    | Bit 0 has highest priority |

**Example scenarios:**
```
data_i = 4'b0000 → valid_o = 0, pos_o = 2'bXX
data_i = 4'b1000 → valid_o = 1, pos_o = 2'b11
data_i = 4'b0100 → valid_o = 1, pos_o = 2'b10
data_i = 4'b1010 → valid_o = 1, pos_o = 2'b01 (bit 1 is highest priority active)
data_i = 4'b1111 → valid_o = 1, pos_o = 2'b00 (bit 0 is highest priority)
```

## Constraints
- When `data_i = 4'b0000`, `pos_o` is don't-care (can be any value)
- Priority is fixed: bit 0 > bit 1 > bit 2 > bit 3
