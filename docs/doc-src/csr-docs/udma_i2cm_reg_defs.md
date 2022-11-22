# UDMA_I2CM

Memory address: UDMA_CH_ADDR_I2CM(`UDMA_CH_ADDR_I2CM)

The actions of the I2C controller are controlled using a sequence of commands that are present in the transmit buffer.
Therefore, to use the I2C controller the software must assemble the appropriate sequence of commands in a buffer, and use the UDMA to send the buffer to the I2C contoller.
And because the UDMA handles data buffers and interrupts, it is important to understand how to operate the UDMA controller.

| I2C Command | Value |  Description |
| ----------------  | ------- | --------------------------------------------- |
| CMD_START | 0x00 | Issue an I2C Start sequence |
| CMD_STOP   | 0x20 | Issue an I2C Stop seqeuence |
| CMD_RD_ACK | 0x40 | Read a byte and send an ACK to the device |
||| byte read from device is stored in receive buffer |
||| ACK implies that the next command will be another read |
| CMD_RD_NACK | 0x60 | Read a byte and send a NACK to the device |
||| byte read from device is stored in receive buffer |
||| NACK implies that the next command will be a Stop (or perhaps Start) |
| CMD_WR | 0x80 | Write the next byte in the transmit buffer to the I2C device |
| CMD_WAIT | 0xA0 | Next byte specifies number of I2C clocks to wait before procceeding to next command|
| CMD_RPT | 0xC0 | Next two bytes are the repeat count and command to be repeated|
||| Typical use case would be to read N_BYTES: |
||| . . . CMD_RPT, N_BYTES-1, CMD_RD_ACK, CMD_RD_NAK . . . |
| CMD_CFG | 0xE0 | Next two bytes in the transmit buffer are the MSB and LSB of the clock divider |
||| I2C clock frequency is peripheral clock frequency deviced by divisor |
| CMD_WAIT_EV | 0x10 | (Needs more investigation)|

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
| AL         |   1:1 |    RO |            | Always returns 0 |
| BUSY       |   0:0 |    RO |            | Always returns 0 |

### SETUP offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESET      |   0:0 |    RW |            | Reset I2C controller |

