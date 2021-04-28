# SOC_CTRL

 Memory address: SOC_CTRL_START_ADDR (`SOC_CTRL_START_ADDR)

This APB peripheral primarily controls I/O configuration and I/O function connection. 
It also supports a few registers for miscellaneous functions.

I/O control supports two functions:

* I/O configuration
* I/O function selection

I/O configuration is a series of bits that control driver characteristics, such as drive strength and slew rate.
I/O function selection controls the select field of a mux that connects the I/O to different signals in the device.

Offset/Field
INFO
N_CORES
N_CLUSTERS
BUILD_DATE
YEAR
MONTH
DAY
BUILD_TIME
HOUR
MINUTES
SECONDS
IO_CFG0
N_GPIO
N_SYSIO
N_IO
IO_CFG1
NBIT_PADMUX
NBIT_PADCFG
PER_CFG0
N_I2SC
N_I2CM
N_QSPIM
N_UART
PER_CFG1
N_CAM
N_SDIO

JTAGREG
CORESTATUS
EOC
STATUS
CS_RO
EOC
STATUS
BOOTSEL
CLKSEL
CLK_DIV_CLU
SEL_CLK_DC_FIFO_EFPGA
CLK_GATING_DC_FIFO_EFPGA
RESET_TYPE1_EFPGA
RESET_LB
RESET_RB
RESET_RT
RESET_LT
ENABLE_IN_OUT_EFPGA
ENABLE_EVENTS
ENABLE_SOC_ACCESS
ENABLE_TCDM_P3
ENABLE_TCDM_P2
ENABLE_TCDM_P1
ENABLE_TCDM_P0
EFPGA_CONTROL_IN
EFPGA_STATUS_OUT
EFPGA_VERSION

IO_CTRL[48]
CFG
MUX

### Notes:

| Access type | Description |
| ----------- | ----------- |
| RW          | Read & Write |
| RO          | Read Only    |
| RC          | Read & Clear after read |
| WO          | Write Only |
| WS          | Write Sets (value ignored; always writes a 1) |
| RW1S        | Read & on Write bits with 1 get set, bits with 0 left unchanged |
| RW1C        | Read & on Write bits with 1 get cleared, bits with 0 left unchanged |
| RW0C        | Read & on Write bits with 0 get cleared, bits with 1 left unchanged |
