# UDMA_SDIO

Memory address: UDMA_CH_ADDR_SDIO(`UDMA_CH_ADDR_SDIO)




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

### TX_SADDR offset = 0x10

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SADDR      |  11:0 |    RW |            | Address of transmit memory buffer: |
|            |       |       |            | - Read: value of pointer until transfer is over, then 0 |
|            |       |       |            | #NAME?          |

### TX_SIZE offset = 0x14

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SIZE       |  15:0 |    RW |            | Buffer size in bytes (1MB max) |
|            |       |       |            | #NAME?          |
|            |       |       |            | #NAME?          |

### TX_CFG offset = 0x18

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CLR        |   5:5 |    WO |            | Clear the transmit channel |
| PENDING    |   5:5 |    RO |            | Transmit transaction is pending |
| EN         |   4:4 |    RW |            | Enable the transmit channel |
| DATASIZE   |   2:1 |    WO |       0x02 | Controls uDMA address increment (Reads as 0x00) |
|            |       |       |            | 0x00: increment address by 1 (data is 8 bits) |
|            |       |       |            | 0x01: increment address by 2 (data is 16 bits) |
|            |       |       |            | 0x02: increment address by 4 (data is 32 bits) |
|            |       |       |            | 0x03: increment address by 0 |
| CONTINUOUS |   0:0 |    RW |            | 0x0: stop after last transfer for channel |
|            |       |       |            | 0x1: after last transfer for channel, |
|            |       |       |            | reload buffer size and start address and restart channel |

### CMD_OP offset = 0x20

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CMD_OP     |  13:8 |    WO |            | SDIO command opcode |
| CMD_RSP_TYPE |   2:0 |    WO |            | Response type:  |
|            |       |       |            | 0x0: No response |
|            |       |       |            | 0x1: 48 bits with CRC |
|            |       |       |            | 0x2: 48 bits with no CRC |
|            |       |       |            | 0x3: 136 bits   |
|            |       |       |            | 0x4: 48 bits with BUSY check |

### CMD_ARG offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CMD_ARG    |  31:0 |    WO |            | Argument to be sent with the command |

### DATA_SETUP offset = 0x28

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| BLOCK_SIZE | 25:16 |     W |            | Block size      |
| BLOCK_NUM  |  15:8 |     W |            | Number of blocks |
| DATA_QUAD  |   2:2 |     W |            | Use QUAD mode   |
| DATA_RWN   |   1:1 |     W |            | Set transfer direction: |
|            |       |       |            | 0x0: write      |
|            |       |       |            | 0x1: read       |
| DATA_EN    |   0:0 |     W |            | Enable data transfer for current command |

### START offset = 0x2C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| START      |   0:0 |     W |            | Start SDIO transfer |

### RSP0 offset = 0x30

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RSP0       |  31:0 |     R |            | Bytes[3:0] of the response |

### RSP1 offset = 0x34

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RSP1       |  31:0 |     R |            | Bytes[7:4] of the response |

### RSP2 offset = 0x38

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RSP2       |  31:0 |     R |            | Bytes[11:8] of the response |

### RSP3 offset = 0x3C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RSP3       |  31:0 |     R |            | Bytes[15:12] of the response |

### CLK_DIV offset = 0x40

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| VALID      |   8:8 |    RW |            | ??              |
| CLK_DIV    |   7:0 |    RW |            | Clock divisor   |

### STATUS offset = 0x44

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CMD_ERR_STATUS | 21:16 |     R |            | Error status of commnd transfer: |
|            |       |       |            | 0x0: no error   |
|            |       |       |            | 0x1: response timeout |
|            |       |       |            | 0x2: response wrong direction |
|            |       |       |            | 0x4: response BUSy timeout |
| ERROR      |   1:1 |   RWC |            | Indicate error in command or data |
|            |       |       |            | 0x0: no error   |
|            |       |       |            | 0x1: error      |
| EOT        |   0:0 |   RWC |            | Indicate the end of transfer (command or data) |
|            |       |       |            | 0x0: not ended  |
|            |       |       |            | 0x1: ended      |

