Memory Map
^^^^^^^^^^

This table reports the memory address map as described in
`core-v-mcu/rtl/includes/soc_mem_map.svh <https://github.com/openhwgroup/core-v-mcu/blob/master/rtl/includes/soc_mem_map.svh>`_.
The AXI plug is not reported as not implemented,
thus it should be treated as empty memory map space.


+-----------------------------+---------------------------+---------------------------+
| **Description**             | **Address Start**         | **Address End**           |
+=============================+===========================+===========================+
| **Boot ROM**                | 0x1A000000                | 0x1A03FFFF                |
+-----------------------------+---------------------------+---------------------------+
| **Peripheral Domain**       | 0x1A100000                | 0x1A2FFFFF                |
+-----------------------------+---------------------------+---------------------------+
| **eFPGA Domain**            | 0x1A300000                | 0x1A3FFFFF                |
+-----------------------------+---------------------------+---------------------------+
| **Memory Bank 0**           | 0x1C000000                | 0x1C007FFF                |
+-----------------------------+---------------------------+---------------------------+
| **Memory Bank 1**           | 0x1C008000                | 0x1C00FFFF                |
+-----------------------------+---------------------------+---------------------------+
| **Memory Bank Interleaved** | 0x1C010000                | 0x1C08FFFF                |
+-----------------------------+---------------------------+---------------------------+

The Peripheral Domain memory map is reported below as described in
`core-v-mcu/rtl/includes/periph_bus_defines.svh <https://github.com/openhwgroup/core-v-mcu/blob/master/rtl/includes/periph_bus_defines.svh>`_.
The Stdout emulator works only with RTL simulation and not
with FPGA or ASIC implementations.

+-----------------------------+---------------------------+---------------------------+
| **Description**             | **Address Start**         | **Address End**           |
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
| **Stdout emulator**         | 0x1A10F000                | 0x1A10FFFF                |
+-----------------------------+---------------------------+---------------------------+
| **Debug**                   | 0x1A110000                | 0x1A11FFFF                |
+-----------------------------+---------------------------+---------------------------+
| **eFPGA configuration**     | 0x1A200000                | 0x1A2F0000                |
+-----------------------------+---------------------------+---------------------------+
| **eFPGA HWCE**              | 0x1A300000                | 0x1A3F0000                |
+-----------------------------+---------------------------+---------------------------+

The memory map of the **Debug** region of the Peripheral Domain is documented as part of the PULP debug system. With the `Overview <https://github.com/pulp-platform/riscv-dbg/blob/master/doc/debug-system.md>`_, the `Debug Memory Map <https://github.com/pulp-platform/riscv-dbg/blob/master/doc/debug-system.md#debug-memory-map>`_ gives the offsets within the Debug region of the various parts of the debug module.

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

