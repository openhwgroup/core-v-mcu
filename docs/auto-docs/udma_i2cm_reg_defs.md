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
Offset/Field
RX_SADDR
SADDR
RX_SIZE
SIZE
RX_CFG
CLR
PENDING
EN
CONTINUOUS


TX_SADDR
SADDR
TX_SIZE
SIZE
TX_CFG
CLR
PENDING
EN
CONTINUOUS


STATUS
AL
BUSY
SETUP
RESET

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
