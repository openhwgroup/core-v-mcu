<!--
NOTE: this document is intended to capture an outline of the CORE-V-MCU User Manual, currently under development.
Once the outline has been agreed to, this document will be deprecated and replaced.
-->
# CORE-V-MCU

## Introduction
The purpose of the CORE-V-MCU is to showcase the [CV32E40P](https://cv32e40p.readthedocs.io/en/latest/intro), a fully verified open-source RISC-V core supported by the Open Hardware Group.
In addition to the CV32E40P core, the CORE-V-MCU supports a representative set of peripherals:

* 2xUART
* 2xI2C master
* 1xI2C slave
* 2xQSPI master
* 1xCAMERA
* 1xSDIO
* 4xPWM
* eFPGA with 4 math units

CORE-V-MCU supports 512KB of SRAM and 3 PLLs.

![Block Diagram](../images/core-v-mcu-block-diagram.png)


## Hardware Evaluation Kits
The CORE-V-MCU is delivered as either:

* a Xilinx bitstream that runs on the Digilent Nexsy A7 board
* a Xilinx bitstream that runs on the Digilent Genesys2 board
* an SoC implemented with GLOBALFOUNDRIES 22nm fdx SOI technology that runs on the Open Hardware Group CORE-V-MCU EVK board
<!--
TODO: add references to the documentation for the above boards.
-->

## Software Development Kits
<!--
TODO: Short introdcution to the SDK plus a pointer to a stand-alone SDK User Manual
-->

## Getting Started
<!--
TODO: step-by-step guide to getting a blinking LED test working.
-->

## Peripherals
<!--
TODO: theory of operation of the peripherals
-->

### Memory Map
### Peripheral Control and Status Registers
#### UDMA
<!--
TODO: CSR table for UDMA goes here:
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### UART
<!--
This is the real CSR description description for the UART:
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | RX_SADDR |  |  |  |  |  |  |
 |  |  | SADDR | 11 | 0 | RW |  | Address of receive buffer on write; current address on read |
 | 0x04 | RX_SIZE |  |  |  |  |  |  |
 |  |  | SIZE | 15 | 0 | RW |  | Size of receive buffer on write; bytes left on read | 
 | 0x08 | RX_CFG |  |  |  |  |  |  |
 |  |  | CLR | 6 | 6 | WO |  | Clear the receive channel |
 |  |  | PENDING | 5 | 5 | RO |  | Receive transaction is pending |
 |  |  | EN | 4 | 4 | RW |  | Enable the receive channel |
 |  |  | CONTINUOUS | 0 | 0 | RW |  | 0x0: stop after last transfer for channel
 |  |  |            |   |   |    |  | 0x1: after last transfer for channel,reload buffer size and start address and restart channel |  | 
 | 0x10 | TX_SADDR |  |  |  |  |  |  |
 |  |  | SADDR | 11 | 0 | RW |  | Address of transmit buffer on write; current address on read | 
 | 0x14 | TX_SIZE |  |  |  |  |  |  | 
 |  |  | SIZE | 15 | 0 | RW |  | Size of receive buffer on write; bytes left on read | 
 | 0x18 | TX_CFG |  |  |  |  |  |  |
 |  |  | CLR | 6 | 6 | WO |  | Clear the transmit channel | 
 |  |  | PENDING | 5 | 5 | RO |  | Transmit transaction is pending | 
 |  |  | EN | 4 | 4 | RW |  | Enable the transmit channel |
 |  |  | CONTINUOUS | 0 | 0 | RW |  | 0x0: stop after last transfer for channel
 |  |  |            |   |   |    |  | 0x1: after last transfer for channel,reload buffer size and start address and restart channel |
 | 0x20 | STATUS |  |  |  |  |  |  |
 |  |  | RX_BUSY | 1 | 1 | RO |  | 0x1: receiver is busy |
 |  |  | TX_BUSY | 0 | 0 | RO |  | 0x1: transmitter is busy | 
 | 0x24 | UART_SETUP |  |  |  |  |  |  |
 |  |  | DIV | 31 | 16 | RW |  |  |
 |  |  | EN_RX | 9 | 9 | RW |  | Enable the reciever | 
 |  |  | EN_TX | 8 | 8 | RW |  | Enable the transmitter | 
 |  |  | RX_CLEAN_FIFO | 5 | 5 | RW |  | Empty the receive FIFO | 
 |  |  | RX_POLLING_EN | 4 | 4 | RW |  | Enable polling mode for receiver | 
 |  |  | STOP_BITS | 3 | 3 | RW |  | 0x0: 1 stop bit
 |  |  |           |   |   |    |  | 0x1: 2 stop bits |
 |  |  | BITS | 2 | 1 | RW |  | 0x0: 5 bit transfers
 |  |  |            |   |   |    |  | 0x1: 6 bit transfers
 |  |  |            |   |   |    |  | 0x2: 7 bit transfers
 |  |  |            |   |   |    |  | 0x3: 8 bit transfers  
 |  |  | PARITY_EN | 0 | 0 | RW |  | Enable parity |
 | 0x28 | ERROR |  |  |  |  |  |  |
 |  |  | PARITY_ERR | 1 | 1 | RC |  | 0x1 indicates parity error; read clears the bit | 
 |  |  | OVERFLOW_ERR | 0 | 0 | RC |  | 0x1 indicates overflow error; read clears the bit | 
 | 0x2C | IRQ_EN |  |  |  |  |  |  |
 |  |  | ERR_IRQ_EN | 1 | 1 | RW |  | Enable the error interrupt |
 |  |  | RX_IRQ_EN | 0 | 0 | RW |  | Enable the receiver interrupt |
 | 0x30 | VALID |  |  |  |  |  |  |
 |  |  | RX_DATA_VALID | 0 | 0 | RO |  | Cleared when RX_DATA is read |
 | 0x34 | DATA |  |  |  |  |  |  |
 |  |  | RX_DATA | 7 | 0 | RO |  | Receive data; reading clears RX_DATA_VALID | 

#### I2Cm
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### I2Cs
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### SPIm
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### QSPIm
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### CAMI
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### GPIO
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### PWM
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

### eFPGA
<!--
-->
 | Offset |Register |Field |MSB |LSB |Type |Default |Description |
 |--- | --- | --- | --- | --- | --- | --- | --- |
 | 0x00 | EX_CSR |  |  |  |  |  |  |
 |  |  | EX_FIELD | 31 | 0 | RW |  | Example Control/Status Register |

#### Overview
#### Programming the eFPGA
#### TCMD
#### APB
#### Math blocks
#### IO
#### Configuration
#### Test mode
