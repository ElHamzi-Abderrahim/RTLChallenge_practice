# MAC Address Filter

## Problem Statement

Design a module that filters Ethernet frames based on destination MAC address. The module accepts frames and outputs whether the frame should be accepted based on matching the configured MAC address, broadcast address, or multicast.

### Module Interface
- **Module Name**: `mac_filter`
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `cfg_mac[47:0]`: Configured local MAC address
  - `cfg_promisc`: Promiscuous mode enable
  - `in_valid`: Input is valid
  - `in_dst_mac[47:0]`: Destination MAC from frame
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Output result is valid
  - `out_accept`: 1 if frame should be accepted
  - `out_reason[2:0]`: Reason for acceptance

### Accept Reasons

| Value | Reason |
|-------|--------|
| 0     | No match (reject) |
| 1     | Unicast match (matches cfg_mac) |
| 2     | Broadcast (FF:FF:FF:FF:FF:FF) |
| 3     | Multicast (bit 0 of first byte = 1) |
| 4     | Promiscuous mode |

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Unicast**: Accept if dst_mac matches cfg_mac
3. **Broadcast**: Accept if dst_mac is FF:FF:FF:FF:FF:FF
4. **Multicast**: Accept if LSB of first byte is 1
5. **Promiscuous**: Accept all frames if cfg_promisc is set

### Example

```
cfg_mac = 00:1A:2B:3C:4D:5E

Frame 1: dst_mac = 00:1A:2B:3C:4D:5E
  -> accept=1, reason=1 (unicast match)

Frame 2: dst_mac = FF:FF:FF:FF:FF:FF
  -> accept=1, reason=2 (broadcast)

Frame 3: dst_mac = 01:00:5E:00:00:01
  -> accept=1, reason=3 (multicast, LSB=1)

Frame 4: dst_mac = 00:11:22:33:44:55
  -> accept=0, reason=0 (no match)
```

### Design Template

```verilog
module mac_filter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [47:0] cfg_mac,
    input  wire        cfg_promisc,
    input  wire        in_valid,
    input  wire [47:0] in_dst_mac,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_accept,
    output wire [2:0]  out_reason
);

    // Your implementation here...

endmodule
```

### Hints

- Check broadcast first (all 1s)
- Multicast check: in_dst_mac[40] == 1 (LSB of first byte)
- Priority: Promiscuous > Broadcast > Multicast > Unicast
- Can be combinational or registered

## Constraint
- Correctly implement valid/ready handshake
- Priority order must be followed for reason codes
