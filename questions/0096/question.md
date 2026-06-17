# VLAN Tag Detector

## Problem Statement

Design a module that detects and extracts VLAN (802.1Q) tag information from Ethernet frames using valid/ready handshake protocol.

### VLAN Tag Structure

```
Standard Ethernet:   [Dst MAC][Src MAC][EtherType][Payload]

VLAN Tagged:         [Dst MAC][Src MAC][0x8100][TCI][EtherType][Payload]
                                         ^     ^
                              TPID (Tag Protocol ID)
                                          |
                              TCI (Tag Control Information)

TCI Format (16 bits):
  Bits 15-13: PCP (Priority Code Point) - 3 bits
  Bit 12:     DEI (Drop Eligible Indicator) - 1 bit
  Bits 11-0:  VID (VLAN ID) - 12 bits
```

### Module Interface
- **Module Name**: `vlan_detector`
- **Inputs**:
  - `clk`: Clock signal
  - `rst_n`: Active-low reset
  - `in_valid`: Input is valid
  - `in_ethertype[15:0]`: EtherType field
  - `in_tci[15:0]`: TCI field (valid if tagged)
  - `out_ready`: Downstream is ready
- **Outputs**:
  - `in_ready`: Ready to accept input
  - `out_valid`: Result is valid
  - `out_is_tagged`: 1 if VLAN tagged
  - `out_pcp[2:0]`: Priority Code Point
  - `out_dei`: Drop Eligible Indicator
  - `out_vid[11:0]`: VLAN ID

### Functional Requirements

1. **Reset**: On reset, go to idle state
2. **Detect**: Check if EtherType is 0x8100 (VLAN)
3. **Extract**: Parse TCI fields if tagged
4. **Output**: Report tag status and fields

### Example

```
Frame with VLAN tag:
  EtherType = 0x8100 (VLAN)
  TCI = 0xA064
        PCP = 101 (5)
        DEI = 0
        VID = 0x064 (100)

Output:
  is_tagged = 1
  pcp = 3'd5
  dei = 0
  vid = 12'd100
```

### Design Template

```verilog
module vlan_detector (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        in_valid,
    input  wire [15:0] in_ethertype,
    input  wire [15:0] in_tci,
    input  wire        out_ready,
    output wire        in_ready,
    output wire        out_valid,
    output wire        out_is_tagged,
    output wire [2:0]  out_pcp,
    output wire        out_dei,
    output wire [11:0] out_vid
);

    // Your implementation here...

endmodule
```

### Hints

- VLAN TPID is 0x8100
- TCI[15:13] = PCP, TCI[12] = DEI, TCI[11:0] = VID
- If not tagged, output fields can be 0

## Constraint
- Correctly implement valid/ready handshake
- Only report as tagged if EtherType is 0x8100
