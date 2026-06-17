# ARP Request Detector

## Problem Statement

Design a module that detects ARP (Address Resolution Protocol) requests and extracts key fields using valid/ready handshake protocol.

### ARP Packet Structure (after Ethernet header)

```
Offset  Field               Size    Value for Request
------------------------------------------------------
0-1     Hardware Type       2       0x0001 (Ethernet)
2-3     Protocol Type       2       0x0800 (IPv4)
4       Hardware Addr Len   1       0x06
5       Protocol Addr Len   1       0x04
6-7     Operation           2       0x0001 (Request)
8-13    Sender MAC          6
14-17   Sender IP           4
18-23   Target MAC          6       (00:00:00:00:00:00 for request)
24-27   Target IP           4       (IP being queried)
------------------------------------------------------
Total: 28 bytes
```

### Module Interface
- **Module Name**: `arp_detector`
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input byte is valid
  - `in_data[7:0]`: Input byte
  - `in_sof`: Start of ARP packet
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_is_request`: 1 if ARP request, 0 otherwise
  - `out_sender_ip[31:0]`: Sender's IP address
  - `out_target_ip[31:0]`: Target IP being queried

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Parse**: Collect 28 bytes of ARP packet
3. **Validate**: Check if operation is request (0x0001)
4. **Output**: Report sender and target IPs

### Example

```
ARP Request: "Who has 192.168.1.1? Tell 192.168.1.100"

Bytes: 00 01 08 00 06 04 00 01    (HW/Proto type, lengths, op)
       AA BB CC DD EE FF          (Sender MAC)
       C0 A8 01 64                 (Sender IP: 192.168.1.100)
       00 00 00 00 00 00          (Target MAC: unknown)
       C0 A8 01 01                 (Target IP: 192.168.1.1)

Output:
  is_request = 1
  sender_ip  = 32'hC0A80164 (192.168.1.100)
  target_ip  = 32'hC0A80101 (192.168.1.1)
```

### Design Template

```verilog
module arp_detector (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_sof,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_is_request,
    output wire [31:0] out_sender_ip,
    output wire [31:0] out_target_ip
);

    // Your implementation here...

endmodule
```

### Hints

- Track byte position with counter
- Extract operation at bytes 6-7
- Sender IP at bytes 14-17
- Target IP at bytes 24-27
- IPs are big-endian (network byte order)

## Constraint
- Correctly implement valid/ready handshake
- Only assert is_request for operation code 0x0001
