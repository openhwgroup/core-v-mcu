# SOC_CTRL

This APB peripheral primarily controls I/O configuration and I/O function connection. 
It also supports a few registers for miscellaneous functions.

I/O control supports two functions:

* I/O configuration
* I/O function selection

I/O configuration is a series of bits that control driver characteristics, such as drive strength and slew rate.
I/O function selection controls the select field of a mux that connects the I/O to different signals in the device.
### INFO offset = 0x0000
| Field      |  Bits |  Type |    Default | Description     |
| ---        |   --- |   --- |        --- | ---             |
| N_CORES    | 31:16 |    RO |            | Number of cores in design |
| N_CLUSTERS |  15:0 |    RO |            | Number of clusters in design |
### JTAGREG offset = 0x0074
### CORESTATUS offset = 0x00A0
| Field      |  Bits |  Type |    Default | Description     |
| ---        |   --- |   --- |        --- | ---             |
| EOC        | 31:31 |    RW |            | EOC condition   |
| STATUS     |  30:0 |    RW |            | Status bits     |
### CS_RO offset = 0x00C0
| Field      |  Bits |  Type |    Default | Description     |
| ---        |   --- |   --- |        --- | ---             |
| EOC        | 31:31 |    RO |            | EOC condition   |
| STATUS     |  30:0 |    RO |            | Status bits     |
### BOOTSEL offset = 0x00C4
### CLKSEL offset = 0x00C8
### CLK_DIV_CLU offset = 0x00D8
### SEL_CLK_DC_FIFO_EFPGA offset = 0x00E0
### CLK_GATING_DC_FIFO_EFPGA offset = 0x00E4
### RESET_TYPE1_EFPGA offset = 0x00E8
### ENABLE_IN_OUT_EFPGA offset = 0x00EC
### IO_CTRL[48] offset = 0x0400
| Field      |  Bits |  Type |    Default | Description     |
| ---        |   --- |   --- |        --- | ---             |
| CFG        |  13:8 |    RW |       0x00 | Pad configuration (TBD) |
| MUX        |   1:0 |    RW |       0x00 | Mux select      |
