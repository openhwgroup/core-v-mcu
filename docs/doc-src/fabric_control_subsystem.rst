..
   Copyright (c) 2023 OpenHW Group
   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

.. _fabric_control_subsystem:

Fabric Control Subsystem
========================
The fabric control subsystem in the CORE-V-MCU is so-named because it drives the primary control interfaces into the L2 TCDM Interconnect.
These interfaces view the entire memory map of the MCU as a single flat address space.
This address space includes memories and peripheral CSRsi, including those CSRs accessible via the Micro-DMA and/or the APB Interconnect.

In the CORE-V-MCU the primary component of the Fabric Control Subsystem is the CORE-V CV32E40P processor core.
Future MCUs based on the CORE-V-MCU could implement the Fabric Subsystem to host multiple cores and/or hardware accelerators.

CV32E40P Description
--------------------

Short summary and link to Core documentation

CV32E40P IP Configuration
-------------------------


