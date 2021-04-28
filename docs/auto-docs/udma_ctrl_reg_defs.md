# UDMA_CTRL

Memory address: UDMA_CH_ADDR_CTRL(`UDMA_CH_ADDR_CTRL)

The UDMA addresses are organized as an array of channels.
The first channel, channel 0, is a control channel that is used to:

* enable or disable the peripheral clocks
* reset the periperal controller
* set compare value for the event macthing mechanism

The base address for the UDMA channels is defined as UDMA_START_ADDR in core-v-mcu-config.h
The size of each channel is UDMA_CH_SIZE, therefore the address of channels N is UDMA_START_ADDR+N*UDMA_CH_SIZE.
core-v-mcu-config.h has explicit defines for each peripheral.
For instance,  if there are 2 UARTS then there are three defines:

* UDMA_CH_ADDR_UART -- address of first UART
* UDMA_CH_ADDR_UART0 -- address of UART0
* UDMA_CH_ADDR_UART1 -- address of UART1

The reason for having the UDMA_CH_UART define
is so that you can programmatically access UART ID by using
UDMA_CH_ADDR_UART + ID * UDMA_CH_SIZE

The register definitions for the control channel are specified in this section.
The register definitions for each peripheral are specified in sections named UDMA_XXXXX.

Offset/Field
REG_CG
PERIPH_CLK_ENABLE

REG_CFG_EVT
CMP_EVENT3
CMP_EVENT2
CMP_EVENT1
CMP_EVENT0
REG_RST
PERIPH_RESET


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
