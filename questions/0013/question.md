# 4-bit Linear Feedback Shift Register (LFSR)

## Problem Statement

Linear Feedback Shift Registers (LFSRs) are fundamental building blocks in digital systems, widely used for pseudo-random number generation, test pattern generation, scrambling/descrambling, CRC calculation, and spread spectrum communications.

Design a 4-bit Linear Feedback Shift Register (LFSR) that generates a pseudo-random sequence using polynomial feedback. The LFSR should produce a maximal-length sequence of 15 unique states before repeating, making it suitable for applications requiring high-quality pseudo-random sequences with excellent statistical properties.

### Module Interface

**Module Name**: `lfsr`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `lfsr_o` | Output | 4 | 4-bit LFSR output |

### Functional Requirements

1. **Pseudo-Random Generation**: Generate pseudo-random sequence using feedback polynomial
2. **Maximal Length**: Produce 15 unique states (2^4 - 1) before repeating
3. **Feedback Polynomial**: Use polynomial x^4 + x^3 + 1 (taps at positions 3 and 1)
4. **Asynchronous Reset**: Reset to seed value 4'hE (1110)
5. **Edge Triggered**: Register updates on positive clock edge

### Example Operation

**Polynomial Implementation:** The characteristic polynomial x^4 + x^3 + 1 uses tap positions at bit 3 and bit 1, with feedback = `lfsr[3] ^ lfsr[1]` and next state = `{lfsr[2:0], lfsr[3] ^ lfsr[1]}`.

**LFSR Behavior:**
- Reset State: `lfsr_o = 4'hE` (1110) - Non-zero seed value
- Shift Operation: `lfsr = {lfsr[2:0], feedback}` (shift left, feedback at LSB)
- Sequence Length: 15 states (excludes all-zero state)

Starting from reset value 1110 (4'hE):

| Clock | lfsr[3:0] | Binary | Feedback (bit3^bit1) |
|-------|-----------|--------|----------------------|
| Reset | 1110      | 4'hE   | -                    |
| 1     | 1101      | 4'hD   | 1^1=0               |
| 2     | 1011      | 4'hB   | 1^0=1               |
| 3     | 0111      | 4'h7   | 0^1=1               |
| 4     | 1111      | 4'hF   | 0^1=1               |
| 5     | 1110      | 4'hE   | 1^1=0               |

Complete sequence: 1110 → 1101 → 1011 → 0111 → 1111 → 1110 (repeats after 15 states)

## Constraints
NA