..
   Copyright (c) 2023 OpenHW Group
   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. _terminology:

Terminology
===========

+-----------------+------------------------------------------------------------------------------+
| Term            | Defintion                                                                    |
+=================+==============================================================================+
| APB             | Advanced Peripheral Bus. APB is a low-cost interface that is optimized       |
|                 | for minimal power consumption and reduced interface complexity.              |
+-----------------+------------------------------------------------------------------------------+
| CSRs            | Control and Status Registers.                                                |
+-----------------+------------------------------------------------------------------------------+
| Core Complex    | In the CORE-V-MCU, the Core Complex is a SystemVerilog module instantiating  |
|                 | the processor core.                                                          |
+-----------------+------------------------------------------------------------------------------+
| CORE-V          | A family of RISC-V cores developed by the OpenHW Group.                      |
+-----------------+------------------------------------------------------------------------------+
| CORE-V-MCU      | A micro-controller based on the CV32E40P CORE-V processor core.              |
+-----------------+------------------------------------------------------------------------------+
| DMA             | Direct Memory Access.                                                        |
+-----------------+------------------------------------------------------------------------------+
| eFPGA           | Embedded Field Programmable Gate Array. The CORE-V-MCU supports an eFPGA.    |
+-----------------+------------------------------------------------------------------------------+
| uDMA, micro-DMA | Small, specific-purpose DMA controller supported by the CORE-V-MCU.          |
+-----------------+------------------------------------------------------------------------------+
| L1, L2          | Level 1, Level 2. In memory architectures L1 typically refers to a           |
|                 | cache memory that is tightly tightly coupled to the core and L2 is a         |
|                 | non-cached memory used for data store.                                       |
|                 |                                                                              |
|                 | The CORE-V-MCU does not support an L1 cache for either instructions or data. |
|                 | The CORE-V-MCU Core Complex, eFPGA and uDMA Subsystems all access L2         |
|                 | memory via the TCDM Interconnect.                                            |
+-----------------+------------------------------------------------------------------------------+
| TCDM            | Tightly Coupled Data Memory.  Generic term for a memory architecure          |
|                 | that is purpose built for a specific application.                            |
+-----------------+------------------------------------------------------------------------------+
| TCDM            | Level 2 Memory Interconnect.  An SoC bus fabric tuned specifically to        |
| Interconnect    | provide high-bandwidth, low-latency connections to memory resources.         |
+-----------------+------------------------------------------------------------------------------+
| XBUS_TCDM_BUS   | The I/O Bus used by the CORE-V-MCU TCDM Interconnect.                        |
+-----------------+------------------------------------------------------------------------------+
| OBI             | Open Bus Interface. An open source bus specification.  OBI is used as        |
|                 | the Instruction fetch and Data load/store bus by the CVE cores such as       |
|                 | the CV32E40P.                                                                |
+-----------------+------------------------------------------------------------------------------+


