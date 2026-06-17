# Packet Length Validator

## Problem Statement

Design a module that validates packet lengths by comparing the actual byte count with the length field from the IP header using valid/ready handshake protocol.

### Module Interface
- **Module Name**: `pkt_len_validator`
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `start`: Start validation (pulse)
  - `in_valid`: Input byte is valid
  - `in_data[7:0]`: Input byte
  - `in_last`: Last byte indicator
  - `hdr_total_len[15:0]`: Total length from IP header
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_len_ok`: 1 if lengths match
  - `out_actual_len[15:0]`: Actual byte count

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Count**: Count bytes as they arrive
3. **Compare**: Compare count with header length
4. **Output**: Report match status and actual length

### Example

```
hdr_total_len = 0x0014 (20 bytes)
Actual bytes received: 20

Output:
  len_ok = 1
  actual_len = 0x0014
```

### Design Template

```verilog
module pkt_len_validator (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_last,
    input  wire [15:0] hdr_total_len,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_len_ok,
    output wire [15:0] out_actual_len
);

    // Your implementation here...

endmodule
```

### Hints

- Use a counter to track actual bytes
- Compare on in_last assertion
- Header length includes IP header itself

## Constraint
- Correctly implement valid/ready handshake
- Handle packets up to 65535 bytes
