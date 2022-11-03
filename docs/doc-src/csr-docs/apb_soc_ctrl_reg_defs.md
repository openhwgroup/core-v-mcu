# SOC_CTRL

 Memory address: SOC_CTRL_START_ADDR (0x1A104000)

This APB peripheral primarily controls I/O configuration and I/O function connection. 
It also supports a few registers for miscellaneous functions.

I/O control supports two functions:

* I/O configuration
* I/O function selection

I/O configuration is a series of bits that control driver characteristics, such as drive strength and slew rate.
I/O function selection controls the select field of a mux that connects the I/O to different signals in the device.


### INFO offset = 0x0000

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| N_CORES    | 31:16 |    RO |            | Number of cores in design |
| N_CLUSTERS |  15:0 |    RO |            | Number of clusters in design |

### BUILD_DATE offset = 0x000C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| YEAR       | 31:16 |    RO |            | Year in BCD     |
| MONTH      |  15:8 |    RO |            | Month in BCD    |
| DAY        |   7:0 |    RO |            | Day in BCD      |

### BUILD_TIME offset = 0x0010

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| HOUR       | 23:16 |    RO |            | Hour in BCD     |
| MINUTES    |  15:8 |    RO |            | Minutes in BCD  |
| SECONDS    |   7:0 |    RO |            | Seconds in BCD  |

### IO_CFG0 offset = 0x0014

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| N_GPIO     | 23:16 |    RO |         32 | Number of IO connected to GPIO controller |
| N_SYSIO    |  15:8 |    RO |          3 | Number of fixed-function IO |
| N_IO       |   7:0 |    RO |         48 | Number of IO on device (not necessarily on package) |

### IO_CFG1 offset = 0x0018

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| NBIT_PADMUX |  15:8 |    RO |          2 | Number of bits in pad mux select, which means there are 2^NBIT_PADMUX options |
| NBIT_PADCFG |   7:0 |    RO |          6 | Number of bits in padconfiguration |

### PER_CFG0 offset = 0x0020

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| N_I2SC     | 31:24 |    RO |          0 | Number of I2S clients |
| N_I2CM     | 23:16 |    RO |          2 | Number of I2C masters |
| N_QSPIM    |  15:8 |    RO |          2 | Number of QSPI masters |
| N_UART     |   7:0 |    RO |          2 | Number of UARTs |

### PER_CFG1 offset = 0x0024

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| N_CAM      |  15:8 |    RO |          1 | Number of Camera controllers |
| N_SDIO     |   7:0 |    RO |          1 | Number of SDIO controllers |

### JTAGREG offset = 0x0074


### BOOTSEL offset = 0x00C4

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| BootDev    |   0:0 |       |            | Selects Boot device 1=SPI, 0=Host mode via I2Cs |

### CLKSEL offset = 0x00C8


### WD_COUNT offset = 0x00D0

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| COUNT      |  30:0 |   R/W |     0x8000 | Only writable before Watchdog is enabled |

### WD_CONTROL offset = 0x00D4

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| ENABLE_STATUS | 31:31 |    R0 |            | 1=Watchdog Enabled, 0=Watchdog not enabled,Enabled Watch dog, once enable, cannot be disabled  |
| WD_VALUE   |  15:0 |    WO |         NA | Set to 0x6699 to reset watchdog when enabled, read current WD value |

### RESET_REASON offset = 0x00D8

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| REASON     |   1:0 |   R/W |            | 2'b01= reset pin, 2'b11=Watchdog expired |

### RTO_PERIPHERAL_ERROR offset = 0x00E0

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| FCB_RTO    |   8:8 |   R/W |       0x0  | 1 indicates that the FCB interface caused a ready timeout |
| TIMER_RTO  |   7:7 |   R/W |       0x0  | 1 indicates that the TIMER interface caused a ready timeout |
| I2CS_RTO   |   6:6 |   R/W |       0x0  | 1 indicates that the I2CS interface caused a ready timeout |
| EVENT_GEN_RTO |   5:5 |   R/W |       0x0  | 1 indicates that the EVENT GENERATOR interface caused a ready timeout |
| ADV_TIMER_RTO |   4:4 |   R/W |       0x0  | 1 indicates that the ADVANCED TIMER interface caused a ready timeout |
| SOC_CONTROL_RTO |   3:3 |   R/W |        0x0 | 1 indicates that the SOC CONTROL interface caused a ready timeout |
| UDMA_RTO   |   2:2 |   R/W |        0x0 | 1 indicates that the UDMA CONTROL interface caused a ready timeout |
| GPIO_RTO   |   1:1 |   R/W |       0x0  | 1 indicates that the GPIO interface caused a ready timeout |
| FLL_RTO    |   0:0 |   R/W |       0x0  | 1 indicates that the FLL interface caused a ready timeout |

### READY_TIMEOUT_COUNT offset = 0x00E4

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| COUNT      |  19:0 |   R/W |       0xFF | Number of APB clocks before a ready timeout occurs |

### RESET_TYPE1_EFPGA offset = 0x00E8

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESET_LB   |   3:3 |   R/W |       0x0  | Reset eFPGA Left Bottom Quadrant |
| RESET_RB   |   2:2 |   R/W |       0x0  | Reset eFPGA Right Bottom Quadrant |
| RESET_RT   |   1:1 |   R/W |       0x0  | Reset eFPGA Right Top Quadrant |
| RESET_LT   |   0:0 |   R/W |       0x0  | Reset eFPGA Left Top Quadrant |

### ENABLE_IN_OUT_EFPGA offset = 0x00EC

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| ENABLE_EVENTS |   5:5 |   R/W |       0x00 | Enable events from efpga to SOC |
| ENABLE_SOC_ACCESS |   4:4 |   R/W |       0x0  | Enable SOC memory mapped access to EFPGA |
| ENABLE_TCDM_P3 |   3:3 |   R/W |       0x0  | Enable EFPGA access via TCDM port 3 |
| ENABLE_TCDM_P2 |   2:2 |   R/W |       1x0  | Enable EFPGA access via TCDM port 2 |
| ENABLE_TCDM_P1 |   1:1 |   R/W |       2x0  | Enable EFPGA access via TCDM port 1 |
| ENABLE_TCDM_P0 |   0:0 |   R/W |       3x0  | Enable EFPGA access via TCDM port 0 |

### EFPGA_CONTROL_IN offset = 0x00F0


### EFPGA_STATUS_OUT offset = 0x00F4


### EFPGA_VERSION offset = 0x00F8


### SOFT_RESET offset = 0x00FC


### IO_CTRL[48] offset = 0x0400

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CFG        |  13:8 |    RW |       0x00 | Pad configuration (TBD) |
| MUX        |   1:0 |    RW |       0x00 | Mux select      |

