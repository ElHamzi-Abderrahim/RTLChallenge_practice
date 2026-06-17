# Memory Interface

## Problem Statement

Memory interfaces are critical components in digital systems that provide controlled access to memory arrays with proper timing and handshaking protocols. These interfaces manage read and write operations while implementing flow control mechanisms to handle varying memory access latencies and system performance requirements.

Design a memory interface that provides read and write access to a 16-entry memory array with 4 clock cycle access delays. The interface should implement proper request-ready handshaking and include variable latency to simulate realistic memory behavior with wait states.

### Module Interface

**Module Name**: `mem_interface`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal |
| `reset` | Input | 1 | Asynchronous reset signal |
| `req_i` | Input | 1 | Memory request signal |
| `req_rnw_i` | Input | 1 | Read/Write control (1=read, 0=write) |
| `req_addr_i` | Input | 4 | Memory address (4-bit for 16 entries) |
| `req_wdata_i` | Input | 32 | Write data input |
| `req_ready_o` | Output | 1 | Ready signal (transaction complete) |
| `req_rdata_o` | Output | 32 | Read data output |

### Functional Requirements

1. **Memory Array**: 16 entries of 32-bit data storage
2. **Read Operation**: When req_rnw_i=1, output data from addressed location
3. **Write Operation**: When req_rnw_i=0, store data to addressed location
4. **Variable Latency**: Implement random delays using internal counter mechanism
5. **Ready Handshaking**: Assert req_ready_o when operation completes
6. **Request Detection**: Use edge detection to identify new requests

### Example Operation

**Memory Write Operation with Delay:**

```
Clock:       ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
req_i:       ________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_______
req_rnw_i:   ___________________________________________________________
req_addr_i:  --------<    5    >----------------------------------------
req_wdata_i: --------< 0xABCD  >----------------------------------------
req_ready_o: ___________________________________________/‾‾‾\___________
4 clk cycle access delay.
```


**Memory Read Operation:**

```
Clock:       ___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___/‾‾‾\___
req_i:        ________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\______
req_rnw_i:   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
req_addr_i:  --------<    5    >----------------------------------------
req_rdata_o: <     0x0000                               ><    0xABCD   >
req_ready_o: ___________________________________________/‾‾‾\___________
4 clk cycle access delay.
```

**Timing Behavior:**
- On rising edge of req_i, counter loads a delay value (simulating variable latency)
- Counter decrements each clock cycle
- When counter reaches 0, operation completes and req_ready_o asserts for one cycle
- For writes: data is written to memory when counter=0
- For reads: data is available on req_rdata_o (can be combinational or registered)
- req_i can remain high until req_ready_o; use edge detection to identify new requests

## Constraints
NA