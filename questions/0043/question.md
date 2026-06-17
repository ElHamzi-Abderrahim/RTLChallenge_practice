# Leading Zero Counter

## Problem Statement

Design a leading zero counter that counts the number of consecutive zeros from the most significant bit (MSB) of a binary input. This circuit is commonly used in floating-point units for normalization and in priority encoders.

### Module Interface

**Module Name**: `leading_zero_counter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `data_in` | Input | `[INPUT_WIDTH-1:0]` | Binary input word |
| `zero_count` | Output | `[COUNT_WIDTH-1:0]` | Number of leading zeros |
| `all_zero` | Output | 1 | Flag indicating all bits are zero |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `INPUT_WIDTH` | 8 | Width of input data |
| `COUNT_WIDTH` | 4 | Width of output count (ceil(log2(INPUT_WIDTH+1))) |

### Functional Requirements

1. **Leading Zero Count**: Count zeros from MSB until first '1' is encountered
2. **All Zero Detection**: Special flag when entire input is zero
3. **Priority Logic**: Use priority encoder principles for efficient implementation
4. **Range**: Output range from 0 to INPUT_WIDTH
5. **Combinational Logic**: Pure combinational implementation
6. **Edge Cases**: Handle all-zero and no-leading-zero cases correctly

### Example Operation

For INPUT_WIDTH = 8:
- Input: 8'b11111111 → zero_count: 4'b0000 (0), all_zero: 0
- Input: 8'b01111111 → zero_count: 4'b0001 (1), all_zero: 0
- Input: 8'b00111111 → zero_count: 4'b0010 (2), all_zero: 0
- Input: 8'b00000001 → zero_count: 4'b0111 (7), all_zero: 0
- Input: 8'b00000000 → zero_count: 4'b1000 (8), all_zero: 1

For INPUT_WIDTH = 16:
- Input: 16'b1000000000000000 → zero_count: 5'b00000 (0), all_zero: 0
- Input: 16'b0000100000000000 → zero_count: 5'b00100 (4), all_zero: 0
- Input: 16'b0000000000000000 → zero_count: 5'b10000 (16), all_zero: 1

### Implementation Approaches

**Method 1 - Priority Encoder**: Use standard priority encoder logic
**Method 2 - Tree Structure**: Hierarchical comparison and counting
**Method 3 - Case Statement**: Direct mapping for smaller widths

## Constraints
- COUNT_WIDTH = ceil(log2(INPUT_WIDTH + 1))
- When all_zero = 1, zero_count = INPUT_WIDTH
- When all_zero = 0, zero_count < INPUT_WIDTH
- Purely combinational design