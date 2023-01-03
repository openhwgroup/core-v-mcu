..
   Copyright (c) 2023 OpenHW Group
   Copyright 2018 ETH Zurich and University of Bologna.

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

.. Level 1
   =======

   Level 2
   -------

   Level 3
   ~~~~~~~

   Level 4
   ^^^^^^^

.. _overview:

CORE-V-MCU Overview
===================
Welcome to the CORE-V-MCU User Manual!

The purpose of the CORE-V-MCU is to showcase the CV32E40P (v1.0.0), the first member of the OpenHW Group's CORE-V family of RISC-V cores.
The CORE-V-MCU also supports an embedded FPGA (eFPGA) provided by Quicklogic.
The eFPGA is a memory mapped resource for the CV32E40P core and may also be connected to the MCU's user I/O pins.
In addition, the CORE-V-MCU supports 512KB of on-chip SRAM and a rich set of peripherals:

* 2 UARTs
* 2 I2C masters
* 2 QSPI masters
* 1 I2C slave
* 1 CPI (Camera)
* 1 SDIO
* 4 PWM channels

The UARTs, I2C masters, QSPI, SDIO and Camera periphals transfer data to and from on-chip memory via a micro-DMA unit.

With the exception of the eFPGA, all of the above are open source artifacts, permissively licensed under Soldpad 2.0.

License
-------
Copyright 2022, 2023 OpenHW Group.

Copyright 2018 ETH Zurich and University of Bologna.

Copyright and related rights are licensed under the Solderpad Hardware License, Version 2.0 or newer (the “License”);
you may not use CORE-V-MCU source files except in compliance with the License.
You may obtain a copy of the License at http://solderpad.org/licenses.
Unless required by applicable law or agreed to in writing, software, hardware and materials distributed under this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

Standards Compliance
--------------------
The CORE-V-MCU processor core is the CV32E40P v1.0.0, a standards-compliant 32-bit RISC-V processor.
It follows these specifications:

- RISC-V Instruction Set Manual, Volume I: User-Level ISA, Document Version 20191213 (December 13, 2019)
- RISC-V Instruction Set Manual, Volume II: Privileged Architecture, document version 20190608-Base-Ratified (June 8, 2019). CV32E40P implements the Machine ISA version 1.11.
- RISC-V External Debug Support, draft version 0.13.2 (https://github.com/riscv/riscv-debug-spec/tree/4e0bb0fc2d843473db2356623792c6b7603b94d4)

In addition to the above, the CORE-V-MCU supports peripherals that adhere to one or more of the following standards:

- I2C: UM10204 - I2C-bus specification and user manual. Rev. 6 — 4 April 2014. NXP Semiconductors
- QSPI: defacto standard - please see the *QSPI Master* chapter of this User Manual for more information.
- SDIO: specification for the Secure Digital IO are maintained by the SD Association (https://www.sdcard.org)
- CPI: Camera Parallel Interface
- JTAG: 1149.7-2009 - IEEE Standard for Reduced-Pin and Enhanced-Functionality Test Access Port and Boundary-Scan Architecture


Implementation Note
-------------------
The first release of the CORE-V-MCU targets three physical implementations:

- Digilent Nexys A7 with the Xilinx Artix-7 XC7A100T FPGA.
- Digilent Genesys 2 with the Xilinx Kintex-7 XC7K325T FPGA.
- OpenHW ASIC implemented in GF-22FDX.

As far as possible, this User Manual attempts to be agnostic to the implementation.
Details of a specific implementation, such as device pin-outs, will be provided as needed.

An Open Source Project
----------------------
We encourage people to get involved and contribute to this project.
Please have a look at the *Open Source Development at the OpenHW Group* chapter of this User Manual.

Configuring CORE-V-MCU
----------------------
The open source nature of this project enables the user to port the CORE-V-MCU to almost any implementation technology and to alter is configuration.
In fact, the repository is organizated to simplify the task of customizing an implementation.
For example, a set of macros (tick defines) in ``rtl/includes/pulp_soc_defines.svh`` defines which micro-DRAM peripherals (and how many) are incorporated in the build.
Generate statements in the RTL are in place to instanitate the correct peripheral set as per pulp_soc_defines.svh, and a python script at ``util/ioscript.py`` *should* extract some useful documentation and configuration data to be used during simulation and synthesis.
Please note that these capabilties have not been extensively tested and only the peripheral set and physical implementations defined above are known to build properly.

