# Pin Assignment

| IO | sysio | sel=0 | sel=1 | sel=2 | sel=3 |
| --- | --- | --- | --- | --- | --- |
| IO_0 |  | uart0_rx |  | gpio_0 | fpgaio_0 |
| IO_1 |  | uart0_tx |  | gpio_1 | fpgaio_1 |
| IO_2 |  | 0 | 1 | gpio_2 | fpgaio_2 |
| IO_3 |  | uart1_tx | uart1_rx | gpio_3 | fpgaio_3 |
| IO_4 |  | uart1_rx | uart1_tx | gpio_4 | fpgaio_4 |
| IO_5 |  | 0 | 1 | gpio_5 | fpgaio_5 |
| IO_6 | ref_clk |  |  |  |  |
| IO_7 | rstn |  |  |  |  |
| IO_8 | jtag_tck |  |  |  |  |
| IO_9 | jtag_tdi |  |  |  |  |
| IO_10 | jtag_tdo |  |  |  |  |
| IO_11 | jtag_tms |  |  |  |  |
| IO_12 | jtag_trst |  |  |  |  |
| IO_13 |  | i2cm0_scl | 1 | 0 | gpio_0 |
| IO_14 |  | i2cm0_sda | 1 | 0 | gpio_1 |
| IO_15 | bootsel | sdio0_clk |  |  |  |
| IO_16 |  | sdio0_cmd |  |  |  |
| IO_17 |  | sdio0_data0 |  |  |  |
| IO_18 |  | sdio0_data1 |  |  |  |
| IO_19 |  | sdio0_data2 |  |  |  |
| IO_20 |  | sdio0_data3 |  |  |  |
| IO_21 |  | qspim0_clk | i2cm0_scl | gpio_6 | uart0_tx |
| IO_22 |  | qspim0_data0 | i2cm0_sda | gpio_7 | uart0_rx |
| IO_23 |  | qspim0_data1 | i2cm1_scl | gpio_8 |  |
| IO_24 |  | qspim0_data2 | i2cm1_sda | gpio_9 |  |
| IO_25 |  | qspim0_data3 |  | gpio_10 |  |
| IO_26 |  | qspim0_csn0 |  | gpio_11 |  |
| IO_27 |  | qspim0_csn1 |  | gpio_12 |  |
| IO_28 |  | qspim0_csn2 |  | gpio_13 |  |
| IO_29 |  | qspim0_csn3 |  | gpio_14 |  |
| IO_30 |  | cam0_vsync |  | gpio_15 |  |
| IO_31 |  | cam0_hsync |  | gpio_16 |  |
| IO_32 |  | cam0_data0 |  | gpio_17 |  |
| IO_33 |  | cam0_data1 |  | gpio_18 |  |
| IO_34 |  | cam0_data2 |  | gpio_19 |  |
| IO_35 |  | cam0_data3 |  | gpio_20 |  |
| IO_36 |  | cam0_data4 |  | gpio_21 |  |
| IO_37 |  | cam0_data5 |  | gpio_22 |  |
| IO_38 |  | cam0_data6 |  | gpio_23 |  |
| IO_39 |  | cam0_data7 |  | gpio_24 |  |
| IO_40 |  | cam0_clk |  | gpio_25 |  |
| IO_41 |  | 1 | gpio_0 | gpio_26 | 0 |
| IO_42 |  | 1 | gpio_1 | gpio_27 | 0 |
| IO_43 |  | 1 | gpio_2 | gpio_28 | 0 |
| IO_44 |  | 0 | gpio_3 | gpio_29 | 0 |
| IO_45 |  | 1 | gpio_5 | gpio_30 | 0 |
| IO_46 |  | i2cm1_scl | gpio_5 | gpio_31 | 0 |
| IO_47 |  | i2cm1_sda | gpio_6 | 1 | 0 |
