# CORE-V-MCU Overview

The purpose of the CORE-V-MCU is to showcase the CV32E40P (v1.0.0), the first member of the OpenHW Group's CORE-V family of RISC-V cores.
The CORE-V-MCU also supports an embedded FPGA (eFPGA) provided by Quicklogic.
The eFPGA is a memory mapped resource for the CV32E40P core and may also be connected to the MCU's user I/O pins.
In addition, the CORE-V-MCU supports 512KB of on-chip SRAM and a rich set of peripherals:

* 2 UARTs
* 2 I2C masters
* 2 QSPI masters
* 1 I2C slave
* 1 CAMERA
* 1 SDIO
* 4 PWM channels

The UARTs, I2C masters, QSPI, SDIO and Camera periphals transfer data to and from on-chip memory via a micro-DMA unit.

![Block Diagram](../images/CORE-V-MCU_Block_Diagram.png)

## Implementation Note
The first release of the CORE-V-MCU targets three physical implementations:

* Digilent Nexys A7 with Xilinx Artix-7 XC7A100T FPGA
* Digilent Genesys 2 with Xilinx Kintex-7 XC7K325T FPGA
* OpenHW ASIC implemented in GF-22FDX

As far as possible, this User Manual attempts to be agnotic to the implementation.
Details of a specific implementation, such as device pin-outs, will be provided as needed.

The open source nature of project enables the user to port the CORE-V-MCU to almost any implementation technology.
In fact, the repository is organizated to simplify the task of customizing an implementation.
For example, a set of registers in soc_ctrl defines which peripherals and how many are incorporated in the build.
The soc_ctrl documenation reports the configuration when the documentation is generated,
however that may not be in sync with the configuration when the RTL was built.

