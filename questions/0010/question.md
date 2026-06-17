# Simple ALU (Arithmetic Logic Unit)

## Problem Statement

Design a simple 8-bit Arithmetic Logic Unit (ALU) that performs basic arithmetic and logical operations on two input operands. The ALU should support 8 different operations controlled by a 3-bit operation code.

### Module Interface

**Module Name**: `simple_alu`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `a_i` | Input | 8 | First operand |
| `b_i` | Input | 8 | Second operand |
| `op_i` | Input | 3 | Operation code |
| `alu_o` | Output | 8 | ALU result |

### Functional Requirements

1. **Combinational Logic**: Pure combinational implementation (no clock required)
2. **8-bit Operations**: All operations work on 8-bit unsigned values
3. **8 Operations**: Support for 8 different arithmetic and logical operations
4. **Operation Selection**: Use 3-bit operation code to select function

### Operation Encoding

| Operation Code | Operation | Description |
|----------------|-----------|-------------|
| `3'b000` | ADD | `alu_o = a_i + b_i` |
| `3'b001` | SUB | `alu_o = a_i - b_i` |
| `3'b010` | AND | `alu_o = a_i & b_i` |
| `3'b011` | OR | `alu_o = a_i \| b_i` |
| `3'b100` | XOR | `alu_o = a_i ^ b_i` |
| `3'b101` | NOT | `alu_o = ~a_i` (b_i ignored) |
| `3'b110` | SLL | `alu_o = a_i << 1` (Shift Left Logical, b_i ignored) |
| `3'b111` | SRL | `alu_o = a_i >> 1` (Shift Right Logical, b_i ignored) |

### Example Operations

```
a_i = 8'h05 (5), b_i = 8'h03 (3)

op_i = 3'b000 (ADD): alu_o = 8'h08 (8)
op_i = 3'b001 (SUB): alu_o = 8'h02 (2)
op_i = 3'b010 (AND): alu_o = 8'h01 (1)
op_i = 3'b011 (OR):  alu_o = 8'h07 (7)
op_i = 3'b100 (XOR): alu_o = 8'h06 (6)
op_i = 3'b101 (NOT): alu_o = 8'hFA (-6 as signed, 250 as unsigned)
op_i = 3'b110 (SLL): alu_o = 8'h0A (10)
op_i = 3'b111 (SRL): alu_o = 8'h02 (2)
```


## Constraints
NA