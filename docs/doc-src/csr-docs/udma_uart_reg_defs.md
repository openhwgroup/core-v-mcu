# UDMA_UART

Memory address: UDMA_CH_ADDR_UART(`UDMA_CH_ADDR_UART)

Basic UART driven by UDMA system

### RX_SADDR offset = 0x00

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SADDR      |  11:0 |    RW |            | Address of receive buffer on write; current address on read |

### RX_SIZE offset = 0x04

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SIZE       |  15:0 |    RW |            | Size of receive buffer on write; bytes left on read |

### RX_CFG offset = 0x08

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CLR        |   6:6 |    WO |            | Clear the receive channel |
| PENDING    |   5:5 |    RO |            | Receive transaction is pending |
| EN         |   4:4 |    RW |            | Enable the receive channel |
| CONTINUOUS |   0:0 |    RW |            | 0x0: stop after last transfer for channel |
|            |       |       |            | 0x1: after last transfer for channel, |
|            |       |       |            | reload buffer size and start address and restart channel |

### TX_SADDR offset = 0x10

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SADDR      |  11:0 |    RW |            | Address of transmit buffer on write; current address on read |

### TX_SIZE offset = 0x14

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SIZE       |  15:0 |    RW |            | Size of receive buffer on write; bytes left on read |

### TX_CFG offset = 0x18

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CLR        |   6:6 |    WO |            | Clear the transmit channel |
| PENDING    |   5:5 |    RO |            | Transmit transaction is pending |
| EN         |   4:4 |    RW |            | Enable the transmit channel |
| CONTINUOUS |   0:0 |    RW |            | 0x0: stop after last transfer for channel |
|            |       |       |            | 0x1: after last transfer for channel, |
|            |       |       |            | reload buffer size and start address and restart channel |

### STATUS offset = 0x20

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RX_BUSY    |   1:1 |    RO |            | 0x1: receiver is busy |
| TX_BUSY    |   0:0 |    RO |            | 0x1: transmitter is busy |

### UART_SETUP offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| DIV        | 31:16 |    RW |            |                 |
| EN_RX      |   9:9 |    RW |            | Enable the reciever |
| EN_TX      |   8:8 |    RW |            | Enable the transmitter |
| RX_CLEAN_FIFO |   5:5 |    RW |            | Empty the receive FIFO |
| RX_POLLING_EN |   4:4 |    RW |            | Enable polling mode for receiver |
| STOP_BITS  |   3:3 |    RW |            | 0x0: 1 stop bit |
|            |       |       |            | 0x1: 2 stop bits |
| BITS       |   2:1 |    RW |            | 0x0: 5 bit transfers |
|            |       |       |            | 0x1: 6 bit transfers |
|            |       |       |            | 0x2: 7 bit transfers |
|            |       |       |            | 0x3: 8 bit transfers |
| PARITY_EN  |   0:0 |    RW |            | Enable parity   |

### ERROR offset = 0x28

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| PARITY_ERR |   1:1 |    RC |            | 0x1 indicates parity error; read clears the bit |
| OVERFLOW_ERR |   0:0 |    RC |            | 0x1 indicates overflow error; read clears the bit |

### IRQ_EN offset = 0x2C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| ERR_IRQ_EN |   1:1 |    RW |            | Enable the error interrupt |
| RX_IRQ_EN  |   0:0 |    RW |            | Enable the receiver interrupt |

### VALID offset = 0x30

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RX_DATA_VALID |   0:0 |    RO |            | Cleared when RX_DATA is read |

### DATA offset = 0x34

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RX_DATA    |   7:0 |    RO |            | Receive data; reading clears RX_DATA_VALID |

