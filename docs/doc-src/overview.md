# Overview: CORE_V_MCU

## Purpose
The purpose of the core-v-mcu is to showcase the cv32e40p fully verified RISC-V core available from the Open Hardware Group.
The cv32e40p core is connected to a representative set of peripherals:

* 2xUART
* 2xI2C master
* 1xI2C slave
* 2xQSPI master
* 1xCAMERA
* 1xSDIO
* 4xPWM

as well as an eFPGA accelerator with 4 math units.

The system supports 512KB of SRAM and 2 PLLs.

![Block Diagram](../images/core-v-mcu-block-diagram.png)


## Development Kits
The core-v-mcu is delivered as either:

* a Xilinx bitstream that runs on the Digilent Nexsy A7 board
* a Xilinx bitstream that runs on the Digilent Genesys2 board
* an SOC implemented with GLOBAFOUNDRIES 22nm fdx SOI technology that runs on an Open Hardware Group HDK1 board

All boards have multiple PMOD connectors that suport various PMOD modules which are used to connect debug and various peripherals.