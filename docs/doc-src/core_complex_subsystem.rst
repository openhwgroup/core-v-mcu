..
   Copyright (c) 2023 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. _core_complex_subsystem:

Core Complex Subsystem
=======================
The core complex subsystem in the CORE-V-MCU drives the primary control interfaces into the TCDM Interconnect.
These interfaces view the entire memory map of the MCU as a single flat address space.
This address space includes memories and peripheral CSRs, including those CSRs accessible via the Micro-DMA and/or the APB Interconnect.

In the CORE-V-MCU the only component of the core complex subsystem is the CORE-V CV32E40P processor core.
Future MCUs based on the CORE-V-MCU could implement the core control subsystem to host multiple cores and/or hardware accelerators.

.. note::
   In the RTL implementation of CORE-V-MCU the core complex is named the fabric control subsystem or fc_subsystem.
   This name is an historical artefact from the PULP Platform heritage of the CORE-V-MCU.
   It name was changed to reflect its use in the OpenHW Group implementation.

CV32E40P Description
--------------------

The CORE-V-MCU incorporates v1.0.0 of the CV32E40P.
Please see the `CV32E40P User Manual <https://docs.openhwgroup.org/projects/cv32e40p-user-manual/en/latest/>`_ for details.

