..
   Copyright (c) 2023 OpenHW Group
   Copyright 2018 ETH Zurich and University of Bologna.

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. Level 1
   =======

   Level 2
   -------

   Level 3
   ~~~~~~~

   Level 4
   ^^^^^^^

.. _io_assignment_tables:

I/O Assignment Tables
=====================

CORE-V-MCU Integration suggests that the MCU supports nine dedicated-function ports and a set of 48 user-selectable IO ports.
However, the number of user-selectable IO ports is less than the total number of I/O signals supported by the CORE-V-MCU's internal peripheral functions.
An internal IO-MUX is used to connect a subset of peripheral I/O to top-level CORE-V-MCU IO ports.
The peripheral functions selectable via the IO-MUX are:

* **uart0..1**: I/O signals for one of two simple Universal Asynchronous Receiver/Transmitters.
* **qspim0..1**: I/O signals for one of two Queued Serial Peripheral Interface masters.
* **i2cm0..1**: I/O signals for one of two Inter-Integrated Circuit bus masters.
* **i2cs**: I/O signals for the Inter-Integrated Circuit bus slave.
* **gpio_0..31**: One of 32 general purpose I/O signals driven by the GPIO module.
* **pwm_chX.Y**: Outputs of four PWMs supported by the Advanced Timer module.
* **fpgaio_0..31**: One of 32 general purpose I/O signals driven by the eFPGA.
* **cam0**: Camera (cpi) interface.
* **sdio**: SDIO Card.

Per-port control of the IO-MUX is via the **IO_CTRL[0..47]** CSRs starting at offset 0x0400.
**Note**: only 40 of the user-selectable IO ports are available to the user.
These are IO_7 to IO_43 and IO_45 to IO_47.

The table below provides the mapping between the above peripheral I/O and the 40 user-selectable IO ports of the CORE-V-MCU.
Headings have the following meaning:

* **IO_PORT**: user-selectable top-level port of core-v-mcu.sv.
* **IO_CTRL.MUX=0..3**: the value of the MUX field of the IO_CTRL CSR for the specified IO_PORT.

+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_PORT   | IO_CTRL.MUX=0 | IO_CTRL.MUX=1 | IO_CTRL.MUX=2 | IO_CTRL.MUX=3 | Note                                        |
+===========+===============+===============+===============+===============+=============================================+
| IO_0..6   | IO_0..6 are not selectable                                                                                  |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_7      | uart0_rx      |               | gpio_0        | efpgaio_0     | gpio_0 may also appear on IO_12 or IO_43    |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_8      | uart0_tx      |               | gpio_1        | efpgaio_1     | gpio_1 may also appear on IO_17             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_9      | uart1_tx      |               | gpio_2        | efpgaio_2     | gpio_2 may also appear on IO_18             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_10     | uart1_rx      |               | gpio_3        | efpgaio_3     |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_11     | pwm_ch0.0     | pwm_ch3.3     | gpio_4        | efpgaio_4     | pwm_ch0.0 may also appear on IO_26 or IO_39 |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_12     | gpio_0        |               | gpio_5        | efpgaio_5     | gpio_0 may also appear on IO_7 or IO_43     |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_13     | qspim0_csn0   | pwm_ch0.2     | gpio_6        | efpgaio_6     |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_14     | qspim0_data0  | pwm_ch0.3     | gpio_7        | efpgaio_7     |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_15     | qspim0_data1  | pwm_ch1.1     | gpio_8        | efpgaio_8     |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_16     | qspim0_clk    | pwm_ch1.2     | gpio_9        | efpgaio_9     |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_17     | gpio_1        | pwm_ch2.0     | gpio_10       | efpgaio_10    | gpio_1 may also appear on IO_8              |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_18     | gpio_2        | pwm_ch2.1     | gpio_11       | efpgaio_11    | gpio_2 may also appear on IO_9              |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_19     | qspim0_data2  | pwm_ch2.2     | gpio_12       | efpgaio_12    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_20     | qspim0_data3  | pwm_ch2.3     | gpio_13       | efpgaio_13    | pwm_ch2.3 may also appear on IO_40          |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_21     | cam0_vsync    | pwm_ch1.0     | gpio_14       | efpgaio_14    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_22     | cam0_hsync    | pwm_ch1.3     | gpio_15       | efpgaio_15    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_23     | i2cm0_scl     |               | gpio_16       | efpgaio_16    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_24     | i2cm0_sda     |               | gpio_17       | efpgaio_17    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_25     | cam0_clk      | pwm_ch0.1     | gpio_18       | efpgaio_18    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_26     | pwm_ch0.0     | qspim0_csn1   | gpio_19       | efpgaio_19    | pwm_ch0.0 may also appear on IO_11 or IO_39 |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_27     | i2cs_scl      | qspim0_csn2   | gpio_20       | efpgaio_20    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_28     | i2cs_sda      | qspim0_csn3   | gpio_21       | efpgaio_21    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_29     | cam0_data0    | qspim1_csn0   | gpio_22       | efpgaio_22    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_30     | cam0_data1    | qspim1_data0  | gpio_23       | efpgaio_23    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_31     | cam0_data2    | qspim1_data1  | gpio_24       | efpgaio_24    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_32     | cam0_data3    | qspim1_clk    | gpio_25       | efpgaio_25    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_33     | cam0_data4    | qspim1_csn1   | gpio_26       | efpgaio_26    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_34     | cam0_data5    | qspim1_csn2   | gpio_27       | efpgaio_27    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_35     | cam0_data6    | qspim1_data2  | gpio_28       | efpgaio_28    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_36     | cam0_data7    | qspim1_data3  | gpio_29       | efpgaio_29    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_37     | sdio0_data3   |               | gpio_30       | efpgaio_30    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_38     | sdio0_cmd     |               | gpio_31       | efpgaio_31    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_39     | sdio0_data0   |               | pwm_ch0.0     | efpgaio_32    | pwm_ch0.0 may also appear on IO_11 or IO_26 |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_40     | sdio0_clk     |               | pwm_ch2.3     | efpgaio_33    | pwm_ch2.3 may also appear on IO_20          |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_41     | sdio0_data1   |               | pwm_ch3.0     | efpgaio_34    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_42     | sdio0_data2   |               | pwm_ch3.1     | efpgaio_35    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_43     | i2cs_intr     | gpio_0        | pwm_ch3.2     | efpgaio_36    | gpio_0 may also appear on IO_7 or IO_12     |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_44     | IO_44 not selectable                                                                                        |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_45     |               |               |               | efpgaio_37    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_46     | i2cm1_scl     |               |               | efpgaio_38    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+
| IO_47     | i2cm1_sda     |               |               | efpgaio_39    |                                             |
+-----------+---------------+---------------+---------------+---------------+---------------------------------------------+

Nexys A7 with Xilinx XC7A100T FPGA
----------------------------------
The Nexys A7 makes many of the FPGA balls accessible via one of many on-board resources such as PMOD connections or a dedicated header, switch or LED.
Please consult the Digilent Nexys A7 FPGA Board Reference Manual for the locations and pinouts of the PMODs and other resources on the board.
The default mapping from CORE-V-MCU top-level IO to these Nexys A7 connections is provided in the table below.

+--------------+-----------+-----------------------------------------------------+
| Nexys A7     | MCU Port  | Notes                                               |
+==============+===========+=====================================================+
| JB[10]       | jtag_tck  |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JB[8]        | jtag_tdi  |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JB[9]        | jtag_tdo  |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JB[7]        | jtag_tms  |                                                     |
+--------------+-----------+-----------------------------------------------------+
| SW[0]        | jtag_trst | Put this switch in the "up" position                |
+--------------+-----------+-----------------------------------------------------+
| CLK100MHZ    | ref_clk   | Convenient on-board resource                        |
+--------------+-----------+-----------------------------------------------------+
| CPU_RESETN   | rstn      | On-board push-button                                |
+--------------+-----------+-----------------------------------------------------+
| UART_TXD_IN  | IO_7      | Shared UART/JTAG USB port                           |
+--------------+-----------+-----------------------------------------------------+
| UART_RXD_OUT | IO_8      | Shared UART/JTAG USB port                           |
+--------------+-----------+-----------------------------------------------------+
| JB[2]        | IO_9      |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JB[3]        | IO_10     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| LED[0]       | IO_11     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JB[4]        | IO_12     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[1]     | IO_13     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[2]     | IO_14     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[3]     | IO_15     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[4]     | IO_16     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[7]     | IO_17     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[8]     | IO_18     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[9]     | IO_19     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JXADC[10]    | IO_20     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[1]        | IO_21     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[2]        | IO_22     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[3]        | IO_23     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[4]        | IO_24     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[7]        | IO_25     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[8]        | IO_26     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[9]        | IO_27     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JC[10]       | IO_28     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[1]        | IO_29     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[2]        | IO_30     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[3]        | IO_31     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[4]        | IO_32     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[7]        | IO_33     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[8]        | IO_34     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[9]        | IO_35     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JD[10]       | IO_36     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[1]        | IO_37     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[2]        | IO_38     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[3]        | IO_39     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[4]        | IO_40     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[7]        | IO_41     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[8]        | IO_42     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[9]        | IO_43     |                                                     |
+--------------+-----------+-----------------------------------------------------+
| JA[10]       | stm       | Special Test Mode: I/Os connected directly to efpga |
+--------------+-----------+-----------------------------------------------------+
| SW[1]        | bootsel   | Can also be configured for fpgaio_45                |
+--------------+-----------+-----------------------------------------------------+
| TMP_SCL      | IO_46     | Hardwired to on-board temperature sensor            |
+--------------+-----------+-----------------------------------------------------+
| TMP_SDA      | IO_47     | Hardwired to on-board temperature sensor            |
+--------------+-----------+-----------------------------------------------------+

.. ## Nexys A7 with Xilinx XC7A100T FPGA
   CORE-V-MCU Makefiles, FuseSoC "core" files and Xilinx constraints files are available to support synthesis and bitmap generation for the XCA7A100T FPGA on a Digilent Nexys A7.
   Using these files will generate a pin assignment for the Nexys A7 as shown in the Table below.
   
   | Nexys A7 | IO | sysio | sel=0 | sel=1 | sel=2 | sel=3 | Note |
   | --- | --- | --- | --- | --- | --- | --- | --- |
   |        | IO_0 | jtag_tck |  |  |  |  | |
   |        | IO_1 | jtag_tdi |  |  |  |  | |
   |        | IO_2 | jtag_tdo |  |  |  |  | |
   |        | IO_3 | jtag_tms |  |  |  |  | |
   |        | IO_4 | jtag_trst |  |  |  |  | |
   |        | IO_5 | ref_clk |  |  |  |  | |
   |        | IO_6 | rstn |  |  |  |  | |
   |        | IO_7 |  | uart0_rx |  | gpio_0 | fpgaio_0 | gpio_0 may also appear on IO_12 or IO_43 |
   |        | IO_8 |  | uart0_tx |  | gpio_1 | fpgaio_1 | gpio_1 may also appear on Jxadc[7] |
   |        | IO_9 |  | uart1_tx |  | gpio_2 | fpgaio_2 | gpio_2 may also appear on Jxadc[8] |
   |        | IO_10 |  | uart1_rx |  | gpio_3 | fpgaio_3 | |
   | LED[0] | IO_11 |  | pwm_ch0.0 | pwm_ch3.3 | gpio_4 | fpgaio_4 | pwm_ch0.0 may also appear on IO_26 or IO_39 |
   |        | IO_12 |  | gpio_0 |  | gpio_5 | fpgaio_5 | gpio_0 may also appear on IO_7 or IO_43 |
   |        | Jxadc[1] |  | qspim0_csn0 | pwm_ch0.2 | gpio_6 | fpgaio_6 | |
   |        | Jxadc[2] |  | qspim0_data0 | pwm_ch0.3 | gpio_7 | fpgaio_7 | |
   |        | Jxadc[3] |  | qspim0_data1 | pwm_ch1.1 | gpio_8 | fpgaio_8 | |
   |        | Jxadc[4] |  | qspim0_clk | pwm_ch1.2 | gpio_9 | fpgaio_9 | |
   |        | Jxadc[7] |  | gpio_1 | pwm_ch2.0 | gpio_10 | fpgaio_10 | gpio_1 may also appear on IO_8 |
   |        | Jxadc[8] |  | gpio_2 | pwm_ch2.1 | gpio_11 | fpgaio_11 | gpio_2 may also appear on IO_9 |
   |        | Jxadc[9] |  | qspim0_data2 | pwm_ch2.2 | gpio_12 | fpgaio_12 | |
   |        | Jxadc[10] |  | qspim0_data3 | pwm_ch2.3 | gpio_13 | fpgaio_13 | pwm_ch2.3 may also appear on IO_40 |
   |        | IO_21 |  | cam0_vsync | pwm_ch1.0 | gpio_14 | fpgaio_14 | |
   |        | IO_22 |  | cam0_hsync | pwm_ch1.3 | gpio_15 | fpgaio_15 | |
   |        | IO_23 |  | i2cm0_scl |  | gpio_16 | fpgaio_16 | |
   |        | IO_24 |  | i2cm0_sda |  | gpio_17 | fpgaio_17 | |
   |        | IO_25 |  | cam0_clk | pwm_ch0.1 | gpio_18 | fpgaio_18 | |
   |        | IO_26 |  | pwm_ch0.0 | qspim0_csn1 | gpio_19 | fpgaio_19 | pwm_ch0.0 may also appear on IO_11 or IO_39 |
   |        | IO_27 |  | i2cs_scl | qspim0_csn2 | gpio_20 | fpgaio_20 | |
   |        | IO_28 |  | i2cs_sda | qspim0_csn3 | gpio_21 | fpgaio_21 | |
   |        | IO_29 |  | cam0_data0 | qspim1_csn0 | gpio_22 | fpgaio_22 | |
   |        | IO_30 |  | cam0_data1 | qspim1_data0 | gpio_23 | fpgaio_23 | |
   |        | IO_31 |  | cam0_data2 | qspim1_data1 | gpio_24 | fpgaio_24 | |
   |        | IO_32 |  | cam0_data3 | qspim1_clk | gpio_25 | fpgaio_25 | |
   |        | IO_33 |  | cam0_data4 | qspim1_csn1 | gpio_26 | fpgaio_26 | |
   |        | IO_34 |  | cam0_data5 | qspim1_csn2 | gpio_27 | fpgaio_27 | |
   |        | IO_35 |  | cam0_data6 | qspim1_data2 | gpio_28 | fpgaio_28 | |
   |        | IO_36 |  | cam0_data7 | qspim1_data3 | gpio_29 | fpgaio_29 | |
   |        | IO_37 |  | sdio0_data3 |  | gpio_30 | fpgaio_30 | |
   |        | IO_38 |  | sdio0_cmd |  | gpio_31 | fpgaio_31 | |
   |        | IO_39 |  | sdio0_data0 |  | pwm_ch0.0 | fpgaio_32 | pwm_ch0.0 may also appear on IO_11 or IO_26 |
   |        | IO_40 |  | sdio0_clk |  | pwm_ch2.3 | fpgaio_33 | pwm_ch2.3 may also appear on Jxadc[10] |
   |        | IO_41 |  | sdio0_data1 |  | pwm_ch3.0 | fpgaio_34 | |
   |        | IO_42 |  | sdio0_data2 |  | pwm_ch3.1 | fpgaio_35 | |
   |        | IO_43 |  | i2cs_intr | gpio_0 | pwm_ch3.2 | fpgaio_36 | gpio_0 may also appear on IO_7 or IO_12 |
   |        | IO_44 | stm |  |  |  |  | |
   |        | IO_45 | bootsel |  |  |  | fpgaio_37 | |
   |        | IO_46 |  | i2cm1_scl |  |  | fpgaio_38 | |
   |        | IO_47 |  | i2cm1_sda |  |  | fpgaio_39 | |
   -->

ASIC Pin-out
------------

**Note**: the ASIC pin-out is still being worked out.
An update to this table will be made when it is finalized.

.. <!--
   | Pin | IO | sysio | sel=0 | sel=1 | sel=2 | sel=3 |
   | --- | --- | --- | --- | --- | --- | --- |
   |     | IO_0 | jtag_tck |  |  |  |  |
   |     | IO_1 | jtag_tdi |  |  |  |  |
   |     | IO_2 | jtag_tdo |  |  |  |  |
   |     | IO_3 | jtag_tms |  |  |  |  |
   |     | IO_4 | jtag_trst |  |  |  |  |
   |     | IO_5 | ref_clk |  |  |  |  |
   |     | IO_6 | rstn |  |  |  |  |
   |     | IO_7 |  | uart0_rx |  | apbio_0 | fpgaio_0 |
   |     | IO_8 |  | uart0_tx |  | apbio_1 | fpgaio_1 |
   |     | IO_9 |  | uart1_tx |  | apbio_2 | fpgaio_2 |
   |     | IO_10 |  | uart1_rx |  | apbio_3 | fpgaio_3 |
   |     | IO_11 |  | apbio_32 | apbio_47 | apbio_4 | fpgaio_4 |
   |     | IO_12 |  | apbio_0 |  | apbio_5 | fpgaio_5 |
   |     | Jxadc[1] |  | qspim0_csn0 | apbio_34 | apbio_6 | fpgaio_6 |
   |     | Jxadc[2] |  | qspim0_data0 | apbio_35 | apbio_7 | fpgaio_7 |
   |     | Jxadc[3] |  | qspim0_data1 | apbio_37 | apbio_8 | fpgaio_8 |
   |     | Jxadc[4] |  | qspim0_clk | apbio_38 | apbio_9 | fpgaio_9 |
   |     | Jxadc[7] |  | apbio_1 | apbio_40 | apbio_10 | fpgaio_10 |
   |     | Jxadc[8] |  | apbio_2 | apbio_41 | apbio_11 | fpgaio_11 |
   |     | Jxadc[9] |  | qspim0_data2 | apbio_42 | apbio_12 | fpgaio_12 |
   |     | Jxadc[10] |  | qspim0_data3 | apbio_43 | apbio_13 | fpgaio_13 |
   |     | IO_21 |  | cam0_vsync | apbio_36 | apbio_14 | fpgaio_14 |
   |     | IO_22 |  | cam0_hsync | apbio_39 | apbio_15 | fpgaio_15 |
   |     | IO_23 |  | i2cm0_scl |  | apbio_16 | fpgaio_16 |
   |     | IO_24 |  | i2cm0_sda |  | apbio_17 | fpgaio_17 |
   |     | IO_25 |  | cam0_clk | apbio_33 | apbio_18 | fpgaio_18 |
   |     | IO_26 |  | apbio_32 | qspim0_csn1 | apbio_19 | fpgaio_19 |
   |     | IO_27 |  | apbio_48 | qspim0_csn2 | apbio_20 | fpgaio_20 |
   |     | IO_28 |  | apbio_49 | qspim0_csn3 | apbio_21 | fpgaio_21 |
   |     | IO_29 |  | cam0_data0 | qspim1_csn0 | apbio_22 | fpgaio_22 |
   |     | IO_30 |  | cam0_data1 | qspim1_data0 | apbio_23 | fpgaio_23 |
   |     | IO_31 |  | cam0_data2 | qspim1_data1 | apbio_24 | fpgaio_24 |
   |     | IO_32 |  | cam0_data3 | qspim1_clk | apbio_25 | fpgaio_25 |
   |     | IO_33 |  | cam0_data4 | qspim1_csn1 | apbio_26 | fpgaio_26 |
   |     | IO_34 |  | cam0_data5 | qspim1_csn2 | apbio_27 | fpgaio_27 |
   |     | IO_35 |  | cam0_data6 | qspim1_data2 | apbio_28 | fpgaio_28 |
   |     | IO_36 |  | cam0_data7 | qspim1_data3 | apbio_29 | fpgaio_29 |
   |     | IO_37 |  | sdio0_data3 |  | apbio_30 | fpgaio_30 |
   |     | IO_38 |  | sdio0_cmd |  | apbio_31 | fpgaio_31 |
   |     | IO_39 |  | sdio0_data0 |  | apbio_32 | fpgaio_32 |
   |     | IO_40 |  | sdio0_clk |  | apbio_43 | fpgaio_33 |
   |     | IO_41 |  | sdio0_data1 |  | apbio_44 | fpgaio_34 |
   |     | IO_42 |  | sdio0_data2 |  | apbio_45 | fpgaio_35 |
   |     | IO_43 |  | apbio_50 | apbio_0 | apbio_46 | fpgaio_36 |
   |     | IO_44 | stm |  |  |  |  |
   |     | IO_45 | bootsel |  |  |  | fpgaio_37 |
   |     | IO_46 |  | i2cm1_scl |  |  | fpgaio_38 |
   |     | IO_47 |  | i2cm1_sda |  |  | fpgaio_39 |
   -->
