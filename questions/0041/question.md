# SECDED 13-8 Hamming Code Encoder

## Problem Statement

Design a SECDED (Single Error Correction, Double Error Detection) Hamming code encoder for 8-bit data. SECDED codes extend standard Hamming codes with an additional overall parity bit, enabling detection of double-bit errors while maintaining single-bit error correction capability.

### Module Interface

**Module Name**: `hamming_encoder`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `data_in` | Input | `[7:0]` | Original 8 data bits |
| `encoded_out` | Output | `[12:0]` | Encoded 13-bit word with parity bits |
| `parity_bits` | Output | `[4:0]` | Generated 5 parity bits (P4, P3, P2, P1, P0) |

**Note**: This module implements SECDED Hamming(13,8) code specifically and is not parametrizable.

### Functional Requirements

1. **SECDED Hamming(13,8) Code**: Implement SECDED Hamming code for 8 data bits
2. **Hamming Parity Bits**: Place parity bits P0, P1, P2, P3 at positions 1, 2, 4, 8 (powers of 2)
3. **Overall Parity Bit**: P4 provides overall parity for double error detection
4. **Data Bit Placement**: Place data bits at remaining positions
5. **Even Parity**: Use even parity for all parity calculations
6. **Combinational Logic**: Pure combinational implementation

### SECDED Hamming(13,8) Code Structure

```
Position: 12 11 10  9  8  7  6  5  4  3  2  1  0
Bit Type: P4 D7 D6 D5 D4 P3 D3 D2 D1 P2 D0 P1 P0
```

Where:
- D7-D0 = 8 data bits
- P3, P2, P1, P0 = Hamming parity bits (at power-of-2 positions)
- P4 = Overall parity bit for SECDED

### Parity Bit Calculations

Using 0-based indexing for bit positions:

- **P0 (position 0)**: Covers positions with bit 0 set in binary representation
  - Covers positions: 0, 2, 4, 6, 8, 10
  - P0 = D0 ⊕ D1 ⊕ D3 ⊕ D4 ⊕ D6

- **P1 (position 1)**: Covers positions with bit 1 set in binary representation
  - Covers positions: 1, 2, 5, 6, 9, 10
  - P1 = D0 ⊕ D2 ⊕ D3 ⊕ D5 ⊕ D6

- **P2 (position 3)**: Covers positions with bit 2 set in binary representation
  - Covers positions: 3, 4, 5, 6, 11
  - P2 = D1 ⊕ D2 ⊕ D3 ⊕ D7

- **P3 (position 7)**: Covers positions with bit 3 set in binary representation
  - Covers positions: 7, 8, 9, 10, 11
  - P3 = D4 ⊕ D5 ⊕ D6 ⊕ D7

- **P4 (position 12)**: Overall parity bit
  - P4 = P0 ⊕ P1 ⊕ D0 ⊕ P2 ⊕ D1 ⊕ D2 ⊕ D3 ⊕ P3 ⊕ D4 ⊕ D5 ⊕ D6 ⊕ D7

### Example Operation

For data_in = 8'b10110011:
- D0=1, D1=1, D2=0, D3=0, D4=1, D5=1, D6=0, D7=1
- P0 = 1 ⊕ 1 ⊕ 0 ⊕ 1 ⊕ 0 = 1
- P1 = 1 ⊕ 0 ⊕ 0 ⊕ 1 ⊕ 0 = 0
- P2 = 1 ⊕ 0 ⊕ 0 ⊕ 1 = 0
- P3 = 1 ⊕ 1 ⊕ 0 ⊕ 1 = 1
- P4 = 1 ⊕ 0 ⊕ 1 ⊕ 0 ⊕ 1 ⊕ 0 ⊕ 0 ⊕ 1 ⊕ 1 ⊕ 1 ⊕ 0 ⊕ 1 = 1
- encoded_out = 13'b1101101100101

## Constraints
- Use even parity for all parity calculations
- Parity bits P0-P3 at power-of-2 positions (1, 2, 4, 8 in 1-based indexing)
- Overall parity bit P4 at MSB position for SECDED capability
- Purely combinational design
- SECDED enables: Single error correction OR double error detection (not both simultaneously)