/*
 * This is a generated file
 * 
 * Copyright 2021 QuickLogic
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

`define BUILD_DATE 32'h20210622
`define BUILD_TIME 32'h00151912

//  PER_ID definitions
`define PER_ID_UART      0
`define PER_ID_QSPIM     2
`define PER_ID_I2CM      3
`define PER_ID_I2SC      5
`define PER_ID_CSI2      5
`define PER_ID_HYPER     5
`define PER_ID_SDIO      5
`define PER_ID_CAM       5
`define PER_ID_JTAG      6
`define PER_ID_MRAM      6
`define PER_ID_FILTER    6
`define PER_ID_FPGA      7
`define PER_ID_EXT_PER   8

//  UDMA TX channels
`define CH_ID_TX_UART    0
`define CH_ID_TX_UART0   0
`define CH_ID_TX_UART1   1
`define CH_ID_TX_QSPIM   2
`define CH_ID_TX_QSPIM0  2
`define CH_ID_CMD_QSPIM  3
`define CH_ID_CMD_QSPIM0 3
`define CH_ID_TX_I2CM    4
`define CH_ID_TX_I2CM0   4
`define CH_ID_TX_I2CM1   5
`define CH_ID_TX_I2SC    6
`define CH_ID_TX_CSI2    6
`define CH_ID_TX_HYPER   6
`define CH_ID_TX_HYPER   6
`define CH_ID_TX_JTAG    6
`define CH_ID_TX_MRAM    6
`define CH_ID_TX_FPGA    6
`define CH_ID_TX_FPGA0   6
`define CH_ID_TX_EXT_PER 7

//  UDMA RX channels
`define CH_ID_RX_UART    0
`define CH_ID_RX_UART0   0
`define CH_ID_RX_UART1   1
`define CH_ID_RX_QSPIM   2
`define CH_ID_RX_QSPIM0  2
`define CH_ID_RX_I2CM    3
`define CH_ID_RX_I2CM0   3
`define CH_ID_RX_I2CM1   4
`define CH_ID_RX_I2SC    5
`define CH_ID_RX_CSI2    5
`define CH_ID_RX_HYPER   5
`define CH_ID_RX_HYPER   5
`define CH_ID_CAM        5
`define CH_ID_CAM0       5
`define CH_ID_RX_JTAG    6
`define CH_ID_RX_MRAM    6
`define CH_ID_RX_FPGA    6
`define CH_ID_RX_FPGA0   6
`define CH_ID_RX_EXT_PER 7

//  Number of channels
`define N_TX_CHANNELS  7
`define N_RX_CHANNELS  7

//  Width of perio bus
`define N_PERIO  38

//  define index locations in perio bus
`define PERIO_UART_NPORTS 2
`define PERIO_UART0_TX   0
`define PERIO_UART0_RX   1
`define PERIO_UART1_TX   2
`define PERIO_UART1_RX   3
`define PERIO_QSPIM_NPORTS 9
`define PERIO_QSPIM0_CLK 4
`define PERIO_QSPIM0_CSN0 5
`define PERIO_QSPIM0_CSN1 6
`define PERIO_QSPIM0_CSN2 7
`define PERIO_QSPIM0_CSN3 8
`define PERIO_QSPIM0_DATA0 9
`define PERIO_QSPIM0_DATA1 10
`define PERIO_QSPIM0_DATA2 11
`define PERIO_QSPIM0_DATA3 12
`define PERIO_I2CM_NPORTS 2
`define PERIO_I2CM0_SCL  13
`define PERIO_I2CM0_SDA  14
`define PERIO_I2CM1_SCL  15
`define PERIO_I2CM1_SDA  16
`define PERIO_I2SC_NPORTS 4
`define PERIO_I2SC0_SCK  17
`define PERIO_I2SC0_WS   18
`define PERIO_I2SC0_SD0  19
`define PERIO_I2SC0_SD1  20
`define PERIO_CSI2_NPORTS 0
`define PERIO_HYPER_NPORTS 0
`define PERIO_SDIO_NPORTS 6
`define PERIO_SDIO0_CLK  21
`define PERIO_SDIO0_CMD  22
`define PERIO_SDIO0_DATA0 23
`define PERIO_SDIO0_DATA1 24
`define PERIO_SDIO0_DATA2 25
`define PERIO_SDIO0_DATA3 26
`define PERIO_CAM_NPORTS 11
`define PERIO_CAM0_CLK   27
`define PERIO_CAM0_VSYNC 28
`define PERIO_CAM0_HSYNC 29
`define PERIO_CAM0_DATA0 30
`define PERIO_CAM0_DATA1 31
`define PERIO_CAM0_DATA2 32
`define PERIO_CAM0_DATA3 33
`define PERIO_CAM0_DATA4 34
`define PERIO_CAM0_DATA5 35
`define PERIO_CAM0_DATA6 36
`define PERIO_CAM0_DATA7 37
`define PERIO_JTAG_NPORTS 0
`define PERIO_MRAM_NPORTS 0
`define PERIO_FILTER_NPORTS 0
`define PERIO_FPGA_NPORTS 0
`define PERIO_EXT_PER_NPORTS 0
