# Prime Number Checker

## Problem Statement

Design a prime number checker that determines whether a given number is prime using trial division with a valid/ready handshake protocol.

### Module Interface
- **Module Name**: `prime_check`
- **Parameters**:
  - `DATA_WIDTH` (default: 16)
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input data is valid
  - `in_num[DATA_WIDTH-1:0]`: Number to check
  - `out_ready`: Downstream is ready to accept result
- **Outputs**:
  - `in_ready`: Ready to accept new input
  - `out_valid`: Output result is valid
  - `out_is_prime`: 1 if prime, 0 if not prime

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 16 | Bit width of input number |

### Valid/Ready Handshake Protocol

- Input transfer occurs when `in_valid && in_ready` on clock edge
- Output transfer occurs when `out_valid && out_ready` on clock edge
- Data must be stable while valid is high

### Functional Requirements

1. **Reset**: On reset, go to idle state, ready to accept input
2. **Input**: Accept a number when handshake occurs
3. **Compute**: Check if number is prime using trial division
4. **Output**: Assert `out_is_prime` = 1 if prime, 0 otherwise
5. **Edge Cases**:
   - 0 is not prime
   - 1 is not prime
   - 2 is prime (smallest prime)

### Trial Division Algorithm

```
is_prime(n):
  if n <= 1: return false
  if n <= 3: return true
  if n % 2 == 0: return false

  divisor = 3
  while divisor * divisor <= n:
    if n % divisor == 0: return false
    divisor = divisor + 2
  return true

Examples:
  is_prime(2)  = true
  is_prime(17) = true
  is_prime(18) = false
  is_prime(97) = true
```

### Example Waveform

```
          ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk       │   │   │   │   │   │   │   │   │   │   │   │   │   │
      ────┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └──
              ┌───────┐
in_valid  ────┘       └──────────────────────────────────────────
              ┌───────┐
in_ready  ────┘       └──────────────────────────────────────────
              ┌───────┐
in_num    ════│  17   │══════════════════════════════════════════
              └───────┘
                                              ┌───────┐
out_valid ────────────────────────────────────┘       └──────────
          ────────────────────────────────────────────┐   ┌──────
out_ready                                             └───┘
                                              ┌───────┐
out_is_prime ═════════════════════════════════│   1   │══════════
                                              └───────┘
```

### Hints

- Use a state machine: IDLE -> CHECK -> DONE
- Only check odd divisors (skip even numbers after 2)
- Stop checking when divisor^2 > n (optimization)
- Handle special cases (0, 1, 2, 3) immediately
- Use modulo operator to check divisibility

## Constraint
- Correctly implement valid/ready handshake on both input and output
- Must correctly identify all prime numbers
