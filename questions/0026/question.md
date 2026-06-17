# 7-Segment Display Driver

## Problem Statement

Design a 7-segment display driver that converts BCD (Binary Coded Decimal) digits to the appropriate segment patterns for displaying decimal numbers. This is commonly used in digital clocks, calculators, and measurement instruments.

### Module Interface

**Module Name**: `seven_segment_driver`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `bcd_digit` | Input | 4 | BCD digit input (0-9) |
| `enable` | Input | 1 | Display enable signal |
| `segments` | Output | 7 | 7-segment output (a,b,c,d,e,f,g) |
| `digit_valid` | Output | 1 | Valid digit indicator |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `ACTIVE_HIGH` | 1 | 1 for active high, 0 for active low segments |

### Functional Requirements

1. **BCD to 7-Segment Mapping**: Convert BCD digits 0-9 to segment patterns
2. **Segment Order**: segments[6:0] = {g,f,e,d,c,b,a} (MSB to LSB)
3. **Enable Control**: When enable=0, all segments should be off
4. **Invalid Input**: For BCD inputs >9, display should be blank and digit_valid=0
5. **Active High/Low**: Support both common anode and common cathode displays
6. **Valid Output**: digit_valid indicates when displaying a valid digit (0-9)

### 7-Segment Layout
```
 aaa
f   b
 ggg
e   c
 ddd
```

### Segment Patterns (Active High)

| Digit | Pattern | Hex | Binary  | Segments On |
|-------|---------|-----|---------|-------------|
| 0     | 0x3F    | 0111111 | a,b,c,d,e,f |
| 1     | 0x06    | 0000110 | b,c |
| 2     | 0x5B    | 1011011 | a,b,g,e,d |
| 3     | 0x4F    | 1001111 | a,b,g,c,d |
| 4     | 0x66    | 1100110 | f,g,b,c |
| 5     | 0x6D    | 1101101 | a,f,g,c,d |
| 6     | 0x7D    | 1111101 | a,f,g,e,d,c |
| 7     | 0x07    | 0000111 | a,b,c |
| 8     | 0x7F    | 1111111 | a,b,c,d,e,f,g |
| 9     | 0x6F    | 1101111 | a,b,c,d,f,g |

## Constraints
- BCD input range: 0-15 (only 0-9 valid)
- For invalid inputs (10-15), all segments off and digit_valid=0
- When enable=0, all segments off regardless of input
- ACTIVE_HIGH parameter inverts all segment outputs when 0