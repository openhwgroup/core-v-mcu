# Pin Assignment Tables
The CORE-V-MCU can be targeted to multiple implementations, including FPGA and ASIC.
This section is the pin assignments for the currently supported implementations.

Table headings have the following meaning:

* **IO**: a user I/O or XADC pin on the FPGA.
* **SYSIO**: a hardwired function, i.e., not affected by I/O Mux Select, (e.g. ref_clk).
* **sel=0..3**: the value of the I/O Mux Select; IO_CTRL[1:0] CSR (at offset 0x0400).

The I/O Mux select can be used to select one or more of the following IP peripheral blocks to the specified I/O pins:

* **uart0..1**: I/O signals for one of two simple [Universal Asynchronous Receiver/Transmitters](uart.md)
* **qspim0..1**: I/O signals for one of two [Queued Serial Peripheral Interface](qspim.md) masters.
* **i2cm0..1**: I/O signals for one of two Inter-Integrated Circuit [I2C](i2cm.md) bus masters.
* **i2cs**: I/O signals for the Inter-Integrated Circuit [I2C](i2cs.md) bus slave.
* **gpio_0..31**: One of 32 general purpose I/O ([GPIO](apb_gpio.md)) signals.
* **pwm_chX.Y**: Outputs of four PWMs supported by the ([Advanced Timer](apb_adv_timer.md)) module.
* **fpgaio_0..31**: One of 32 general purpose I/O ([GPIO](apb_gpio.md)) signals driven by the eFPGA.
* **cam0**: [Camera](cam.md) interface.
* **sdio**: [SDIO Card](sdio).

Note that a subset of I/Os can be configured onto multiple IO pins.

## Xilinx XC7A100T FPGA
CORE-V-MCU Makefiles, FuseSoC "core" files and Xilinx constraints files are available to support synthesis and bitmap generation for the XCA7A100T FPGA on a Digilent Nexys A7.
The pin assignment and IOMUX selection in the XC7A100T is given in the Table below.

| IO | sysio | sel=0 | sel=1 | sel=2 | sel=3 | Note |
| --- | --- | --- | --- | --- | --- | --- |
| IO_0 | jtag_tck |  |  |  |  | |
| IO_1 | jtag_tdi |  |  |  |  | |
| IO_2 | jtag_tdo |  |  |  |  | |
| IO_3 | jtag_tms |  |  |  |  | |
| IO_4 | jtag_trst |  |  |  |  | |
| IO_5 | ref_clk |  |  |  |  | |
| IO_6 | rstn |  |  |  |  | |
| IO_7 |  | uart0_rx |  | gpio_0 | fpgaio_0 | gpio_0 may also appear on IO_12 or IO_43 |
| IO_8 |  | uart0_tx |  | gpio_1 | fpgaio_1 | gpio_1 may also appear on Jxadc[7] |
| IO_9 |  | uart1_tx |  | gpio_2 | fpgaio_2 | gpio_2 may also appear on Jxadc[8] |
| IO_10 |  | uart1_rx |  | gpio_3 | fpgaio_3 | |
| IO_11 |  | pwm_ch0.0 | pwm_ch3.3 | gpio_4 | fpgaio_4 | pwm_ch0.0 may also appear on IO_26 or IO_39 |
| IO_12 |  | gpio_0 |  | gpio_5 | fpgaio_5 | gpio_0 may also appear on IO_7 or IO_43 |
| Jxadc[1] |  | qspim0_csn0 | pwm_ch0.2 | gpio_6 | fpgaio_6 | |
| Jxadc[2] |  | qspim0_data0 | pwm_ch0.3 | gpio_7 | fpgaio_7 | |
| Jxadc[3] |  | qspim0_data1 | pwm_ch1.1 | gpio_8 | fpgaio_8 | |
| Jxadc[4] |  | qspim0_clk | pwm_ch1.2 | gpio_9 | fpgaio_9 | |
| Jxadc[7] |  | gpio_1 | pwm_ch2.0 | gpio_10 | fpgaio_10 | gpio_1 may also appear on IO_8 |
| Jxadc[8] |  | gpio_2 | pwm_ch2.1 | gpio_11 | fpgaio_11 | gpio_2 may also appear on IO_9 |
| Jxadc[9] |  | qspim0_data2 | pwm_ch2.2 | gpio_12 | fpgaio_12 | |
| Jxadc[10] |  | qspim0_data3 | pwm_ch2.3 | gpio_13 | fpgaio_13 | pwm_ch2.3 may also appear on IO_40 |
| IO_21 |  | cam0_vsync | pwm_ch1.0 | gpio_14 | fpgaio_14 | |
| IO_22 |  | cam0_hsync | pwm_ch1.3 | gpio_15 | fpgaio_15 | |
| IO_23 |  | i2cm0_scl |  | gpio_16 | fpgaio_16 | |
| IO_24 |  | i2cm0_sda |  | gpio_17 | fpgaio_17 | |
| IO_25 |  | cam0_clk | pwm_ch0.1 | gpio_18 | fpgaio_18 | |
| IO_26 |  | pwm_ch0.0 | qspim0_csn1 | gpio_19 | fpgaio_19 | pwm_ch0.0 may also appear on IO_11 or IO_39 |
| IO_27 |  | i2cs_scl | qspim0_csn2 | gpio_20 | fpgaio_20 | |
| IO_28 |  | i2cs_sda | qspim0_csn3 | gpio_21 | fpgaio_21 | |
| IO_29 |  | cam0_data0 | qspim1_csn0 | gpio_22 | fpgaio_22 | |
| IO_30 |  | cam0_data1 | qspim1_data0 | gpio_23 | fpgaio_23 | |
| IO_31 |  | cam0_data2 | qspim1_data1 | gpio_24 | fpgaio_24 | |
| IO_32 |  | cam0_data3 | qspim1_clk | gpio_25 | fpgaio_25 | |
| IO_33 |  | cam0_data4 | qspim1_csn1 | gpio_26 | fpgaio_26 | |
| IO_34 |  | cam0_data5 | qspim1_csn2 | gpio_27 | fpgaio_27 | |
| IO_35 |  | cam0_data6 | qspim1_data2 | gpio_28 | fpgaio_28 | |
| IO_36 |  | cam0_data7 | qspim1_data3 | gpio_29 | fpgaio_29 | |
| IO_37 |  | sdio0_data3 |  | gpio_30 | fpgaio_30 | |
| IO_38 |  | sdio0_cmd |  | gpio_31 | fpgaio_31 | |
| IO_39 |  | sdio0_data0 |  | pwm_ch0.0 | fpgaio_32 | pwm_ch0.0 may also appear on IO_11 or IO_26 |
| IO_40 |  | sdio0_clk |  | pwm_ch2.3 | fpgaio_33 | pwm_ch2.3 may also appear on Jxadc[10] |
| IO_41 |  | sdio0_data1 |  | pwm_ch3.0 | fpgaio_34 | |
| IO_42 |  | sdio0_data2 |  | pwm_ch3.1 | fpgaio_35 | |
| IO_43 |  | i2cs_intr | gpio_0 | pwm_ch3.2 | fpgaio_36 | gpio_0 may also appear on IO_7 or IO_12 |
| IO_44 | stm |  |  |  |  | |
| IO_45 | bootsel |  |  |  | fpgaio_37 | |
| IO_46 |  | i2cm1_scl |  |  | fpgaio_38 | |
| IO_47 |  | i2cm1_sda |  |  | fpgaio_39 | |

## ASIC Pin-out

**Note**: the ASIC pin-out is still being worked out.
An update to this table will be made when it is finalized.
<!--
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
