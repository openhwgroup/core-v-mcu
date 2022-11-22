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


### REG_CG offset = 0x000

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| PERIPH_CLK_ENABLE |  31:0 |    RW |        0x0 | Enable for peripheral clocks; |
|            |       |       |            | see core-v-mcu_config 'Peripheral clock enable masks' for bit positions |

### REG_CFG_EVT offset = 0x004

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| CMP_EVENT3 | 31:24 |       |       0x00 | Compare value for event detection |
| CMP_EVENT2 | 23:16 |       |       0x01 | Compare value for event detection |
| CMP_EVENT1 |  15:8 |       |       0x02 | Compare value for event detection |
| CMP_EVENT0 |   7:0 |       |       0x03 | Compare value for event detection |

### REG_RST offset = 0x008

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| PERIPH_RESET |  31:0 |    RW |        0x0 | Reset for peripherals; |
|            |       |       |            | use core-v-mcu_config 'Peripheral clock enable masks' for bit positions |

