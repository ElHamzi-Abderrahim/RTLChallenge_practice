# Ethernet Header Parser

## Problem Statement

Design a module that parses an Ethernet frame header and extracts key fields using valid/ready handshake protocol. The module receives bytes sequentially and outputs the parsed header fields.

### Ethernet Frame Header Structure

```
Byte Offset   Field                Size
-----------------------------------------
0-5           Destination MAC      6 bytes
6-11          Source MAC           6 bytes
12-13         EtherType            2 bytes
-----------------------------------------
Total Header: 14 bytes
```

### Module Interface
- **Module Name**: `eth_header_parser`
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input byte is valid
  - `in_data[7:0]`: Input byte (sequential)
  - `in_sof`: Start of frame indicator
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Parsed header is valid
  - `out_dst_mac[47:0]`: Destination MAC address
  - `out_src_mac[47:0]`: Source MAC address
  - `out_ethertype[15:0]`: EtherType field

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **SOF**: When `in_sof` asserts, start parsing new frame
3. **Parse**: Collect 14 bytes sequentially
4. **Output**: After 14 bytes received, output parsed fields

### Example

```
Input bytes (hex):
  FF FF FF FF FF FF    (Dst MAC - broadcast)
  00 1A 2B 3C 4D 5E    (Src MAC)
  08 00                (EtherType - IPv4)

Output:
  dst_mac   = 48'hFFFFFFFFFFFF
  src_mac   = 48'h001A2B3C4D5E
  ethertype = 16'h0800 (IPv4)
```

### Common EtherType Values

| Value  | Protocol |
|--------|----------|
| 0x0800 | IPv4     |
| 0x0806 | ARP      |
| 0x86DD | IPv6     |
| 0x8100 | VLAN     |

### Design Template

```verilog
module eth_header_parser (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [7:0]  in_data,
    input  wire        in_sof,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire [47:0] out_dst_mac,
    output wire [47:0] out_src_mac,
    output wire [15:0] out_ethertype
);

    // Your implementation here...

endmodule
```

### Hints

- Use a byte counter to track position in header
- Shift in bytes to build multi-byte fields
- MAC addresses are transmitted MSB first
- EtherType is big-endian (network byte order)

## Constraint
- Correctly implement valid/ready handshake
- Handle back-to-back frames (new SOF after output)
