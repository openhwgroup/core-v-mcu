Memory Map
^^^^^^^^^^

This table reports the "Top-Level" memory address map as seen by the core.
The Peripheral and eFPGA domains are address ranges which support a set of memory mapped peripherals and the eFPGA resources respectively.
As shown in the Block Diagram, there are two non-interleaved memory banks.
Typically these memories are used for code-store and the stack, although there is no requirement for this.
The interleaved memory is typically used for program data-store and micro-DMA data buffers.

+-----------------------------------+--------------------+------------------+
| **Description**                   | **Address Start**  | **Address End**  |
+===================================+====================+==================+
| **Boot ROM**                      | 0x1A000000         | 0x1A03FFFF       |
+-----------------------------------+--------------------+------------------+
| **Peripheral Domain**             | 0x1A100000         | 0x1A2FFFFF       |
+-----------------------------------+--------------------+------------------+
| **eFPGA Domain**                  | 0x1A300000         | 0x1A3FFFFF       |
+-----------------------------------+--------------------+------------------+
| **Non-Interleaved Memory Bank 0** | 0x1C000000         | 0x1C007FFF       |
+-----------------------------------+--------------------+------------------+
| **Non-Interleaved Memory Bank 1** | 0x1C008000         | 0x1C00FFFF       |
+-----------------------------------+--------------------+------------------+
| **Interleaved Memory**            | 0x1C010000         | 0x1C07FFFF       |
+-----------------------------------+--------------------+------------------+

Memory locations in the peripheral domain are used to access Control and Status Registers (CSRs) used to control the CORE-V-MCU IP blocks.

+-----------------------------+---------------------------+---------------------------+
| **CORE-V-MCU IP Block**     | **Address Start**         | **Address End**           |
+=============================+===========================+===========================+
| **Frequency-locked loop**   | 0x1A100000                | 0x1A100FFF                |
+-----------------------------+---------------------------+---------------------------+
| **GPIOs**                   | 0x1A101000                | 0x1A101FFF                |
+-----------------------------+---------------------------+---------------------------+
| **uDMA**                    | 0x1A102000                | 0x1A103FFF                |
+-----------------------------+---------------------------+---------------------------+
| **SoC Controller**          | 0x1A104000                | 0x1A104FFF                |
+-----------------------------+---------------------------+---------------------------+
| **Advanced Timer**          | 0x1A105000                | 0x1A105FFF                |
+-----------------------------+---------------------------+---------------------------+
| **SoC Event Generator**     | 0x1A106000                | 0x1A106FFF                |
+-----------------------------+---------------------------+---------------------------+
| **I2CS**                    | 0x1A107000                | 0x1A107FFF                |
+-----------------------------+---------------------------+---------------------------+
| **Timer**                   | 0x1A10B000                | 0x1A10BFFF                |
+-----------------------------+---------------------------+---------------------------+
| **stdout emulator**         | 0x1A10F000                | 0x1A10FFFF                |
+-----------------------------+---------------------------+---------------------------+
| **Debug**                   | 0x1A110000                | 0x1A11FFFF                |
+-----------------------------+---------------------------+---------------------------+
| **eFPGA configuration**     | 0x1A200000                | 0x1A2F0000                |
+-----------------------------+---------------------------+---------------------------+
| **eFPGA HWCE**              | 0x1A300000                | 0x1A3F0000                |
+-----------------------------+---------------------------+---------------------------+

Note that the stdout emulator works only with RTL simulation and not with FPGA or ASIC implementations.


CSR Access Types:
~~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~~~~~~~
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
