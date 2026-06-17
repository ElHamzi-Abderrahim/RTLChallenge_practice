# IPv4 Header Checksum

## Problem Statement

Design a module that calculates and verifies the IPv4 header checksum using valid/ready handshake protocol. The checksum is the 16-bit one's complement of the one's complement sum of all 16-bit words in the header.

### IPv4 Header Checksum Algorithm

```
1. Set checksum field to 0
2. Sum all 16-bit words in header
3. Add carry bits back to result (fold)
4. Take one's complement of result
```

### Module Interface
- **Module Name**: `ipv4_checksum`
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start calculation (pulse)
  - `in_valid`: Input word is valid
  - `in_data[15:0]`: 16-bit header word
  - `in_last`: Last word indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_checksum[15:0]`: Calculated checksum
  - `out_valid_hdr`: 1 if checksum verifies (sum = 0xFFFF)

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Calculate**: Sum all 16-bit words with carry folding
3. **Verify**: For received packets, sum should equal 0xFFFF
4. **Generate**: For new packets, output is the checksum to insert

### Example

```
Header words: 4500, 0034, 1234, 4000, 4006, 0000,
              C0A8, 0001, C0A8, 0002
              (checksum field = 0000 for calculation)

Sum:   4500 + 0034 + 1234 + 4000 + 4006 + 0000 +
       C0A8 + 0001 + C0A8 + 0002 = 2_6C5E

Fold:  6C5E + 0002 = 6C60

Checksum: ~6C60 = 939F
```

### Design Template

```verilog
module ipv4_checksum (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        in_valid,
    input  wire [15:0] in_data,
    input  wire        in_last,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire [15:0] out_checksum,
    output wire        out_valid_hdr
);

    // Your implementation here...

endmodule
```

### Hints

- Use 17+ bit accumulator to capture carries
- Fold carries: sum[15:0] + sum[31:16]
- May need multiple fold iterations
- Valid header check: final sum == 0xFFFF

## Constraint
- Correctly implement valid/ready handshake
- Handle variable header lengths (with options)
