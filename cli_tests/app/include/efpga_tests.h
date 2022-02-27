/*==========================================================
 * Copyright 2021 QuickLogic Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *==========================================================*/
#ifndef INC_EFPGA_H
#define INC_EFPGA_H

#ifdef __cplusplus
extern "C" {
#endif


#define EFPGA_DEBUG 0
#define EFPGA_ERROR 0
#define APB_SOC_CTRL_BASE_ADDR 0x1A104000
#define EFPGA_BASE_ADDR 0x1A300000
#define APB_ADV_TIMER_BASE_ADDR 0x1A105000

typedef struct {
	volatile unsigned int T0_CMD;
	volatile unsigned int T0_CONFIG;
	volatile unsigned int T0_THRESHOLD;
	volatile unsigned int T0_TH_CH0;
	volatile unsigned int T0_TH_CH1;
	volatile unsigned int T0_TH_CH2;
	volatile unsigned int T0_TH_CH3;
	volatile unsigned int T0_TH_CH0_LUT;
	volatile unsigned int T0_TH_CH1_LUT;
	volatile unsigned int T0_TH_CH2_LUT;
	volatile unsigned int T0_TH_CH3_LUT;
	volatile unsigned int T0_COUNTER;
	volatile unsigned int reserved30[4];
	volatile unsigned int T1_CMD;
	volatile unsigned int T1_CONFIG;
	volatile unsigned int T1_THRESHOLD;
	volatile unsigned int T1_TH_CH0;
	volatile unsigned int T1_TH_CH1;
	volatile unsigned int T1_TH_CH2;
	volatile unsigned int T1_TH_CH3;
	volatile unsigned int T1_TH_CH0_LUT;
	volatile unsigned int T1_TH_CH1_LUT;
	volatile unsigned int T1_TH_CH2_LUT;
	volatile unsigned int T1_TH_CH3_LUT;
	volatile unsigned int T1_COUNTER;
	volatile unsigned int reserved70[4];
	volatile unsigned int T2_CMD;
	volatile unsigned int T2_CONFIG;
	volatile unsigned int T2_THRESHOLD;
	volatile unsigned int T2_TH_CH0;
	volatile unsigned int T2_TH_CH1;
	volatile unsigned int T2_TH_CH2;
	volatile unsigned int T2_TH_CH3;
	volatile unsigned int T2_TH_CH0_LUT;
	volatile unsigned int T2_TH_CH1_LUT;
	volatile unsigned int T2_TH_CH2_LUT;
	volatile unsigned int T2_TH_CH3_LUT;
	volatile unsigned int T2_COUNTER;
	volatile unsigned int reservedB0[4];
	volatile unsigned int T3_CMD;
	volatile unsigned int T3_CONFIG;
	volatile unsigned int T3_THRESHOLD;
	volatile unsigned int T3_TH_CH0;
	volatile unsigned int T3_TH_CH1;
	volatile unsigned int T3_TH_CH2;
	volatile unsigned int T3_TH_CH3;
	volatile unsigned int T3_TH_CH0_LUT;
	volatile unsigned int T3_TH_CH1_LUT;
	volatile unsigned int T3_TH_CH2_LUT;
	volatile unsigned int T3_TH_CH3_LUT;
	volatile unsigned int T3_COUNTER;
	volatile unsigned int reservedF0[4];
	volatile unsigned int EVENT_CFG;
	volatile unsigned int CG;
} apb_adv_timer_typedef;

typedef struct {
	volatile unsigned int CFG_REG_LO; //         6'h0
	volatile unsigned int CFG_REG_HI; //         6'h4
	volatile unsigned int TIMER_VAL_LO; //       6'h8
	volatile unsigned int TIMER_VAL_HI; //       6'hC
	volatile unsigned int TIMER_CMP_LO; //       6'h10
	volatile unsigned int TIMER_CMP_HI; //       6'h14
	volatile unsigned int TIMER_START_LO; //     6'h18
	volatile unsigned int TIMER_START_HI; //     6'h1C
	volatile unsigned int TIMER_RESET_LO; //     6'h20
	volatile unsigned int TIMER_RESET_HI; //     6'h24
} apb_timer_typedef;

typedef struct {
	volatile unsigned int MASK;//		0x0
	volatile unsigned int MASK_SET;//			0x4
	volatile unsigned int MASK_CLEAR;//			0x8
	volatile unsigned int INT;//			0xC
	volatile unsigned int INT_SET;//			0x10
	volatile unsigned int INT_CLEAR;//			0x14
	volatile unsigned int ACK;//			0x18
	volatile unsigned int ACK_SET;//			0x1C
	volatile unsigned int ACK_CLEAR;//			0x20
	volatile unsigned int FIFO;//			0x24
} apb_interrupt_ctl_typedef;

typedef struct {
	volatile unsigned int tcdm0_ctl;
	volatile unsigned int tcdm1_ctl;
	volatile unsigned int tcdm2_ctl;
	volatile unsigned int tcdm3_ctl;
	volatile unsigned int m0_m0_ctl;
	volatile unsigned int m0_m1_ctl;
	volatile unsigned int m1_m0_ctl;
	volatile unsigned int m1_m1_ctl;
	volatile unsigned int m0_ram_ctl;
	volatile unsigned int m1_ram_ctl;
	volatile unsigned int reserved28;
	volatile unsigned int reserved2c;
	volatile unsigned int m0_m0_clken;
	volatile unsigned int m0_m1_clken;
	volatile unsigned int m1_m0_clken;
	volatile unsigned int m1_m1_clken;
	volatile unsigned int efpga_out0;
	volatile unsigned int efpga_out32;
	volatile unsigned int efpga_out64;
	volatile unsigned int reserved4c;
	volatile unsigned int efpga_oe0;
	volatile unsigned int efpga_oe32;
	volatile unsigned int efpga_oe64;
	volatile unsigned int reserved5c;
	volatile unsigned int efpga_in0;
	volatile unsigned int efpga_in32;
	volatile unsigned int efpga_in64;
	volatile unsigned int events;
	volatile unsigned int reserved70[4];
	volatile unsigned int tcdm_result[4];

	volatile unsigned int m0_m0_odata;
	volatile unsigned int m0_m1_odata;
	volatile unsigned int m0_m0_cdata;
	volatile unsigned int m0_m1_cdata;
	volatile unsigned int m1_m0_odata;
	volatile unsigned int m1_m1_odata;
	volatile unsigned int m1_m0_cdata;
	volatile unsigned int m1_m1_cdata;
	volatile unsigned int reservedb0[0x14];

	volatile unsigned int m0_m0_data_out;
	volatile unsigned int m0_m1_data_out;
	volatile unsigned int m1_m0_data_out;
	volatile unsigned int m1_m1_data_out;
	volatile unsigned int reserved110[0x1BC]; // 0x110 - 0x7FF
	volatile unsigned int test_read;
	volatile unsigned int reserved804[0x1ff];
	union {
		volatile unsigned char b[0x1000];
		volatile unsigned short hw[0x800];
		volatile unsigned int w[0x400];
	} m0_oper0;
	union {
		volatile unsigned char b[0x1000];
		volatile unsigned short hw[0x800];
		volatile unsigned int w[0x400];
	} m0_oper1;
	union {
		volatile unsigned char b[0x1000];
		volatile unsigned short hw[0x800];
		volatile unsigned int w[0x400];
	} m0_coef;
	union {
		volatile unsigned char b[0x1000];
		volatile unsigned short hw[0x800];
		volatile unsigned int w[0x400];
	} m1_oper0;
	union {
		volatile unsigned char b[0x1000];
		volatile unsigned short hw[0x800];
		volatile unsigned int w[0x400];
	} m1_oper1;
	union {
		volatile unsigned char b[0x1000];
		volatile unsigned short hw[0x800];
		volatile unsigned int w[0x400];
	} m1_coef;
} efpga_typedef;

typedef struct {
	volatile unsigned int reserved0[0x18]; //
	volatile unsigned int WCFGFUN;
	volatile unsigned int RCFGFUN;
	volatile unsigned int reserved68[0x20]; // 0x68-0xE7
	volatile unsigned int rst_efpga;
	volatile unsigned int ena_efpga;
	volatile unsigned int control_in;
	volatile unsigned int status_out;
	volatile unsigned int version;
	volatile unsigned int reservedf0[0xb8];
	volatile unsigned int padmux[64];
} apb_soc_ctrl_typedef;

typedef enum {
	BIT_32,
	BIT_16,
	BIT_8,
	BIT_MAX
} fpga_ram_rw_mode_enum;

typedef struct {
	fpga_ram_rw_mode_enum coef_write;
	fpga_ram_rw_mode_enum coef_read;
	fpga_ram_rw_mode_enum operand1_write;
	fpga_ram_rw_mode_enum operand1_read;
	fpga_ram_rw_mode_enum operand0_write;
	fpga_ram_rw_mode_enum operand0_read;
} fpga_ram_mode_typedef;

#ifdef __cplusplus
}
#endif
#endif /* INC_EFPGA_H */

