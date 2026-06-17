# Population Counter

## Problem Statement

Design a population counter (also known as a bit counter or Hamming weight calculator) that counts the number of '1' bits in a binary input word. This is a fundamental operation used in error correction, cryptography, and digital signal processing.

### Module Interface

**Module Name**: `population_counter`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `data_in` | Input | `[INPUT_WIDTH-1:0]` | Binary input word |
| `count_out` | Output | `[COUNT_WIDTH-1:0]` | Number of '1' bits in input |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `INPUT_WIDTH` | 8 | Width of input data |
| `COUNT_WIDTH` | 4 | Width of output count (ceil(log2(INPUT_WIDTH+1))) |

### Functional Requirements

1. **Bit Counting**: Count the total number of '1' bits in the input
2. **Parameterizable Width**: Support different input widths
3. **Optimal Output Width**: COUNT_WIDTH should accommodate maximum possible count
4. **Combinational Logic**: Pure combinational implementation
5. **Fast Operation**: Use efficient counting architecture (tree structure preferred)
6. **Range**: Output range from 0 to INPUT_WIDTH

### Example Operation

For INPUT_WIDTH = 8:
- Input: 8'b00000000 → Output: 4'b0000 (0 ones)
- Input: 8'b10101010 → Output: 4'b0100 (4 ones)
- Input: 8'b11111111 → Output: 4'b1000 (8 ones)
- Input: 8'b11010110 → Output: 4'b0101 (5 ones)

For INPUT_WIDTH = 16:
- Input: 16'b1010101010101010 → Output: 5'b01000 (8 ones)
- Input: 16'b1111000011110000 → Output: 5'b01000 (8 ones)

### Implementation Hints

**Method 1 - Tree Structure**: Use hierarchical addition of bit pairs
**Method 2 - Wallace Tree**: Parallel counting with carry-save adders
**Method 3 - Lookup Table**: For smaller widths, use ROM/LUT

## Constraints
- Must handle all possible input combinations
- COUNT_WIDTH = ceil(log2(INPUT_WIDTH + 1))
- Purely combinational design
- Should be synthesizable and efficient