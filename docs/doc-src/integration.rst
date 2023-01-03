..
   Copyright (c) 2022 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

.. _core-v-mcu-integration:

CORE-V-MCU Integration
======================

The top-level module is named ``core_v_mcu`` and can be found in ``rtl/core-v-mcu/top/core_v_mcu.sv``.
Below, the instantiation template is given and the parameters and interfaces are described.

Instantiation Template
----------------------

.. code-block:: verilog

   module core_v_mcu #(
       .USE_FPU    ( 0 ),
       .USE_HWPE   ( 0 )
    ) (
       // Test and Debug control
       .jtag_tck_i  (),
       .jtag_tdi_i  (),
       .jtag_tdo_o  (),
       .jtag_tms_i  (),
       .jtag_trst_i (),

       // Clock and reset
       .ref_clk_i   (),
       .slow_clk_o  (),
       .rstn_i      (),

       // Configuration
       .bootsel_i   (),
       .stm_i       (),

       // Peripheral I/O and associated configuration
       .io_in_i     (),      // [`N_IO-1:0]
       .io_out_o    (),      // [`N_IO-1:0]
       .pad_cfg_o   (),      // [`N_IO-1:0][`NBIT_PADCFG-1:0]
       .io_oe_o     ()       // [`N_IO-1:0]
   );

Parameters
----------

.. note::
   The CORE-V-MCU is also configurable with a large set of localparams that are not visible to the top-level module.
   A future release will bring all of these up to the top-level module.

+------------------------------+-------------+------------+------------------------------------------------------------------+
| Name                         | Type/Range  | Default    | Description                                                      |
+==============================+=============+============+==================================================================+
| ``USE_FPU``                  | bit         | 0          | Compile the Floating Point Unit (FPU) and enable floating point  |
|                              |             |            | support in the CV32E40P core. As floating point is not supported |
|                              |             |            | in v1.0.0 of the CV32E40P, this parameter is set to zero.        |
+------------------------------+-------------+------------+------------------------------------------------------------------+
| ``USE_HWPE``                 | bit         | 0          | Compile support for a Hardware Processing Engine. Not supported. |
+------------------------------+-------------+------------+------------------------------------------------------------------+

Macros
------

.. note::
   A future release of the CORE-V-MCU will implement these macros as top-level parameters.

+------------------------------+-------------+------------+-------------------------------------------------------------------+
| Name                         | Type/Range  | Default    | Description                                                       |
+==============================+=============+============+===================================================================+
| ``N_IO``                     | int         | 48         | Number of user-selectable I/O pins.                               |
|                              |             |            | Note that not all I/O pins are selectable, see the I/O Assignment |
|                              |             |            | Tables for more information.                                      |
+------------------------------+-------------+------------+-------------------------------------------------------------------+
| ``NBIT_PADCFG``              | int         | 6          | Implementation-dependent IO PAD configuration.                    |
+------------------------------+-------------+------------+-------------------------------------------------------------------+

Interfaces
----------

+-------------------------+--------------------+-----+--------------------------------------------+
| Signal(s)               | Width              | Dir | Description                                |
+=========================+====================+=====+============================================+
| ``jtag_tck_i``          | 1                  | in  | JTAG Test Clock                            |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``jtag_tdi_i``          | 1                  | in  | JTAG Test Data In                          |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``jtag_tdo_o``          | 1                  | out | JTAG Test Data Out                         |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``jtag_tms_i``          | 1                  | in  | JTAG Test Mode Select                      |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``jtag_trst_i``         | 1                  | in  | JTAG Test Reset                            |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``ref_clk_i``           | 1                  | in  | Reference Clock                            |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``slow_clk_o``          | 1                  | out | Output clock generated from ref_clk_i.     |
|                         |                    |     | Frequency is implementation dependent.     |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``rstn_i``              | 1                  | in  | Active-low asynchronous reset              |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``bootsel_i``           | 1                  | in  | Boot select.                               |
|                         |                    |     | 1: boot from internal bootrom.             |
|                         |                    |     | 0: boot from external memory on QSPI port. |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``io_in_i``             | N_IO               | in  | Port's input signal                        |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``io_out_o``            | N_IO               | out | Port's input signal                        |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``pad_cfg_o``           | N_IO * NBIT_PADCFG | out | PAD configuration                          |
|                         |                    |     | (implementation dependent)                 |
+-------------------------+--------------------+-----+--------------------------------------------+
| ``io_oe_o``             | N_IO               | out | Port's Output Enable                       |
|                         |                    |     | 1: IO = io_out_o.                          |
|                         |                    |     | 0: io_in_i = IO.                           |
+-------------------------+--------------------+-----+--------------------------------------------+
