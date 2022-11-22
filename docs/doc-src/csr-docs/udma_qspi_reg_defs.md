# UDMA_QSPI

Memory address: UDMA_CH_ADDR_QSPI(`UDMA_CH_ADDR_QSPI)

The actions of the QSPI controller are controlled using a sequence of commands that are present in the transmit buffer.
Therefore, to use theQSPI controller the software must assemble the appropriate sequence of commands in a buffer, and use the UDMA to send the buffer to the QSPI contoller.
And because the UDMA handles data buffers and interrupts, it is important to understand how to operate the UDMA controller.

| Code |   Command/Field |  Bits | Description     |
| ---  |  -------------- | ----- | ------------------------- |
| 0x0  |     SPI_CMD_CFG |       | Sets the configuration for the SPI Master IP |
|      |          CLKDIV |   7:0 | Sets the clock divider value |
|      |            CPHA |   8:8 | Sets the clock phase: |
|      |                 |       | 0x0:            |
|      |                 |       | 0x1:            |
|      |            CPOL |   9:9 | Sets the clock polarity: |
|      |                 |       | 0x0:            |
|      |                 |       | 0x1:            |
|      |         SPI_CMD | 31:28 | Command to execute (0x0) |
| 0x1  |     SPI_CMD_SOT |       | Sets the Chip Select (CS) |
|      |              CS |   1:0 | Sets the Chip Select (CS): |
|      |                 |       | 0x0: select csn0 |
|      |                 |       | 0x1: select csn1 |
|      |                 |       | 0x2: select csn2 |
|      |                 |       | 0x3: select csn3 |
|      |         SPI_CMD | 31:28 | Command to execute (0x1) |
| 0x2  | SPI_CMD_SEND_CMD |       | Transmits up to 16bits of data sent in the command |
|      |      DATA_VALUE |  15:0 | Sets the command to send. |
|      |                 |       | MSB must always be at bit 15 |
|      |                 |       |  if cmd size is less than 16 |
|      |       DATA_SIZE | 19:16 | N-1,  where N is the size in bits of the command |
|      |                 |       | to send         |
|      |             LSB | 26:26 | Sends the data starting from LSB |
|      |             QPI | 27:27 | Sends the command using QuadSPI |
|      |         SPI_CMD | 31:28 | Command to execute (0x2) |
| 0x4  |   SPI_CMD_DUMMY |       | Receives a number of dummy bits |
|      |                 |       | which are not sent to the RX interface |
|      |     DUMMY_CYCLE | 21:16 | Number of dummy cycles to perform |
|      |         SPI_CMD | 31:28 | Command to execute (0x4) |
| 0x5  |    SPI_CMD_WAIT |       | Waits for an external event to move to the next  |
|      |                 |       | instruction     |
|      | EVENT_ID_CYCLE_COUNT |   6:0 | External event id or Number of wait cycles |
|      |       WAIT_TYPE |   9:8 | Type of wait:   |
|      |                 |       | 0x0: wait for and soc event selected by EVENT_ID |
|      |                 |       | 0x1: wait CYCLE_COUNT cycles |
|      |                 |       | 0x2: rfu        |
|      |                 |       | 0x3: rfu        |
|      |         SPI_CMD | 31:28 | Command to execute (0x5) |
|      |                 |       |                 |
| 0x6  | SPI_CMD_TX_DATA |       | Sends data (max 256Kbits) |
|      |        WORD_NUM |  15:0 | N-1, where N is the number of words to send |
|      |                 |       | (max 64K)       |
|      |       WORD_SIZE | 20:16 | N-1, where N is the number of bits in each word |
|      | WORD_PER_TRANSF | 22:21 | Number of words transferred from SRAM at |
|      |                 |       | each transfer   |
|      |                 |       | 0x0: 1 word per transfer |
|      |                 |       | 0x1: 2 words per transfer |
|      |                 |       | 0x2: 4 words per transfer |
|      |             LSB | 26:26 | 0x0: MSB first  |
|      |                 |       | 0x1: LSB first  |
|      |             QPI | 27:27 | 0x0: single bit data |
|      |                 |       | 0x1: quad SPI mode |
|      |         SPI_CMD | 31:28 | Command to execute (0x6) |
|      |                 |       |                 |
| 0x7  | SPI_CMD_RX_DATA |       | Receives data (max 256Kbits) |
|      |        WORD_NUM |  15:0 | N-1, where N is the number of words to send |
|      |                 |       | (max 64K)       |
|      |       WORD_SIZE | 20:16 | N-1, where N is the number of bits in each word |
|      | WORD_PER_TRANSF | 22:21 | Number of words transferred from SRAM at |
|      |                 |       | each transfer   |
|      |                 |       | 0x0: 1 word per transfer |
|      |                 |       | 0x1: 2 words per transfer |
|      |                 |       | 0x2: 4 words per transfer |
|      |             LSB | 26:26 | 0x0: MSB first  |
|      |                 |       | 0x1: LSB first  |
|      |             QPI | 27:27 | 0x0: single bit data |
|      |                 |       | 0x1: quad SPI mode |
|      |         SPI_CMD | 31:28 | Command to execute (0x7) |
|      |                 |       |                 |
| 0x8  |     SPI_CMD_RPT |       | Repeat the commands until RTP_END for N |
|      |                 |       | times           |
|      |         RPT_CNT |  15:0 | Number of repeat iterations (max 64K) |
|      |         SPI_CMD | 31:28 | Command to execute (0x8) |
|      |                 |       |                 |
| 0x9  |     SPI_CMD_EOT |       | Clears the Chip Select (CS) |
|      |       EVENT_GEN |   0:0 | Enable EOT event: |
|      |                 |       | 0x0: disable    |
|      |                 |       | 0x1: enable     |
|      |         SPI_CMD | 31:28 | Command to execute (0x9) |
|      |                 |       |                 |
| 0xA  | SPI_CMD_RPT_END |       | End of the repeat loop command |
|      |         SPI_CMD | 31:28 | Command to execute (0xA) |
|      |                 |       |                 |
| 0xB  | SPI_CMD_RX_CHECK |       | Checks up to 16 bits of data against an expected |
|      |                 |       | value           |
|      |       COMP_DATA |  15:0 | Data to compare |
|      |     STATUS_SIZE | 19:16 | N-1, where N is the size in bits of the word |
|      |                 |       | to read         |
|      |      CHECK_TYPE | 25:24 | How to compare: |
|      |                 |       | 0x0: compare bit by bit |
|      |                 |       | 0x1: compare only ones |
|      |                 |       | 0x2: compare only zeros |
|      |             LSB | 26:26 | 0x0: Receieved data is LSB first |
|      |                 |       | 0x1: Received data is MSB first |
|      |             QPI | 27:27 | 0x0: single bit data |
|      |                 |       | 0x1: quad SPI mode |
|      |         SPI_CMD | 31:28 | Command to execute (0xB) |
|      |                 |       |                 |
| 0xC  | SPI_CMD_FULL_DUPL |       | Activate full duplex mode |
|      |       DATA_SIZE |  15:0 | N-1, where N is the number of bits to send |
|      |                 |       | (max 64K)       |
|      |             LSB | 26:26 | 0x0: Data is LSB first |
|      |                 |       | 0x1: Data is MSB first |
|      |         SPI_CMD | 31:28 | Command to execute (0xC) |
|      |                 |       |                 |
| 0xD  | SPI_CMD_SETUP_UCA |       | Sets address for uDMA tx/rx channel |
|      |      START_ADDR |  20:0 | Address of start of buffer |
|      |         SPI_CMD | 31:28 | Command to execute (0xD) |
|      |                 |       |                 |
| 0xE  | SPI_CMD_SETUP_UCS |       | Sets size and starts uDMA tx/rx channel |
|      |            SIZE |       | N-1, where N is the number of bytes to transfer |
|      |                 |       |  (max size depends on the TRANS_SIZE parameter) |
|      | WORD_PER_TRANSF | 26:25 | Number of words from SRAM for each transfer: |
|      |                 |       | 0x0: 1 word per transfer |
|      |                 |       | 0x1: 2 words per transfer |
|      |                 |       | 0x2: 4 words per transfer |
|      |          TX_RXN | 27:27 | Selects TX or RX channel: |
|      |                 |       | 0x0: RX channel |
|      |                 |       | 0x1: TX channel |
|      |         SPI_CMD | 31:28 | Command to execute (0xE) |
|      |                 |       |                 |
|      |                 |       |                 |
|      |                 |       |                 |

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
| DATASIZE   |   2:1 |    WO |       0x02 | Controls uDMA address increment (Reads as 0x00) |
|            |       |       |            | 0x00: increment address by 1 (data is 8 bits) |
|            |       |       |            | 0x01: increment address by 2 (data is 16 bits) |
|            |       |       |            | 0x02: increment address by 4 (data is 32 bits) |
|            |       |       |            | 0x03: increment address by 0 |
| CONTINUOUS |   0:0 |    RW |            | 0x0: stop after last transfer for channel |
|            |       |       |            | 0x1: after last transfer for channel, |
|            |       |       |            | reload buffer size and start address and restart channel |

### CMD_SADDR offset = 0x20

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SADDR      |  31:0 |    RW |       0x00 | Address of command memory buffer: |
|            |       |       |            | Read: current address until transfer is complete, then 0x00 |
|            |       |       |            | Write: start addrress of command buffer |

### CMD_SIZE offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SIZE       |  20:0 |       |            | Buffer size in bytes (1MByte maximum) |
|            |       |       |            | Read: bytes remaining to be transferred |
|            |       |       |            | Write: number of bytes to transmit |

### CMD_CFG offset = 0x28

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CLR        |   6:6 |    WO |            | Clear the transmit channel |
| PENDING    |   5:5 |    RO |            | Transmit transaction is pending |
| EN         |   4:4 |    RW |            | Enable the transmit channel |
| DATASIZE   |   2:1 |    WO |       0x02 | Controls uDMA address increment (Reads as 0x02) |
|            |       |       |            | 0x00: increment address by 1 (data is 8 bits) |
|            |       |       |            | 0x01: increment address by 2 (data is 16 bits) |
|            |       |       |            | 0x02: increment address by 4 (data is 32 bits) |
|            |       |       |            | 0x03: increment address by 0 |
| CONTINUOUS |   0:0 |    RW |            | 0x0: stop after last transfer for channel |
|            |       |       |            | 0x1: after last transfer for channel, |
|            |       |       |            | reload buffer size and start address and restart channel |

### STATUS offset = 0x30

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| BUSY       |   1:0 |    RO |            | Status:         |
|            |       |       |            | 0x00: STAT_NONE |
|            |       |       |            | 0x01: STAT_CHECK (matched) |
|            |       |       |            | 0x02: STAT_EOL (end of loop) |

