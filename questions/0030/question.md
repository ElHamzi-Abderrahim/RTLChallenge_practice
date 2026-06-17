# 8-Bit LIFO (Last In First Out) Stack

## Problem Statement

A LIFO (Last In First Out) stack is a fundamental data structure where elements are added and removed from the same end, called the top of the stack. The last element pushed onto the stack is the first one to be popped off. LIFO stacks are commonly used in applications such as function call management, expression evaluation, undo operations, and temporary data storage.

Design an 8-bit LIFO stack with 4 memory locations that supports push and pop operations. The stack should handle overflow and underflow conditions gracefully and provide proper stack pointer management.

### Module Interface

**Module Name**: `lifo`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Reset signal (active high) |
| `push` | Input | 1 | Push data into the stack |
| `pop` | Input | 1 | Pop data from the stack |
| `data_in` | Input | 8 | Data to be pushed into the stack |
| `data_out` | Output | 8 | Data popped from the stack |

### Functional Requirements

1. **Reset Operation**: When reset=1, clear all stack elements and reset stack pointer to 0
2. **Push Operation**: When push=1, store data_in at the top of stack and increment stack pointer
3. **Pop Operation**: When pop=1, output data from top of stack and decrement stack pointer
4. **Stack Capacity**: 4 elements maximum (locations 0-3)
5. **Overflow Protection**: Ignore push operations when stack is full
6. **Underflow Protection**: Ignore pop operations when stack is empty
7. **Priority**: reset > push > pop (if both push and pop are asserted, push takes priority)

### Example Operation

**Push Operations:**
```
Clock:    ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\
reset:    ‾‾‾\____________________________________________________________________________________
push:     _______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\________
data_in:  <  X   ><     0xAA     ><     0xBB     ><     0xCC     ><     0xDD     ><     0xEE     >
stack[3]: <     0    ><     0        ><     0        ><     0        ><    0xDD      ><     0xDD >
stack[2]: <     0    ><     0        ><     0        ><    0xCC      ><    0xCC      ><     0xCC >
stack[1]: <     0    ><     0        ><    0xBB      ><    0xBB      ><    0xBB      ><     0xBB >
stack[0]: <     0    ><    0xAA      ><    0xAA      ><    0xAA      ><    0xAA      ><     0xAA >
```

**Pop Operations:**
```
Clock:    ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\
reset:    ‾‾‾\____________________________________________________________________________________
pop:     _______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\________
data_in:  <  X   ><     0xDD     ><     0xCC     ><     0xBB     ><     0xAA     ><     0x00     >
stack[3]: <    0xDD  ><     0        ><     0        ><     0       ><      0        ><     0    >
stack[2]: <    0xCC  ><    0xCC      ><     0        ><     0       ><      0        ><     0    >
stack[1]: <    0xBB  ><    0xBB      ><    0xBB      ><     0       ><      0        ><     0    >
stack[0]: <    0xAA  ><    0xAA      ><    0xAA      ><    0xAA     ><      0        ><     0    >
```

**Stack Full/Empty Conditions:**
- **Full**: top = 3, push operations ignored
- **Empty**: top = 0, pop operations ignored, data_out = 0x00

## Constraints
NA