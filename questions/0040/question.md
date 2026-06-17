# CRC Calculator

## Problem Statement

Design a Cyclic Redundancy Check (CRC) calculator that computes CRC checksums for data integrity verification. CRC is widely used in communication protocols and storage systems to detect errors in transmitted or stored data.

### Module Interface

**Module Name**: `crc_calculator`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Active high asynchronous reset |
| `data_valid` | Input | 1 | Input data valid signal |
| `data_in` | Input | 8 | Input data byte |
| `start` | Input | 1 | Start new CRC calculation |
| `crc_out` | Output | `[CRC_WIDTH-1:0]` | Calculated CRC value |
| `crc_valid` | Output | 1 | CRC calculation complete |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `CRC_WIDTH` | 8 | Width of CRC (8, 16, or 32 bits) |
| `POLYNOMIAL` | 8'h07 | CRC polynomial (CRC-8-CCITT: x^8+x^2+x^1+1) |

### Functional Requirements

1. **Serial Processing**: Process input data byte by byte when data_valid is high
   - Process all 8 bits of each byte in a single clock cycle
   - Bit order: MSB first (bit 7 down to bit 0)
2. **Polynomial Division**: Implement CRC using polynomial long division
   - For each bit: if MSB of CRC XOR with data bit = 1, shift left and XOR with polynomial
   - Otherwise, just shift left
3. **Configurable**: Support different CRC widths and polynomials via parameters
4. **Reset/Start Function**:
   - reset or start signal initializes CRC to 0 and clears crc_valid
   - start signal allows restarting calculation without full reset
5. **Valid Output**:
   - crc_valid goes high after first data_valid
   - Remains high until reset or start
6. **Continuous Mode**: Can process multiple bytes for single CRC calculation
   - Each data_valid byte updates the running CRC
7. **Initial Value**: CRC starts at 0 (all zeros)

### Example Operation

For CRC-8 with polynomial 0x07 (x^8+x^2+x^1+1):
1. Assert start for one cycle to initialize
2. For each data byte, assert data_valid for one cycle with data_in
3. CRC is calculated bit-by-bit (MSB first) within that cycle
4. crc_valid goes high after first byte
5. Final CRC available on crc_out

Example sequence (processing "Hell" - 0x48, 0x65, 0x6C, 0x6C):
```
Cycle 0: start=1, data_valid=0 → CRC=0x00, crc_valid=0 (initialize)
Cycle 1: start=0, data_valid=0 → CRC=0x00, crc_valid=0 (idle after start)
Cycle 2: start=0, data_valid=1, data_in=0x48 ('H') → CRC=0xFF, crc_valid=1
Cycle 3: start=0, data_valid=0 → CRC=0xFF, crc_valid=1 (idle, CRC held)
Cycle 4: start=0, data_valid=1, data_in=0x65 ('e') → CRC=0xCF, crc_valid=1
Cycle 5: start=0, data_valid=0 → CRC=0xCF, crc_valid=1 (idle, CRC held)
Cycle 6: start=0, data_valid=1, data_in=0x6C ('l') → CRC=0x60, crc_valid=1
Cycle 7: start=0, data_valid=0 → CRC=0x60, crc_valid=1 (idle, CRC held)
Cycle 8: start=0, data_valid=1, data_in=0x6C ('l') → CRC=0x24, crc_valid=1 (final)
```

**Detailed calculation for first byte (0x48 = 'H'):**
```
Initial: CRC = 0x00 = 0b00000000
Step 1: XOR with input byte: 0x00 ^ 0x48 = 0x48 = 0b01001000
Step 2: Process 8 shifts with polynomial 0x07:
  - Iteration 0: MSB=0 → shift left only → 0b10010000 = 0x90
  - Iteration 1: MSB=1 → (0x90 << 1) ^ 0x07 = 0x20 ^ 0x07 = 0x27
  - Iteration 2: MSB=0 → shift left only → 0b01001110 = 0x4E
  - Iteration 3: MSB=0 → shift left only → 0b10011100 = 0x9C
  - Iteration 4: MSB=1 → (0x9C << 1) ^ 0x07 = 0x38 ^ 0x07 = 0x3F
  - Iteration 5: MSB=0 → shift left only → 0b01111110 = 0x7E
  - Iteration 6: MSB=0 → shift left only → 0b11111100 = 0xFC
  - Iteration 7: MSB=1 → (0xFC << 1) ^ 0x07 = 0xF8 ^ 0x07 = 0xFF
Result: CRC = 0xFF
```

**Important Note on Algorithm Variant:**
This implementation uses a **byte-at-a-time table-free CRC** algorithm that XORs each input byte with the current CRC state, then performs 8 shift operations within the CRC width. This is different from the classical textbook CRC which appends N zero bits to the message and performs polynomial division on the wider value.

For example, for input 0x48:
- **This algorithm**: XOR 0x48 into CRC, shift 8 times within 8 bits → Result: 0xFF
- **Classical CRC**: Compute (0x4800) ÷ 0x07 using full polynomial division → Result: 0x00

Both are valid CRC methods, but they produce different results. This byte-at-a-time variant is commonly used in software and hardware implementations because:
1. It doesn't require registers wider than the CRC width
2. It's more efficient for processing data byte-by-byte
3. It's equivalent to using a lookup table (which this implementation avoids for simplicity)

### Common CRC Polynomials

- **CRC-8-CCITT**: 0x07 (x^8+x^2+x^1+1)
- **CRC-16-CCITT**: 0x1021 (x^16+x^12+x^5+1)
- **CRC-32**: 0x04C11DB7 (Ethernet standard)

## Constraints
- Process all 8 bits of one byte per clock when data_valid is asserted
- Use MSB-first bit ordering (process bit 7 first, then 6, 5, ... 0)
- CRC accumulates across multiple bytes until reset/start
- Output remains stable between data_valid pulses
- Initial CRC value is 0 (all zeros)
- Use blocking assignments in the bit-processing loop for combinatorial logic
- Use non-blocking assignments for registered outputs

## Algorithm Details

For each input byte when data_valid is high:
1. Process bits from MSB to LSB (bit 7 down to bit 0)
2. For each bit i:
   - If crc_reg[CRC_WIDTH-1] XOR data_in[i] == 1:
     - crc_reg = (crc_reg << 1) XOR POLYNOMIAL
   - Else:
     - crc_reg = crc_reg << 1
3. Set crc_valid to 1 after processing

This implements standard MSB-first CRC calculation.