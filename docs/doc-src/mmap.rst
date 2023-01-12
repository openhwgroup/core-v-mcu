..
   Copyright (c) 2023 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. Level 1
   =======

   Level 2
   -------

   Level 3
   ~~~~~~~

   Level 4
   ^^^^^^^

.. _memory_map:

Memory Map
==========

This table reports the "Top-Level" memory address map as seen by the core.
The Peripheral and eFPGA domains are address ranges which support a set of memory mapped peripherals and the eFPGA resources respectively.
As shown in the Block Diagram, there are two non-interleaved memory banks.
Typically these memories are used for code-store and the stack, although there is no requirement for this.
The interleaved memory is typically used for program data-store and micro-DMA data buffers.

+-----------------------------------+--------------------+------------------+
| **Description**                   | **Address Start**  | **Address End**  |
+===================================+====================+==================+
|   Boot ROM**                      | 0x1A00-0000        | 0x1A03-FFFF      |
+-----------------------------------+--------------------+------------------+
|   Peripheral Domain               | 0x1A10-0000        | 0x1A2F-FFFF      |
+-----------------------------------+--------------------+------------------+
|   eFPGA Domain                    | 0x1A30-0000        | 0x1A3F-FFFF      |
+-----------------------------------+--------------------+------------------+
|   Non-Interleaved Memory Bank 0   | 0x1C00-0000        | 0x1C00-7FFF      |
+-----------------------------------+--------------------+------------------+
|   Non-Interleaved Memory Bank 1   | 0x1C00-8000        | 0x1C00-FFFF      |
+-----------------------------------+--------------------+------------------+
|   Interleaved Memory              | 0x1C010000         | 0x1C07FFFF       |
+-----------------------------------+--------------------+------------------+

Memory locations in the peripheral domain are used to access Control and Status Registers (CSRs) used to control the CORE-V-MCU IP blocks.

+-----------------------------+---------------------------+---------------------------+
| **CORE-V-MCU IP Block**     | **Address Start**         | **Address End**           |
+=============================+===========================+===========================+
|  APB Frequency-locked loop  | 0x1A10-0000               | 0x1A10-0FFC               |
+-----------------------------+---------------------------+---------------------------+
|  APB GPIOs                  | 0x1A10-1000               | 0x1A10-1FFC               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA                       | 0x1A10-2000               | 0x1A10-3FFC               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA UART0                 | 0x1A10-2080               | 0x1A10-20FC               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA UART1                 | 0x1A10-2100               | 0x1A10-217C               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA QSPI0                 | 0x1A10-2180               | 0x1A10-21FC               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA QSPI1                 | 0x1A10-2200               | 0x1A10-227C               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA I2CM0                 | 0x1A10-2280               | 0x1A10-22FC               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA I2CM1                 | 0x1A10-2300               | 0x1A10-237C               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA SDIO                  | 0x1A10-2380               | 0x1A10-23FC               |
+-----------------------------+---------------------------+---------------------------+
|  uDMA CAMERA                | 0x1A10-2400               | 0x1A10-247C               |
+-----------------------------+---------------------------+---------------------------+
|  APB SoC Controller         | 0x1A10-4000               | 0x1A10-4FFC               |
+-----------------------------+---------------------------+---------------------------+
|  APB Advanced Timer         | 0x1A10-5000               | 0x1A10-5FFC               |
+-----------------------------+---------------------------+---------------------------+
|  APB SoC Event Controller   | 0x1A10-6000               | 0x1A10-6FFC               |
+-----------------------------+---------------------------+---------------------------+
|  APB I2CS                   | 0x1A10-7000               | 0x1A10-7FFC               |
+-----------------------------+---------------------------+---------------------------+
|  APB Timer                  | 0x1A10-B000               | 0x1A10-BFFC               |
+-----------------------------+---------------------------+---------------------------+
|  stdout emulator            | 0x1A10-F000               | 0x1A10-FFFC               |
+-----------------------------+---------------------------+---------------------------+
|  Debug                      | 0x1A11-0000               | 0x1A11-FFFC               |
+-----------------------------+---------------------------+---------------------------+
|  eFPGA configuration        | 0x1A20-0000               | 0x1A2F-0000               |
+-----------------------------+---------------------------+---------------------------+

Note that the stdout emulator works only with RTL simulation and not with FPGA or ASIC implementations.


CSR Access Types:
-----------------

+-------------+---------------------------------------------------------------------+
| Access Type | Description                                                         |
+=============+=====================================================================+
| RW          | Read & Write                                                        |
+-------------+---------------------------------------------------------------------+
| RO          | Read Only                                                           |
+-------------+---------------------------------------------------------------------+
| RC          | Read & Clear after read                                             |
+-------------+---------------------------------------------------------------------+
| WO          | Write Only                                                          |
+-------------+---------------------------------------------------------------------+
| WC          | Write Clears (value ignored; always writes a 0)                     |
+-------------+---------------------------------------------------------------------+
| WS          | Write Sets (value ignored; always writes a 1)                       |
+-------------+---------------------------------------------------------------------+
| RW1S        | Read & on Write bits with 1 get set, bits with 0 left unchanged     |
+-------------+---------------------------------------------------------------------+
| RW1C        | Read & on Write bits with 1 get cleared, bits with 0 left unchanged |
+-------------+---------------------------------------------------------------------+
| RW0C        | Read & on Write bits with 0 get cleared, bits with 1 left unchanged |
+-------------+---------------------------------------------------------------------+

Implementation Details
----------------------
The Top-level address map is defined in
`core-v-mcu/rtl/includes/soc_mem_map.svh <https://github.com/openhwgroup/core-v-mcu/blob/master/rtl/includes/soc_mem_map.svh>`_.

The Peripheral Domain memory map is reported below as described in
`core-v-mcu/rtl/includes/periph_bus_defines.svh <https://github.com/openhwgroup/core-v-mcu/blob/master/rtl/includes/periph_bus_defines.svh>`_.

The memory map of the **Debug** region of the Peripheral Domain is documented as part of the PULP debug system.
With the
`Overview <https://github.com/pulp-platform/riscv-dbg/blob/master/doc/debug-system.md>`_,
the
`Debug Memory Map <https://github.com/pulp-platform/riscv-dbg/blob/master/doc/debug-system.md#debug-memory-map>`_
gives the offsets within the Debug region of the various parts of the debug module.
