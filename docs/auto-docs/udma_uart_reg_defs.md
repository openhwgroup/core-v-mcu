# UDMA_UART

Memory address: UDMA_CH_ADDR_UART(`UDMA_CH_ADDR_UART)

Basic UART driven by UDMA system
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
RX_BUSY
TX_BUSY
UART_SETUP
DIV
EN_RX
EN_TX
RX_CLEAN_FIFO
RX_POLLING_EN
STOP_BITS

BITS



PARITY_EN
ERROR
PARITY_ERR
OVERFLOW_ERR
IRQ_EN
ERR_IRQ_EN
RX_IRQ_EN
VALID
RX_DATA_VALID
DATA
RX_DATA

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
