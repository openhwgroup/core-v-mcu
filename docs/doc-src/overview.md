# CORE-V-MCU Overview

The purpose of the core-v-mcu is to showcase the cv32e40p (v1.0.0), a fully verified RISC-V core available from the Open Hardware Group.
The cv32e40p core is connected to a representative set of peripherals:

* 2xUART
* 2xI2C master
* 1xI2C slave
* 2xQSPI master
* 1xCAMERA
* 1xSDIO
* 4xPWM
* eFPGA with 4 math units

In addition, the core-v-mcu supports an embedded FPGA (eFPGA) provided by Quicklogic.

<!--
__Note:__ A set of registers in soc_ctrl defines which peripherals and how many were incorporated in the build.
The soc_ctrl documenation reports the configuration when the documentation was generated, however that may not be in sync with the
configuration when the RTL was built.

The system supports 512KB of SRAM and 3 PLLs.
-->

![Block Diagram](../images/CORE-V-MCU_Block_Diagram.png)



