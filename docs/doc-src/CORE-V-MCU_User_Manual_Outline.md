<!--
NOTE: this document is intended to capture an outline of the CORE-V-MCU User Manual, currently under development.
Once the outline has been agreed to, this document will be deprecated and replaced.
-->
# CORE-V-MCU User Manual

## Introduction
The CORE-V-MCU showcases the [CV32E40P](https://cv32e40p.readthedocs.io/en/latest/intro), a fully verified open-source RISC-V core supported by the Open Hardware Group in a SoC design.
In addition to the CV32E40P core the SoC provides 512 KBytes of SRAM, a set of standard Peripherals and an embedded FPGA.
Three independent PLLs provide flexible clocking for the CPU, the peripherals and the eFPGA.
An internal bootrom allows for booting from a SPI flash or under host control via an I2C slave interface along with a JTAG interface for debugging.

The following peripherals are equipped:

* 2 UART
* QSPI master
* 2 I2C master
* 1 Parallel CAMERA
* 1 SDIO
* 1 I2C slave
* 32 GPIO
* 4 advanced timer blocks with PWM
* 1 eFPGA with 4 math units
* Event Generator for Interrupt processing
* Fast Interrupt capability


![Block Diagram](../images/core-v-mcu-block-diagram.png)

### UART
The uart equipped on the SoC are udma peripherals that allow efficient transfer of data.

### QSPI master
The QSPI master utilized the udma supsystem to efficiently transfer datato/from memory. It can operate in x1, x2 or x4 mode and can be used by the bootrom to load memory and transfer control. When booting from SPI the interface runs in x1 mode.

### I2C master
Two I2C master interfaces are provided.  They utilize the udma subsystem for transfer to and from memory.

### Parallel Camera
An 11-bit camera interface with 3 control inputs (CLK, HSYNC, VSYNC) and 8 data inputs is provided with a udma interface to transfer frames to memory.
The interface is compatible with the HiMax HM01B0 low power image sensor.

### SDIO
SDIO interface may be included -- TBD

### I2C Slave
An I2C slave interface is provided for host communication to the SoC. It is directly controlled as an APB peripheral with 2 256-Byte Fifos for reciept and transmission of data.

### GPIO
The Soc provides 32 GPIO pins that can multiplexed  from the internal gpio registers to the IO of the device.
Each GPIO is independent and supports Open collector output, loopback from the PAD, programmable pullup/pulldown and several drive strengths. Additionally, interrupts via the event generator can be enabled for level or edge sensitive triggers.

### Advanced Timer
An advanced timer block with four independent timers each with 4 output channels can be programmebe to generate PWM outputs.

### EFPGA
A Quicklogic ArcticPro 2 eFPGA with four math Blocks is equipped. The EFPGA contains approximately 1000 SLC each with 4 lut/ff elements. 2 Math units are provided, each math unit contains 3 4kx32 bit Dual port RAMs and 2 Multiplier units.
the RAMS cna be configures to be 8/16/or 32 bit width independently on the read and write ports.  The mulitpliers can be configured to be a 32x32, 2 -16x16, 4 8x8, or 8 4x4 multipliers.
The EFPGA has a primary APB sytle interface to the SoC and can be addressed as a stadard peripheral.  In addition the CPU controlled APB interface the EFPGA has access to 4 TCDM (Tightly Coupled Distributed Memory) interfaces that allow the EFPGA to independently read and write the System Memory.
The EFPGA had 16 dedicated interrupt output signals to the SoC Event Generator along with 40 FPGAIO that can send and recieve data from the device PADs.

### EVENT Generator
The event Generator collects events (interrupts) from all the udma peripherals (each udma channel has 4 interrupts allocated), the GPIO and the EFPGA for presentation to the CPU via set of FIFOs which presnt the interrupts in a round robin fashion

### Fast Interrupts
The CV32E40P core provides for Fast interrupts that allow quick response. The interrupts are directly vectored from the MTVEC.

## Hardware Implementations
The CORE-V-MCU is delivered as either:

* a Xilinx bitstream that runs on the Digilent Nexsy A7 board
* a Xilinx bitstream that runs on the Digilent Genesys2 board
* an ASIC implemented with GLOBALFOUNDRIES 22nm fdx SOI technology that runs on the Open Hardware Group CORE-V-MCU HWDK board
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

## Memory Map
### Peripheral Control and Status Registers
#### UDMA
<!--
TODO: CSR table for UDMA goes here:
-->
 | Offset | Register | Field       | MSB | LSB | Access | PoR        | Description                                                                                        |
 |------- | -------- | ----------- | ---:| ---:| ------:|:---------- | -------------------------------------------------------------------------------------------------- |
 | 0x00   | EX_CSR0  |             |     |     |        |            | Example single line REGISTER description for CSR ``EX_CSR0``                                       |
 |        |          | EX_FIELD0.0 | 31  | 0   | RW     | 0x12340005 | Example single line FIELD description for ``EX_FIELD0.0 ``                                         |
 | 0x04   | EX_CSR1  |             |     |     | RW     |            | Another example REGISTER description for CSR ``EX_CSR1``                                           |
 |        |          | EX_FIELD1.0 | 31  | 16  | RW     | 0x0005     | Another FIELD description for ``EX_FIELD1.0``                                                      |
 |        |          | EX_FIELD1.1 | 15  | 0   | RW     | 0x5550     | Example multi-line FIELD description<br> for more complex field ``EX_FIELD1.1``                    |

#### UART
<!--
This is the real CSR description description for the UART:
-->
 | Offset | Register   | Field         | MSB | LSB | Access | PoR | Description                                                                                                                                 |
 |------- | ---------- | ------------- | ---:| ---:| ------:|:--- | ------------------------------------------------------------------------------------------------------------------------------------------- |
 | 0x00   | RX_SADDR   |               |     |     |        |     |                                                                                                                                             |
 |        |            | SADDR         | 11  | 0   | RW     |     | Address of receive buffer on write<br> current address on read                                                                              |
 | 0x04   | RX_SIZE    |               |     |     |        |     |                                                                                                                                             |
 |        |            | SIZE          | 15  | 0   | RW     |     | Size of receive buffer on write; bytes left on read                                                                                         |
 | 0x08   | RX_CFG     |               |     |     |        |     |                                                                                                                                             |
 |        |            | CLR           | 6   | 6   | WO     |     | Clear the receive channel                                                                                                                   |
 |        |            | PENDING       | 5   | 5   | RO     |     | Receive transaction is pending                                                                                                              |
 |        |            | EN            | 4   | 4   | RW     |     | Enable the receive channel                                                                                                                  |
 |        |            | CONTINUOUS    | 0   | 0   | RW     |     | 0x0: stop after last transfer for channel<br> 0x1: after last transfer for channel,reload buffer size and start address and restart channel |
 | 0x10   | TX_SADDR   |               |     |     |        |     |                                                                                                                                             |
 |        |            | SADDR         | 11  | 0   | RW     |     | Address of transmit buffer on write<br> current address on read                                                                             |
 | 0x14   | TX_SIZE    |               |     |     |        |     |                                                                                                                                             |
 |        |            | SIZE          | 15  | 0   | RW     |     | Size of receive buffer on write; bytes left on read                                                                                         |
 | 0x18   | TX_CFG     |               |     |     |        |     |                                                                                                                                             |
 |        |            | CLR           | 6   | 6   | WO     |     | Clear the transmit channel                                                                                                                  |
 |        |            | PENDING       | 5   | 5   | RO     |     | Transmit transaction is pending                                                                                                             |
 |        |            | EN            | 4   | 4   | RW     |     | Enable the transmit channel                                                                                                                 |
 |        |            | CONTINUOUS    | 0   | 0   | RW     |     | 0x0: stop after last transfer for channel<br> 0x1: after last transfer for channel,reload buffer size and start address and restart channel |
 | 0x20   | STATUS     |               |     |     |        |     |                                                                                                                                             |
 |        |            | RX_BUSY       | 1   | 1   | RO     |     | 0x1: receiver is busy                                                                                                                       |
 |        |            | TX_BUSY       | 0   | 0   | RO     |     | 0x1: transmitter is busy                                                                                                                    |
 | 0x24   | UART_SETUP |               |     |     |        |     |                                                                                                                                             |
 |        |            | DIV           | 31  | 16  | RW     |     |                                                                                                                                             |
 |        |            | EN_RX         | 9   | 9   | RW     |     | Enable the reciever                                                                                                                         |
 |        |            | EN_TX         | 8   | 8   | RW     |     | Enable the transmitter                                                                                                                      |
 |        |            | RX_CLEAN_FIFO | 5   | 5   | RW     |     | Empty the receive FIFO                                                                                                                      |
 |        |            | RX_POLLING_EN | 4   | 4   | RW     |     | Enable polling mode for receiver                                                                                                            |
 |        |            | STOP_BITS     | 3   | 3   | RW     |     | 0x0: 1 stop bit<br> 0x1: 2 stop bits                                                                                                        |
 |        |            | BITS          | 2   | 1   | RW     |     | 0x0: 5 bit transfers<br> 0x1: 6 bit transfers<br> 0x2: 7 bit transfers<br> 0x3: 8 bit transfers                                             |
 |        |            | PARITY_EN     | 0   | 0   | RW     |     | Enable parity                                                                                                                               |
 | 0x28   | ERROR      |               |     |     |        |     |                                                                                                                                             |
 |        |            | PARITY_ERR    | 1   | 1   | RC     |     | 0x1 indicates parity error; read clears the bit                                                                                             |
 |        |            | OVERFLOW_ERR  | 0   | 0   | RC     |     | 0x1 indicates overflow error; read clears the bit                                                                                           |
 | 0x2C   | IRQ_EN     |               |     |     |        |     |                                                                                                                                             |
 |        |            | ERR_IRQ_EN    | 1   | 1   | RW     |     | Enable the error interrupt                                                                                                                  |
 |        |            | RX_IRQ_EN     | 0   | 0   | RW     |     | Enable the receiver interrupt                                                                                                               |
 | 0x30   | VALID      |               |     |     |        |     |                                                                                                                                             |
 |        |            | RX_DATA_VALID | 0   | 0   | RO     |     | Cleared when RX_DATA is read                                                                                                                |
 | 0x34   | DATA       |               |     |     |        |     |                                                                                                                                             |
 |        |            | RX_DATA       | 7   | 0   | RO     |     | Receive data; reading clears RX_DATA_VALID                                                                                                  |

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

## Programming the eFPGA
### TCMD
### APB
### Math blocks
### IO
### Configuration
### Test mode
