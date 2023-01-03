..
   Copyright (c) 2023 OpenHW Group
   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

.. _terminology:

Terminology
===========

+-----------------+------------------------------------------------------------------------+
| Term            | Defintion                                                              |
+=================+========================================================================+
| APB             | Advanced Peripheral Bus. APB is a low-cost interface that is optimized |
|                 | for minimal power consumption and reduced interface complexity.        |
+-----------------+------------------------------------------------------------------------+
| CORE-V          | A family of RISC-V cores developed by the OpenHW Group.                |
+-----------------+------------------------------------------------------------------------+
| CORE-V-MCU      | A micro-controller based on the CV32E40P CORE-V processor core.        |
+-----------------+------------------------------------------------------------------------+
| CSRs            | Control and Status Registers.                                          |
+-----------------+------------------------------------------------------------------------+
| DMA             | Direct Memory Access.                                                  |
+-----------------+------------------------------------------------------------------------+
| uDMA, micro-DMA | Small, specific-purpose DMA controller supported by the CORE-V-MCU.    |
+-----------------+------------------------------------------------------------------------+
| L2              | Level 2.  In memory architectures L1 is typically a cache tightly      |
|                 | coupled to the core and L2 is a non-cached memory used for data store. |
+-----------------+------------------------------------------------------------------------+
| TCDM            | Tightly Coupled Data Memory.  Generic term for a memory architecure    |
|                 | that is purpose built for a specific application.                      |
+-----------------+------------------------------------------------------------------------+
| L2 TCDM         | Level 2 Memory Interconnect.  An SoC bus fabric tuned specifically to  |
| Interconnect    | provide high-bandwidth, low-latency connections to memory resources.   |
+-----------------+------------------------------------------------------------------------+
| XBUS_TCDM_BUS   | The I/O Bus used by the CORE-V-MCU L2 TCDM Interconnect.               |
+-----------------+------------------------------------------------------------------------+
| OBI             | Open Bus Interface. An open source bus specification.  OBI is used as  |
|                 | the Instruction fetch and Data load/store bus by the CVE cores such as |
|                 | the CV32E40P.                                                          |
+-----------------+------------------------------------------------------------------------+


