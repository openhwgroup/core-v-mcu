# UDMA_CAMERA

Memory address: UDMA_CH_ADDR_CAMERA(`UDMA_CH_ADDR_CAMERA)




### RX_SADDR offset = 0x00

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SADDR      |  31:0 |    RW |            | Address of receive memory buffer: |
|            |       |       |            | - Read: value of pointer until transfer is over, then 0 |
|            |       |       |            | - Write: set memory buffer start address |

### RX_SIZE offset = 0x04

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SIZE       |  15:0 |    RW |            | Buffer size in bytes (1MB max) |
|            |       |       |            | - Read: bytes remaining until transfer complete |
|            |       |       |            | - Write: set number of bytes to transfer |

### RX_CFG offset = 0x08

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CLR        |   5:5 |    WO |            | Clear the receive channel |
| PENDING    |   5:5 |    RO |            | Receive transaction is pending |
| EN         |   4:4 |    RW |            | Enable the receive channel |
| DATASIZE   |   2:1 |    RW |       0x02 | Controls uDMA address increment |
|            |       |       |            | 0x00: increment address by 1 (data is 8 bits) |
|            |       |       |            | 0x01: increment address by 2 (data is 16 bits) |
|            |       |       |            | 0x02: increment address by 4 (data is 32 bits) |
|            |       |       |            | 0x03: increment address by 0 |
| CONTINUOUS |   0:0 |    RW |            | 0x0: stop after last transfer for channel |
|            |       |       |            | 0x1: after last transfer for channel, |
|            |       |       |            | reload buffer size and start address and restart channel |

### CFG_GLOB offset = 0x20

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| EN         | 31:31 |    RW |            | Enable data RX from camera interface |
|            |       |       |            | Enable/disable only happens at start of frame |
|            |       |       |            | 0x0: disable    |
|            |       |       |            | 0x1: enable     |
| SHIFT      | 14:11 |       |            | Number of bits to right shift final pixel value |
|            |       |       |            | Note: not used if FORMAT == BYPASS |
| FORMAT     |  10:8 |       |            | Input frame format: |
|            |       |       |            | 0x0: RGB565     |
|            |       |       |            | 0x1: RGB555     |
|            |       |       |            | 0x2: RGB444     |
|            |       |       |            | 0x4: BYPASS_LITTLEEND |
|            |       |       |            | 0x5: BYPASS_BIGEND |
| FRAMEWINDOW_EN |   7:7 |       |            | Windowing enable: |
|            |       |       |            | 0x0: disable    |
|            |       |       |            | 0x1: enable     |
| FRAMEDROP_VAL |   6:1 |       |            | How many frames dropped between receievd frame |
| FRAMEDROP_EN |   0:0 |       |            | Frame dropping enable: |
|            |       |       |            | 0x0: disable frame dropping |
|            |       |       |            | 0x1: enable frame dropping |

### CFG_LL offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| FRAMEWINDOW_LLY | 31:16 |       |            | Y coordinate of lower left corner of window |
| FRAMEWINDOW_LLX |  15:0 |       |            | X coordinate of lower left corner of window |

### CFG_UR offset = 0x28

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| FRAMEWINDOW_URY | 31:16 |       |            | Y coordinate of upper right corner of window |
| FRAMEWINDOW_URX |  15:0 |       |            | X coordinate of upper right corner of window |

### CFG_SIZE offset = 0x2C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| ROWLEN     | 31:16 |       |            | N-1 where N is the number of horizontal pixels |
|            |       |       |            | (used in window mode) |

### CFG_FILTER offset = 0x30

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| R_COEFF    | 23:16 |       |            | Coefficent that multiplies R component |
|            |       |       |            | Note: not used if FORMAT == BYPASS |
| G_COEFF    |  15:8 |       |            | Coefficent that multiplies G component |
|            |       |       |            | Note: not used if FORMAT == BYPASS |
| B_COEFF    |  15:8 |       |            | Coefficent that multiplies B component |
|            |       |       |            | Note: not used if FORMAT == BYPASS |

### VSYNC_POLARITY offset = 0x34

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| VSYNC_POLARITY |   0:0 |   R/W |            | Set vsync polarity: |
|            |       |       |            | 0x0: Active low |
|            |       |       |            | 0x1: Active high |

