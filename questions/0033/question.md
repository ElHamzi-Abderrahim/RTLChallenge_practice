# Asynchronous FIFO

## Problem Statement

Design a parameterizable asynchronous FIFO (First-In-First-Out) buffer that can safely transfer data between two different clock domains. The FIFO must handle clock domain crossing without data corruption or metastability issues.

### Module Interface

**Module Name**: `async_fifo`

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `wr_clk` | Input | 1 | Write clock domain |
| `wr_rst_n` | Input | 1 | Write clock domain reset (active low) |
| `wr_en` | Input | 1 | Write enable signal |
| `wr_data` | Input | `[DATA_WIDTH-1:0]` | Data to write into FIFO |
| `wr_full` | Output | 1 | FIFO full flag (write domain) |
| `rd_clk` | Input | 1 | Read clock domain |
| `rd_rst_n` | Input | 1 | Read clock domain reset (active low) |
| `rd_en` | Input | 1 | Read enable signal |
| `rd_data` | Output | `[DATA_WIDTH-1:0]` | Data read from FIFO |
| `rd_empty` | Output | 1 | FIFO empty flag (read domain) |

**Parameters**:
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `DATA_WIDTH` | 8 | Width of data bus |
| `FIFO_DEPTH` | 16 | Depth of FIFO (must be power of 2) |

### Functional Requirements

1. **Asynchronous Operation**: Safe operation across different clock domains
2. **Gray Code Pointers**: Use Gray code for pointer synchronization
3. **Full/Empty Detection**: Accurate status flags in respective domains
4. **No Data Loss**: Prevent overwrite when full or underflow when empty
5. **Metastability Protection**: Proper synchronization between clock domains
6. **Parameterizable**: Support different data widths and FIFO depths

### Example Operation

For DATA_WIDTH = 8, FIFO_DEPTH = 4:
- Write data when wr_en=1 and wr_full=0
- Read data when rd_en=1 and rd_empty=0
- wr_full asserts when FIFO has 4 entries
- rd_empty asserts when FIFO has 0 entries

## Constraints
- FIFO_DEPTH must be a power of 2 (2, 4, 8, 16, etc.)
- Both reset signals are active low and asynchronous
- No writes when wr_full is asserted
- No reads when rd_empty is asserted