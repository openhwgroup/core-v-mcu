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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"
#include "include/efpga_tests.h"
#include "FreeRTOS.h"
#include "task.h"
#include "hal/include/efpga_template_reg_defs.h"

typedef struct {
	uint32_t totalTestsCount; //
	uint32_t totalFailedCount;
	uint32_t totalMismatchCount;
}tcdm_bg_task_sts_t;

tcdm_bg_task_sts_t gTCDMReadStatus;
tcdm_bg_task_sts_t gTCDMWriteStatus;

extern uint8_t gDebugEnabledFlg;
extern uint8_t gSimulatorEnabledFlg;

static void tcdm_test(const struct cli_cmd_entry *pEntry);
static void ram_test(const struct cli_cmd_entry *pEntry);
static void m_mltiply_test(const struct cli_cmd_entry *pEntry);
static void mathUnit0Multiplier0_test(const struct cli_cmd_entry *pEntry);
static void mathUnit0Multiplier1_test(const struct cli_cmd_entry *pEntry);
static void mathUnit1Multiplier0_test(const struct cli_cmd_entry *pEntry);
static void mathUnit1Multiplier1_test(const struct cli_cmd_entry *pEntry);
static void ram_32bit_16bit_8bit_test(const struct cli_cmd_entry *pEntry);
static void tcdm_task_start(const struct cli_cmd_entry *pEntry);
static void tcdm_task_stop(const struct cli_cmd_entry *pEntry);
static void tcdm_task_status(const struct cli_cmd_entry *pEntry);
static void efpga_autotest(const struct cli_cmd_entry *pEntry);

// EFPGA menu
const struct cli_cmd_entry efpga_cli_tests[] =
{
  CLI_CMD_SIMPLE( "tcdm", tcdm_test, "Tcdm0-4 r/w tests" ),
  CLI_CMD_SIMPLE( "tcdm_st", tcdm_task_start, "Tcdm start task" ),
  CLI_CMD_SIMPLE( "tcdm_sp", tcdm_task_stop, "Tcdm delete task" ),
  CLI_CMD_SIMPLE( "tcdm_status", tcdm_task_status, "Tcdm delete task" ),
  CLI_CMD_SIMPLE( "ram", ram_test, "32 bit ram tests" ),
  CLI_CMD_SIMPLE ( "mlt", m_mltiply_test ,"mltiply_test"),
  CLI_CMD_SIMPLE ( "math0mult0", mathUnit0Multiplier0_test ,"math unit 0 multiplier 0 test"),
  CLI_CMD_SIMPLE ( "math0mult1", mathUnit0Multiplier1_test ,"math unit 0 multiplier 1 test"),
  CLI_CMD_SIMPLE ( "math1mult0", mathUnit1Multiplier0_test ,"math unit 1 multiplier 0 test"),
  CLI_CMD_SIMPLE ( "math1mult1", mathUnit1Multiplier1_test ,"math unit 1 multiplier 0 test"),
  CLI_CMD_SIMPLE( "rw", ram_32bit_16bit_8bit_test, "ram_rw_tests" ),
  CLI_CMD_SIMPLE( "auto", efpga_autotest, "autotest" ),

  CLI_CMD_TERMINATE()
};

typedef union {
	volatile unsigned char b[0x1000];
	volatile unsigned short hw[0x800];
	volatile unsigned int w[0x400];
} ram_word;

typedef struct {
	volatile unsigned int *m_ctl;
	volatile unsigned int *m_clken;
	volatile unsigned int *m_odata;
	volatile unsigned int *m_cdata;
	volatile unsigned int *m_data_out;
}mlti_ctl;

xTaskHandle xHandleTcmdTest = NULL;

static void efpga_ram_set_mode(volatile unsigned int* ram_ctl, fpga_ram_mode_typedef mode) {
	volatile unsigned int reg_val = *ram_ctl;
	if((ram_ctl && 0xFF) == REG_M0_RAM_CONTROL) {
		reg_val &= ~((REG_M0_RAM_CONTROL_m0_coef_wmode_MASK << REG_M0_RAM_CONTROL_m0_coef_wmode_LSB ) |
			(REG_M0_RAM_CONTROL_m0_coef_rmode_MASK << REG_M0_RAM_CONTROL_m0_coef_rmode_LSB) |
			(REG_M0_RAM_CONTROL_m0_oper1_wmode_MASK << REG_M0_RAM_CONTROL_m0_oper1_wmode_LSB) |
			(REG_M0_RAM_CONTROL_m0_oper1_rmode_MASK << REG_M0_RAM_CONTROL_m0_oper1_rmode_LSB) |
			(REG_M0_RAM_CONTROL_m0_oper0_wmode_MASK << REG_M0_RAM_CONTROL_m0_oper0_wmode_LSB) |
			(REG_M0_RAM_CONTROL_m0_oper0_rmode_MASK << REG_M0_RAM_CONTROL_m0_oper0_rmode_LSB));
		reg_val |= (((mode.coef_write & REG_M0_RAM_CONTROL_m0_coef_wmode_MASK) << REG_M0_RAM_CONTROL_m0_coef_wmode_LSB) |
			((mode.coef_read & REG_M0_RAM_CONTROL_m0_coef_rmode_MASK) << REG_M0_RAM_CONTROL_m0_coef_rmode_LSB) |
			((mode.operand1_write & REG_M0_RAM_CONTROL_m0_oper1_wmode_MASK) << REG_M0_RAM_CONTROL_m0_oper1_wmode_LSB) |
		    ((mode.operand1_read & REG_M0_RAM_CONTROL_m0_oper1_rmode_MASK) << REG_M0_RAM_CONTROL_m0_oper1_rmode_LSB) |
			((mode.operand0_write & REG_M0_RAM_CONTROL_m0_oper0_wmode_MASK) << REG_M0_RAM_CONTROL_m0_oper0_wmode_LSB) |
			((mode.operand0_write & REG_M0_RAM_CONTROL_m0_oper0_rmode_MASK) << REG_M0_RAM_CONTROL_m0_oper0_rmode_LSB));
	} else {
		reg_val &= ~((REG_M1_RAM_CONTROL_m1_coef_wmode_MASK << REG_M1_RAM_CONTROL_m1_coef_wmode_LSB ) |
					(REG_M1_RAM_CONTROL_m1_coef_rmode_MASK << REG_M1_RAM_CONTROL_m1_coef_rmode_LSB) |
					(REG_M1_RAM_CONTROL_m1_oper1_wmode_MASK << REG_M1_RAM_CONTROL_m1_oper1_wmode_LSB) |
					(REG_M1_RAM_CONTROL_m1_oper1_rmode_MASK << REG_M1_RAM_CONTROL_m1_oper1_rmode_LSB) |
					(REG_M1_RAM_CONTROL_m1_oper0_wmode_MASK << REG_M1_RAM_CONTROL_m1_oper0_wmode_LSB) |
					(REG_M1_RAM_CONTROL_m1_oper0_rmode_MASK << REG_M1_RAM_CONTROL_m1_oper0_rmode_LSB));
		reg_val |= (((mode.coef_write & REG_M1_RAM_CONTROL_m1_coef_wmode_MASK) << REG_M1_RAM_CONTROL_m1_coef_wmode_LSB) |
					((mode.coef_read & REG_M1_RAM_CONTROL_m1_coef_rmode_MASK) << REG_M1_RAM_CONTROL_m1_coef_rmode_LSB) |
					((mode.operand1_write & REG_M1_RAM_CONTROL_m1_oper1_wmode_MASK) << REG_M1_RAM_CONTROL_m1_oper1_wmode_LSB) |
				    ((mode.operand1_read & REG_M1_RAM_CONTROL_m1_oper1_rmode_MASK) << REG_M1_RAM_CONTROL_m1_oper1_rmode_LSB) |
					((mode.operand0_write & REG_M1_RAM_CONTROL_m1_oper0_wmode_MASK) << REG_M1_RAM_CONTROL_m1_oper0_wmode_LSB) |
					((mode.operand0_write & REG_M1_RAM_CONTROL_m1_oper0_rmode_MASK) << REG_M1_RAM_CONTROL_m1_oper0_rmode_LSB));

    }
	*ram_ctl = reg_val;
}

static unsigned int ram_rw_test(ram_word *ram_adr,volatile unsigned int *ram_ctl) {

	unsigned int i,err;
	fpga_ram_mode_typedef ram_mode;
	char *message = pvPortMalloc(80);
	err = 0;
	unsigned char rdbuff_b[4] = { 0xef,0xbe,0xad,0xde };
	unsigned short int rdbuff_hw[2] = {0xbeef,0xdead};

#if EFPGA_DEBUG
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
	dbg_str("writing 32bit and reading 8bit Test\n\r\r\r");
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
	ram_mode.coef_write = BIT_32;
	ram_mode.coef_read = BIT_8;
	ram_mode.operand1_write = BIT_32;
	ram_mode.operand1_read = BIT_8;
	ram_mode.operand0_write = BIT_32;
	ram_mode.operand0_read = BIT_8;

	efpga_ram_set_mode(ram_ctl, ram_mode);
	//*ram_ctl = 0x222;
	ram_adr->w[0] = 0xdeadbeef;

#if EFPGA_DEBUG
	sprintf(message,"ram_adr->w[0]= 0x%0x\r\n",ram_adr->w[0]);
	dbg_str(message);
#endif

	for (i = 0; i < 4; i++) {
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->b[%d]= 0x%0x\r\n",i, ram_adr->b[i]);
		dbg_str(message);
#endif
		if(ram_adr->b[i] != rdbuff_b[i]) err++;
	}
	memset(&ram_adr->w[0],0x0, 1);

#if EFPGA_DEBUG
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
	dbg_str("writing 8bit and reading 32bit Test\n\r\r\r");
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
	ram_mode.coef_write = BIT_8;
	ram_mode.coef_read = BIT_32;
	ram_mode.operand1_write = BIT_8;
	ram_mode.operand1_read = BIT_32;
	ram_mode.operand0_write = BIT_8;
	ram_mode.operand0_read = BIT_32;
	//*ram_ctl = 0x888;
	efpga_ram_set_mode(ram_ctl, ram_mode);
	for (i = 0; i < 4; i++) {
		ram_adr->b[i] = rdbuff_b[i];
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->w[0]= 0x%0x\r\n",ram_adr->w[0]);
		dbg_str(message);
#endif
	}
#if EFPGA_DEBUG
	sprintf(message,"ram_adr->w[0]= 0x%0x\r\n",ram_adr->w[0]);
	dbg_str(message);
#endif
	if(ram_adr->w[0] != 0xdeadbeef) err++;
	memset(&ram_adr->w[0],0x0, 1);

#if EFPGA_DEBUG
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
	dbg_str("writing 32bit and reading 16bit Test\n\r\r\r");
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
	ram_mode.coef_write = BIT_32;
	ram_mode.coef_read = BIT_16;
	ram_mode.operand1_write = BIT_32;
	ram_mode.operand1_read = BIT_16;
	ram_mode.operand0_write = BIT_32;
	ram_mode.operand0_read = BIT_16;
	//*ram_ctl = 0x111;
	efpga_ram_set_mode(ram_ctl, ram_mode);
	ram_adr->w[0] = 0xdeadbeef;
#if EFPGA_DEBUG
	sprintf(message,"ram_adr->w[0]= 0x%0x\r\n",ram_adr->w[0]);
	dbg_str(message);
#endif
	for (i = 0; i < 2; i++) {
		//rdbuff_hw[i] = efpga->m0_oper0.hw[i];
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->hw[%d]= 0x%0x\r\n",i, ram_adr->hw[i]);
		dbg_str(message);
#endif
		if(ram_adr->hw[i] != rdbuff_hw[i]) err++;
	}
	memset(&ram_adr->w[0],0x0, 1);

#if EFPGA_DEBUG
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
	dbg_str("writing 16bit and reading 32bit Test\n\r\r\r");
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
	ram_mode.coef_write = BIT_16;
	ram_mode.coef_read = BIT_32;
	ram_mode.operand1_write = BIT_16;
	ram_mode.operand1_read = BIT_32;
	ram_mode.operand0_write = BIT_16;
	ram_mode.operand0_read = BIT_32;
	//*ram_ctl = 0x444;
	efpga_ram_set_mode(ram_ctl, ram_mode);
	for (i = 0; i < 2; i++) {
		ram_adr->hw[i] = rdbuff_hw[i];

#if EFPGA_DEBUG
		sprintf(message,"ram_adr->hw[%d]= 0x%0x\r\n",i, ram_adr->hw[i]);
		dbg_str(message);
#endif
	}
#if EFPGA_DEBUG
	sprintf(message,"ram_adr->w[0]= 0x%0x\r\n",ram_adr->w[0]);
	dbg_str(message);
#endif
	if(ram_adr->w[0] != 0xdeadbeef) err++;
	memset(&ram_adr->w[0],0x0, 1);
#if EFPGA_DEBUG
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
	dbg_str("writing 8bit and reading 16bit Test\n\r\r\r");
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
	ram_mode.coef_write = BIT_8;
	ram_mode.coef_read = BIT_16;
	ram_mode.operand1_write = BIT_8;
	ram_mode.operand1_read = BIT_16;
	ram_mode.operand0_write = BIT_8;
	ram_mode.operand0_read = BIT_16;
	//*ram_ctl = 0x999;
	efpga_ram_set_mode(ram_ctl, ram_mode);
	for (i = 0; i < 4; i++) {
		ram_adr->b[i] = rdbuff_b[i];
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->b[%d]= 0x%0x\r\n",i, ram_adr->b[i]);
		dbg_str(message);
#endif
	}
	for (i = 0; i < 2; i++) {
		//rdbuff_hw[i] = efpga->m0_oper0.hw[i];
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->hw[%d]= 0x%0x\r\n",i, ram_adr->hw[i]);
		dbg_str(message);
#endif
		if(ram_adr->hw[i] != rdbuff_hw[i]) err++;
	}
	memset(&ram_adr->w[0],0x0, 1);
#if EFPGA_DEBUG
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
	dbg_str("writing 16bit and reading 8bit Test\n\r\r\r");
	dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
	ram_mode.coef_write = BIT_16;
	ram_mode.coef_read = BIT_8;
	ram_mode.operand1_write = BIT_16;
	ram_mode.operand1_read = BIT_8;
	ram_mode.operand0_write = BIT_16;
	ram_mode.operand0_read = BIT_8;
	//*ram_ctl = 0x666;
	efpga_ram_set_mode(ram_ctl, ram_mode);
	for (i = 0; i < 2; i++) {
		ram_adr->hw[i] = rdbuff_hw[i];
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->hw[%d]= 0x%0x\r\n",i, ram_adr->hw[i]);
		dbg_str(message);
#endif
	}

	for (i = 0; i < 4; i++) {
#if EFPGA_DEBUG
		sprintf(message,"ram_adr->b[%d]= 0x%0x\r\n",i, ram_adr->b[i]);
		dbg_str(message);
#endif
		if(ram_adr->b[i] != rdbuff_b[i]) err++;
	}
	memset(&ram_adr->w[0],0x0, 1);
	/*
			for (i = 0; i < 4; i++) {
				efpga->m0_oper0[i] = (rdbuff1 +i*4);
				sprintf(message,"m0_oper0[%d]= 0x%0x\r\n",i, efpga->m0_oper0[i]);
				dbg_str(message);
			}
	*/
	vPortFree(message);
	return err;

}

static void ram_32bit_16bit_8bit_test(const struct cli_cmd_entry *pEntry)
{
		(void)pEntry;
	    // Add functionality here
		char *message;
		apb_soc_ctrl_typedef *soc_ctrl;
		ram_word *ram_addr;
		unsigned int i;
		unsigned int test_no;
		unsigned int errors = 0;
		volatile unsigned int *ram_ctrl;
		soc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
		soc_ctrl->rst_efpga = 0xf;  //release efpga reset
		soc_ctrl->ena_efpga = 0x7f; // enable all interfaces
		message  = pvPortMalloc(80);
		test_no = 1;
		do {
		switch(test_no) {
		case 1:
			ram_ctrl = (volatile unsigned int *)( EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL);
			ram_addr = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER0);
			if( ram_rw_test(ram_addr,ram_ctrl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0){
				dbg_str("m0_oper0_6_rw_test: <<FAILED>>\r\n");
			} else {
				dbg_str("m0_oper0_6_rw_test: <<PASSED>>\r\n");
			}
#endif
			break;
		case 2:
			ram_ctrl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL);
			ram_addr = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER1);
			ram_rw_test(ram_addr,ram_ctrl);
			if( ram_rw_test(ram_addr,ram_ctrl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m0_oper1_6_rw_test: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m0_oper1_6_rw_test: <<PASSED>>\n\r\r\r");
			}
#endif
			break;
		case 3:
			ram_ctrl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL);
			ram_addr = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_COEF);
			ram_rw_test(ram_addr,ram_ctrl);
			if( ram_rw_test(ram_addr,ram_ctrl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m0_coef_6_rw_tests: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m0_coef_6_rw_tests: <<PASSED>>\n\r\r\r");
			}
#endif
			break;
		case 4:
			ram_ctrl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_RAM_CONTROL);
			ram_addr = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER0);
			ram_rw_test(ram_addr,ram_ctrl);

			if( ram_rw_test(ram_addr,ram_ctrl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m1_oper0_6_rw_tests: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m1_oper0_6_rw_tests: <<PASSED>>\n\r\r\r");
			}
#endif
			break;
		case 5:
			ram_ctrl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_RAM_CONTROL);
			ram_addr = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER1);
			ram_rw_test(ram_addr,ram_ctrl);
			if( ram_rw_test(ram_addr,ram_ctrl) != 0)errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m1_oper1_6_rw_tests: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m1_oper1_6_rw_tests: <<PASSED>>\n\r\r\r");
			}
#endif
			break;
		case 6:
			ram_ctrl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_RAM_CONTROL);
			ram_addr = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_COEF);
			ram_rw_test(ram_addr,ram_ctrl);
			if( ram_rw_test(ram_addr,ram_ctrl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m1_coef_6_rw_tests: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m1_coef_6_rw_tests: <<PASSED>>\n\r\r\r");
			}
#endif
			break;
		default:
			break;
		}
		test_no ++;
	}while(test_no < 7);

	(errors == 0)?(dbg_str("RAMs RW TEST:<<PASSED>>\r\n")):(dbg_str("RAMs RW TEST:<<FAILED>>\r\n"));
	vPortFree(message);
}

static unsigned int mltiply_test(ram_word *ram_adr1, ram_word *ram_adr2, mlti_ctl *mctl)
{
	char *message;
	unsigned int errors = 0;
	unsigned int i, test_type, exp_data_out, data_out;
	unsigned int mlt_type;
	message  = pvPortMalloc(80);
	test_type = 1;
	do{
		switch(test_type) {
		case 1:
			mlt_type = 0;
			do {
				*mctl->m_ctl = 0x80000000;
				*mctl->m_ctl = 0x0;
				errors = 0;

				*mctl->m_odata = 0x2;
				*mctl->m_cdata = 0x3;
				*mctl->m_ctl = (0x40000 | ((mlt_type & 0x3) << 12));
				exp_data_out = (*mctl->m_odata) * (*mctl->m_cdata);
				if ((*mctl->m_data_out) != 0x0) errors ++;
				*mctl->m_clken = 0xf;
				data_out = (*mctl->m_data_out);
				if (mlt_type != 3) {
					if(data_out != exp_data_out) errors ++;
				}
#if EFPGA_DEBUG
				sprintf(message,"mctl->m_data_out = %08x\r\n",data_out);
				dbg_str(message);
#endif
				for (i = 0 ; i < 3; i++) {
					*mctl->m_clken = 0xf;
					data_out = data_out + exp_data_out;
					if (mlt_type != 3) {
						if((*mctl->m_data_out) !=  data_out) errors ++;
					}
#if EFPGA_DEBUG
					sprintf(message,"mctl->m_data_out = %08x\r\n",*mctl->m_data_out);
					dbg_str(message);
#endif
				}
#if EFPGA_DEBUG
				(errors)? dbg_str("*** Test: failed***\n"): dbg_str("###Test: passed###\n");
#endif
				mlt_type ++;
			}while(mlt_type < 4);
			break;
		case 2:

			mlt_type = 0;
			do {
				*mctl->m_ctl = 0x80000000;
				*mctl->m_ctl = 0x0;
				errors = 0;

				ram_adr1->w[0] = 0x4;
				ram_adr2->w[0] = 0x5;
				*mctl->m_ctl = (0x4c000 | ((mlt_type & 0x3) << 12));
				exp_data_out = (ram_adr1->w[0]) * (ram_adr2->w[0]);
				if ((*mctl->m_data_out) != 0x0) errors ++;
				*mctl->m_clken = 0xf;
				data_out = *mctl->m_data_out;
				if (mlt_type != 3) {
					if(data_out != exp_data_out) errors ++;
				}


#if EFPGA_DEBUG
				sprintf(message,"mctl->m_data_out = %08x\r\n",data_out);
				dbg_str(message);
#endif

				for (i = 0 ; i < 3; i++) {
					*mctl->m_clken = 0xf;
					data_out = data_out + exp_data_out;
					if (mlt_type != 3) {
						if((*mctl->m_data_out) !=  data_out) errors ++;

					}
#if EFPGA_DEBUG
					sprintf(message,"mctl->m_data_out = %08x\r\n",*mctl->m_data_out);
					dbg_str(message);
#endif
				}
#if EFPGA_DEBUG
			(errors)? dbg_str("*** Test: failed***\n"): dbg_str("###Test: passed###\n");
#endif
			mlt_type ++;
			}while(mlt_type < 4);

			break;
		default:
			break;
		}
		test_type ++;
	}while(test_type <= 2 );

	vPortFree(message);
	return errors;
}
static void enableMultiplyOperation(uint32_t *aReg)
{
	if( aReg )
		*aReg = 0x0f;	//Any write to the clock enable register will enable a multiply operation.
}

#define MATH_UNIT0_MULTIPLIER_0		0
#define MATH_UNIT0_MULTIPLIER_1		1
#define MATH_UNIT1_MULTIPLIER_0		2
#define MATH_UNIT1_MULTIPLIER_1		3



uint32_t mathUnitMultiplierTest(uint8_t aMathMultNum)
{
	// Add functionality here

	uint8_t mlt_type = 0;
	uint32_t i = 0, lOperandSource = 0;
	uint32_t lErrorCount = 0, lCount = 0;
	uint32_t lPattern = 0;
	uint32_t lCumulativeMultiplierOutput = 0;
	uint32_t lHigherOrderCumulativeMultiplierOutput = 0;
	uint32_t lIndividualMultiplierOutput = 0;
	uint32_t lOperandData = 0;
	uint32_t lCoefficientData = 0;
	uint64_t lExpectedData = 0;
	uint32_t lDummy1 = 0, lDummy2 = 0;

	uint32_t *m_ctl = (uint32_t *)NULL;
	uint32_t *m_clken = (uint32_t *)NULL;
	uint32_t *m_odata = (uint32_t *)NULL;
	uint32_t *m_cdata = (uint32_t *)NULL;
	uint32_t *m_data_out = (uint32_t *)NULL;
	ram_word *ram_addr1 = (ram_word *)NULL;
	ram_word *ram_addr2 = (ram_word *)NULL;
	uint32_t *ram_m0_ctl = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL);
	uint32_t *ram_m1_ctl = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_RAM_CONTROL);
	apb_soc_ctrl_typedef* soc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;

	if( aMathMultNum == MATH_UNIT0_MULTIPLIER_0 )
	{
		m_ctl = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M0_CONTROL);
		m_clken = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M0_CLKEN);
		m_odata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M0_ODATA);
		m_cdata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M0_CDATA);
		m_data_out = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M0_MULTOUT);
		ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER0);
		ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_COEF);
	}
	else if( aMathMultNum == MATH_UNIT0_MULTIPLIER_1 )
	{
		m_ctl = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M1_CONTROL);
		m_clken = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M1_CLKEN);
		m_odata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M1_ODATA);
		m_cdata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M1_CDATA);
		m_data_out = (uint32_t *)(EFPGA_BASE_ADDR + REG_M0_M1_MULTOUT);
		ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER1);
		ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_COEF);
	}
	else if( aMathMultNum == MATH_UNIT1_MULTIPLIER_0 )
	{
		m_ctl = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M0_CONTROL);
		m_clken = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M0_CLKEN);
		m_odata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M0_ODATA);
		m_cdata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M0_CDATA);
		m_data_out = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M0_MULTOUT);
		ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER0);
		ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_COEF);
	}
	else if( aMathMultNum == MATH_UNIT1_MULTIPLIER_1 )
	{
		m_ctl = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M1_CONTROL);
		m_clken = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M1_CLKEN);
		m_odata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M1_ODATA);
		m_cdata = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M1_CDATA);
		m_data_out = (uint32_t *)(EFPGA_BASE_ADDR + REG_M1_M1_MULTOUT);
		ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER1);
		ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_COEF);
	}

	soc_ctrl->rst_efpga = 0xf;  //release efpga reset
	soc_ctrl->ena_efpga = 0x7f; // enable all interfaces

	*ram_m0_ctl = 0x0;
	*ram_m1_ctl = 0x0;
	/*----------------------------------------------------------------------------------------------*/
	//To test 4 bit multiplication (8 4-bit multipliers will be there)
	//1. Basic multiplication which does not need more than 4 bit accumulator. For ex 2*3 = 6 which can be represented in 4 bits.
	mlt_type = 3;	//Set mode to 4 bit multiplier mode.
	lOperandData = 0x11111111;			//8 multiplications will happen. 1*0, 1*1, 1*2, 1*3, 1*4, 1*5, 1*6, 1*7
	lCoefficientData = 0x76543210;


	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];

			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<8; i++ )
		{
			lPattern = (0x0000000F << ( i*4 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*4 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*4 ) ) );
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 4 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//2. Basic multiplication which needs more than 4 bit accumulator, but with saturation bit enabled
	lOperandData = 0x88888833;			//8 multiplications will happen. 3*7, 3*6, 8*2, 8*3, 8*4, 8*5, 8*6, 8*7
	lCoefficientData = 0x76543267;
	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x00040000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x0004C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<8; i++ )
		{
			lPattern = (0x0000000F << ( i*4 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*4 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*4 ) ) );
			if( lExpectedData > 15 )
				lExpectedData = 15;		//Since we are testing the multiplier with saturation bit enabled, we also limit the output of our multiplication operation.
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 4 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//3. Basic multiplication which needs more than 4 bit accumulator, but with saturation bit disabled
	lOperandData = 0xF8888833;			//8 multiplications will happen. 3*7, 3*6, 8*2, 8*3, 8*4, 8*5, 8*6, 15*15
	lCoefficientData = 0xF6543267;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Disable saturation bit.
			*m_ctl = (uint32_t)(0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//Disable saturation bit.
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}

		if (*m_data_out != 0x0)
			lErrorCount ++;

		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;

		//Select outsel to give the next higher 4 bits of the accumulator.
		*m_ctl |= 0x04;
		lHigherOrderCumulativeMultiplierOutput = *m_data_out;

		//check all multiplier outputs
		for(i=0; i<8; i++ )
		{
			lPattern = (0x0000000F << ( i*4 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*4 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*4 ) ) );
			lIndividualMultiplierOutput = ( ( lHigherOrderCumulativeMultiplierOutput & lPattern ) >> ( i * 4 ));
			lIndividualMultiplierOutput <<= 4;
			lIndividualMultiplierOutput |= ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 4 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}


	//4. "Do not Accumulate result" test
	mlt_type = 3;	//Set mode to 4 bit multiplier mode.
	lOperandData = 0x11111111;			//8 multiplications will happen. 1*0, 1*1, 1*2, 1*3, 1*4, 1*5, 1*6, 1*7
	lCoefficientData = 0x76543210;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;

		for(lCount=0; lCount<3; lCount++)
		{
			*m_ctl |= (1 << 17);
			//Enable multiplier.
			enableMultiplyOperation(m_clken);
			lCumulativeMultiplierOutput = *m_data_out;
			//check all multiplier outputs
			for(i=0; i<8; i++ )
			{
				lPattern = (0x0000000F << ( i*4 ) );
				lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*4 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*4 ) ) );
				lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 4 ));
				if( lExpectedData != (lIndividualMultiplierOutput) )
				{
					lErrorCount++;
				}
				lPattern = 0;
			}
		}
	}


	//5. Round bit
	//A = 2, B = 3, OUT_SEL = 2 (0010 will be added to the output), RND_BIT = 1
	//MULTIPLY
	//2*3 = 6 + 0010 (2) = 8. (0000 1000)
	//MAC_OUT = 2 will be given, since OUT_SEL [5:2] is selected (0010)  - - This is the case as OUT_SEL = 2

	mlt_type = 3;	//Set mode to 4 bit multiplier mode.
	lOperandData = 0x00000002;
	lCoefficientData = 0x00000003;

	*m_ctl = 0x80000000;	//Reset accumulator
	*m_ctl = 0x0;

	*m_odata = lOperandData;
	*m_cdata = lCoefficientData;
	*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
	*m_ctl |= (1 << 16);
	//Select outsel to add 20'b0000_0000_0000_0000_0010 to result
	*m_ctl |= 0x02;
	if (*m_data_out != 0x0)
		lErrorCount ++;
	//Enable multiplier.
	enableMultiplyOperation(m_clken);
	lCumulativeMultiplierOutput = *m_data_out;
	if( lCumulativeMultiplierOutput != 2 )
	{
		lErrorCount++;
	}

	//A = 0, B = 0, OUT_SEL = 3 (0100 will be added to the output), RND_BIT = 1
	//MULTIPLY
	//0*0 = 0 + 0100 (4) = 4. (0000 0100)
	//MAC_OUT = 0 will be given, since OUT_SEL = 3, [6:3] is selected (0000)  - - This is the case as OUT_SEL = 3

	mlt_type = 3;	//Set mode to 4 bit multiplier mode.
	lOperandData = 0x00000000;
	lCoefficientData = 0x00000000;

	*m_ctl = 0x80000000;	//Reset accumulator
	*m_ctl = 0x0;

	*m_odata = lOperandData;
	*m_cdata = lCoefficientData;
	*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
	*m_ctl |= (1 << 16);
	//Select outsel to give the next higher 4 bits of the accumulator.
	*m_ctl |= 0x03;
	//Enable multiplier.
	enableMultiplyOperation(m_clken);
	lCumulativeMultiplierOutput = *m_data_out;
	if( lCumulativeMultiplierOutput != 0 )
	{
		lErrorCount++;
	}

/*---------------------------------------------------------------------------------------------------------------------------------*/
	//To test 8 bit multiplication (4 8-bit multipliers will be there)
	//1. Basic multiplication which does not need more than 4 bit accumulator. For ex 2*3 = 6 which can be represented in 4 bits.
	mlt_type = 2;	//Set mode to 8 bit multiplier mode.
	lOperandData = 0x01010101;			//4 multiplications will happen. 1*0, 1*1, 1*2, 1*3
	lCoefficientData = 0x03020100;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<4; i++ )
		{
			lPattern = (0x000000FF << ( i*8 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*8 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*8 ) ) );
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 8 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//2. Basic multiplication which needs more than 8 bit accumulator, but with saturation bit enabled
	lOperandData = 0x0A0A0A0A;			//4 multiplications will happen. 10*29, 10*28, 10*27, 10*26
	lCoefficientData = 0x1D1C1B1A;
	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x00040000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x0004C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<4; i++ )
		{
			lPattern = (0x000000FF << ( i*8 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*8 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*8 ) ) );
			if( lExpectedData > 0xFF )
				lExpectedData = 0xFF;		//Since we are testing the multiplier with saturation bit enabled, we also limit the output of our multiplication operation.
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 8 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//3. Basic multiplication which needs more than 8 bit accumulator, but with saturation bit disabled
	lOperandData = 0xFFA20AF0;			//8 multiplications will happen. 240*15, 10*182,162*10 255*255
	lCoefficientData = 0xFF0AB60F;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//Disable saturation bit.
			*m_ctl = (uint32_t)(0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Disable saturation bit.
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}

		if (*m_data_out != 0x0)
			lErrorCount ++;

		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;

		//Select outsel to give the next higher 4 bits of the accumulator.
		*m_ctl |= 0x08;
		lHigherOrderCumulativeMultiplierOutput = *m_data_out;

		//check all multiplier outputs
		for(i=0; i<4; i++ )
		{
			lPattern = (0x000000FF << ( i*8 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*8 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*8 ) ) );
			lIndividualMultiplierOutput = ( ( lHigherOrderCumulativeMultiplierOutput & lPattern ) >> ( i * 8 ));
			lIndividualMultiplierOutput <<= 8;
			lIndividualMultiplierOutput |= ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 8 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//4. "Do not Accumulate result" test
	mlt_type = 2;	//Set mode to 8 bit multiplier mode.
	lOperandData = 0x01010101;			//4 multiplications will happen. 1*0, 1*1, 1*2, 1*3
	lCoefficientData = 0x03020100;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;

		for(lCount=0; lCount<3; lCount++)
		{
			*m_ctl |= (1 << 17);
			//Enable multiplier.
			enableMultiplyOperation(m_clken);
			lCumulativeMultiplierOutput = *m_data_out;
			//check all multiplier outputs
			for(i=0; i<4; i++ )
			{
				lPattern = (0x000000FF << ( i*8 ) );
				lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*8 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*8 ) ) );
				lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 8 ));
				if( lExpectedData != (lIndividualMultiplierOutput) )
				{
					lErrorCount++;
				}
				lPattern = 0;
			}
		}
	}

	//5. Round bit
	//A = 2, B = 3, OUT_SEL = 2 (0010 will be added to the output), RND_BIT = 1
	//MULTIPLY
	//2*3 = 6 + 0010 (2) = 8. (0000 1000)
	//MAC_OUT = 2 will be given, since OUT_SEL [5:2] is selected (0010)  - - This is the case as OUT_SEL = 2

	mlt_type = 2;	//Set mode to 8 bit multiplier mode.
	lOperandData = 0x00000002;
	lCoefficientData = 0x00000003;

	*m_ctl = 0x80000000;	//Reset accumulator
	*m_ctl = 0x0;

	*m_odata = lOperandData;
	*m_cdata = lCoefficientData;
	*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
	*m_ctl |= (1 << 16);
	//Select outsel to add 24'b0000_0000_0000_0000_0000_0010 to result
	*m_ctl |= 0x02;
	if (*m_data_out != 0x0)
		lErrorCount ++;
	//Enable multiplier.
	enableMultiplyOperation(m_clken);
	lCumulativeMultiplierOutput = *m_data_out;
	if( lCumulativeMultiplierOutput != 2 )
	{
		lErrorCount++;
	}

	//A = 0, B = 0, OUT_SEL = 3 (0100 will be added to the output), RND_BIT = 1
	//MULTIPLY
	//0*0 = 0 + 0100 (4) = 4. (0000 0100)
	//MAC_OUT = 0 will be given, since OUT_SEL = 3, [6:3] is selected (0000)  - - This is the case as OUT_SEL = 3

	mlt_type = 2;	//Set mode to 8 bit multiplier mode.
	lOperandData = 0x00000000;
	lCoefficientData = 0x00000000;

	*m_ctl = 0x80000000;	//Reset accumulator
	*m_ctl = 0x0;

	*m_odata = lOperandData;
	*m_cdata = lCoefficientData;
	*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
	*m_ctl |= (1 << 16);
	//Select outsel to add 24'b0000_0000_0000_0000_0000_0100 to result
	*m_ctl |= 0x03;
	//Enable multiplier.
	enableMultiplyOperation(m_clken);
	lCumulativeMultiplierOutput = *m_data_out;
	if( lCumulativeMultiplierOutput != 0 )
	{
		lErrorCount++;
	}

	/*---------------------------------------------------------------------------------------------------------------------------------*/
	//To test 16 bit multiplication (2 16-bit multipliers will be there)
	//1. Basic multiplication which does not need more than 4 bit accumulator. For ex 2*3 = 6 which can be represented in 4 bits.
	mlt_type = 1;	//Set mode to 16 bit multiplier mode.
	lOperandData = 0x001A0003;			//2 multiplications will happen. 1*0, 1*1
	lCoefficientData = 0x00230004;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<2; i++ )
		{
			lPattern = (0x0000FFFF << ( i*16 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*16 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*16 ) ) );
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 16 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//2. Basic multiplication which needs more than 16 bit accumulator, but with saturation bit enabled
	lOperandData = 0x8CA08CA0;			//4 multiplications will happen. 10*29, 10*28, 10*27, 10*26
	lCoefficientData = 0x00030002;
	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x00040000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x0004C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<2; i++ )
		{
			lPattern = (0x0000FFFF << ( i*16 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*16 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*16 ) ) );
			if( lExpectedData > 0xFFFF )
				lExpectedData = 0xFFFF;		//Since we are testing the multiplier with saturation bit enabled, we also limit the output of our multiplication operation.
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 16 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//3. Basic multiplication which needs more than 16 bit accumulator, but with saturation bit disabled
	lOperandData = 0xFFFF8CA0;			//2 multiplications will happen. 36000*2, 65535*65535
	lCoefficientData = 0xFFFF000F;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//Disable saturation bit.
			*m_ctl = (uint32_t)(0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Disable saturation bit.
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}

		if (*m_data_out != 0x0)
			lErrorCount ++;

		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;

		//Select outsel to give the next higher 4 bits of the accumulator.
		*m_ctl |= 0x10;	//16
		lHigherOrderCumulativeMultiplierOutput = *m_data_out;

		//check all multiplier outputs
		for(i=0; i<2; i++ )
		{
			lPattern = (0x0000FFFF << ( i*16 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*16 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*16 ) ) );
			lIndividualMultiplierOutput = ( ( lHigherOrderCumulativeMultiplierOutput & lPattern ) >> ( i * 16 ));
			lIndividualMultiplierOutput <<= 16;
			lIndividualMultiplierOutput |= ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 16 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//4. "Do not Accumulate result" test
	mlt_type = 1;	//Set mode to 16 bit multiplier mode.
	lOperandData = 0x00010001;			//2 multiplications will happen. 1*4, 1*3
	lCoefficientData = 0x00030004;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;

		for(lCount=0; lCount<3; lCount++)
		{
			*m_ctl |= (1 << 17);
			//Enable multiplier.
			enableMultiplyOperation(m_clken);
			lCumulativeMultiplierOutput = *m_data_out;
			//check all multiplier outputs
			for(i=0; i<2; i++ )
			{
				lPattern = (0x0000FFFF << ( i*16 ) );
				lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*16 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*16 ) ) );
				lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 16 ));
				if( lExpectedData != (lIndividualMultiplierOutput) )
				{
					lErrorCount++;
				}
				lPattern = 0;
			}
		}
	}

	//5. Round bit
	//A = 2, B = 3, OUT_SEL = 2 (0010 will be added to the output), RND_BIT = 1
	//MULTIPLY
	//2*3 = 6 + 0010 (2) = 8. (0000 1000)
	//MAC_OUT = 2 will be given, since OUT_SEL [17:2] is selected (0010)  - - This is the case as OUT_SEL = 2

	mlt_type = 1;	//Set mode to 16 bit multiplier mode.
	lOperandData = 0x00000002;
	lCoefficientData = 0x00000003;

	*m_ctl = 0x80000000;	//Reset accumulator
	*m_ctl = 0x0;

	*m_odata = lOperandData;
	*m_cdata = lCoefficientData;
	*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
	*m_ctl |= (1 << 16);
	//Select outsel to add 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0010 to result
	*m_ctl |= 0x02;
	if (*m_data_out != 0x0)
		lErrorCount ++;
	//Enable multiplier.
	enableMultiplyOperation(m_clken);
	lCumulativeMultiplierOutput = *m_data_out;
	if( lCumulativeMultiplierOutput != 2 )
	{
		lErrorCount++;
	}

	//A = 0, B = 0, OUT_SEL = 3 (0100 will be added to the output), RND_BIT = 1
	//MULTIPLY
	//0*0 = 0 + 0100 (4) = 4. (0000 0100)
	//MAC_OUT = 0 will be given, since OUT_SEL = 3, [18:3] is selected (0000)  - - This is the case as OUT_SEL = 3

	mlt_type = 1;	//Set mode to 16 bit multiplier mode.
	lOperandData = 0x00000000;
	lCoefficientData = 0x00000000;

	*m_ctl = 0x80000000;	//Reset accumulator
	*m_ctl = 0x0;

	*m_odata = lOperandData;
	*m_cdata = lCoefficientData;
	*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
	*m_ctl |= (1 << 16);
	//Select outsel to add 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0100 to result
	*m_ctl |= 0x03;
	//Enable multiplier.
	enableMultiplyOperation(m_clken);
	lCumulativeMultiplierOutput = *m_data_out;
	if( lCumulativeMultiplierOutput != 0 )
	{
		lErrorCount++;
	}

	/*---------------------------------------------------------------------------------------------------------------------------------*/
	//To test 32 bit multiplication (1 32-bit multipliers will be there)
	//1. Basic multiplication which does not need more than 32 bit accumulator. For ex 2*3 = 6 which can be represented in 4 bits.
	mlt_type = 0;	//Set mode to 32 bit multiplier mode.
	lOperandData = 0x1A001A00;			//1 multiplications will happen.
	lCoefficientData = 0x00000002;

	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			*m_ctl = (0x00000000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			*m_ctl = (uint32_t)(0x0000C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<1; i++ )
		{
			lPattern = (0xFFFFFFFF << ( i*32 ) );
			lExpectedData = ( ( ( lOperandData & lPattern ) >> ( i*32 ) ) * ( ( lCoefficientData & lPattern ) >> ( i*32 ) ) );
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 32 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	//2. Basic multiplication which needs more than 32 bit accumulator, but with saturation bit enabled
	lOperandData = 0xFFFFFFFE;			//1 multiplications will happen. 0xFFFFFFFE * 2
	lCoefficientData = 0x00000002;
	for(lOperandSource = 0; lOperandSource < 2; lOperandSource++)
	{
		*m_ctl = 0x80000000;	//Reset accumulator
		*m_ctl = 0x0;
		if( lOperandSource == 0 )	//Select the operand source as efpga register.
		{
			*m_odata = lOperandData;
			*m_cdata = lCoefficientData;
			ram_addr1->w[0] = 0x0;
			ram_addr2->w[0] = 0x0;
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x00040000 | ((mlt_type & 0x3) << 12));
		}
		else if( lOperandSource == 1 )	//Select the operand source as efpga RAM.
		{
			*m_odata = 0x0;
			*m_cdata = 0x0;
			ram_addr1->w[0] = lOperandData;
			ram_addr2->w[0] = lCoefficientData;
			//The dummy read of RAM address is required so that the multiplication result are read correctly.
			lDummy1 = ram_addr1->w[0];
			lDummy2 = ram_addr2->w[0];
			//Enable saturation bit.
			*m_ctl = (uint32_t)(0x0004C000 | ((mlt_type & 0x3) << 12));
		}
		if (*m_data_out != 0x0)
			lErrorCount ++;
		//Enable multiplier.
		enableMultiplyOperation(m_clken);
		lCumulativeMultiplierOutput = *m_data_out;
		//check all multiplier outputs
		for(i=0; i<1; i++ )
		{
			lPattern = (0xFFFFFFFF << ( i*32 ) );

			lExpectedData = 0xFFFFFFFF;		//Since we are testing the multiplier with saturation bit enabled, we also limit the output of our multiplication operation.
			lIndividualMultiplierOutput = ( ( lCumulativeMultiplierOutput & lPattern ) >> ( i * 32 ));
			if( lExpectedData != (lIndividualMultiplierOutput) )
			{
				lErrorCount++;
			}
			lPattern = 0;
		}
	}

	return lErrorCount;
}

static void mathUnit0Multiplier0_test(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	uint32_t lSts = 0;
	lSts = mathUnitMultiplierTest(MATH_UNIT0_MULTIPLIER_0);
	if( lSts == 0 )
		dbg_str("MA0-MU0 <<PASSED>>\r\n");
	else
		dbg_str("MA0-MU0 <<FAILED>>\r\n");
}

static void mathUnit0Multiplier1_test(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	uint32_t lSts = 0;
	lSts = mathUnitMultiplierTest(MATH_UNIT0_MULTIPLIER_1);
	if( lSts == 0 )
		dbg_str("MA0-MU1 <<PASSED>>\r\n");
	else
		dbg_str("MA0-MU1 <<FAILED>>\r\n");

}

static void mathUnit1Multiplier0_test(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	uint32_t lSts = 0;
	lSts = mathUnitMultiplierTest(MATH_UNIT1_MULTIPLIER_0);
	if( lSts == 0 )
		dbg_str("MA1-MU0 <<PASSED>>\r\n");
	else
		dbg_str("MA1-MU0 <<FAILED>>\r\n");

}

static void mathUnit1Multiplier1_test(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	uint32_t lSts = 0;
	lSts = mathUnitMultiplierTest(MATH_UNIT1_MULTIPLIER_1);
	if( lSts == 0 )
		dbg_str("MA1-MU1 <<PASSED>>\r\n");
	else
		dbg_str("MA1-MU1 <<FAILED>>\r\n");

}

static void m_mltiply_test(const struct cli_cmd_entry *pEntry)
{

	    (void)pEntry;
	    // Add functionality here
		char *message;
		apb_soc_ctrl_typedef *soc_ctrl;
		ram_word *ram_addr1, *ram_addr2;
		mlti_ctl mt_ctl;
		unsigned int test_no;
		volatile unsigned int *ram_m0_ctl;
		unsigned int errors = 0;
		soc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
		soc_ctrl->rst_efpga = 0xf;  //release efpga reset
		soc_ctrl->ena_efpga = 0x7f; // enable all interfaces
		message  = pvPortMalloc(80);

		ram_m0_ctl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL);
		*ram_m0_ctl = 0x0;

		test_no = 1;
		do {
		switch(test_no) {
		case 1:
#if EFPGA_DEBUG
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
			dbg_str("M0_M0_Multiplier Test\n\r\r\r");
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
			mt_ctl.m_ctl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M0_CONTROL);
			mt_ctl.m_clken = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M0_CLKEN);
			mt_ctl.m_odata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M0_ODATA);
			mt_ctl.m_cdata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M0_CDATA);
			mt_ctl.m_data_out = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M0_MULTOUT);
			ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER0);
			ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_COEF);


			if( mltiply_test(ram_addr1, ram_addr2, &mt_ctl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m0_m0_ctl_operation: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m0_m0_ctl_operation: <<PASSED>>\n\r\r\r");
			}
#endif
			break;
		case 2:
#if EFPGA_DEBUG
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
			dbg_str("M0_M1_Multiplier Test\n\r\r\r");
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
			mt_ctl.m_ctl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M1_CONTROL);
			mt_ctl.m_clken = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M1_CLKEN);
			mt_ctl.m_odata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M1_ODATA);
			mt_ctl.m_cdata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M1_CDATA);
			mt_ctl.m_data_out = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M0_M1_MULTOUT);
			ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER1);
			ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_COEF);

			if( mltiply_test(ram_addr1, ram_addr2, &mt_ctl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0){
				dbg_str("m0_m1_ctl_operation: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m0_m1_ctl_operation: <<PASSED>>\n\r\r\r");
			}
#endif
			break;

		case 3:
#if EFPGA_DEBUG
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
			dbg_str("M1_M0_Multiplier Test\n\r\r\r");
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
			mt_ctl.m_ctl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M0_CONTROL);
			mt_ctl.m_clken = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M0_CLKEN);
			mt_ctl.m_odata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M0_ODATA);
			mt_ctl.m_cdata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M0_CDATA);
			mt_ctl.m_data_out = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M0_MULTOUT);
			ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER0);
			ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_COEF);

			if( mltiply_test(ram_addr1, ram_addr2, &mt_ctl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0) {
				dbg_str("m1_m0_ctl_operation: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m1_m0_ctl_operation: <<PASSED>>\n\r\r\r");
			}
#endif
			break;

		case 4:
#if EFPGA_DEBUG
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
			dbg_str("M1_M1_Multiplier Test\n\r\r\r");
			dbg_str("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\r\r\r");
#endif
			mt_ctl.m_ctl = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M1_CONTROL);
			mt_ctl.m_clken = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M1_CLKEN);
			mt_ctl.m_odata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M1_ODATA);
			mt_ctl.m_cdata = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M1_CDATA);
			mt_ctl.m_data_out = (volatile unsigned int *)(EFPGA_BASE_ADDR + REG_M1_M1_MULTOUT);
			ram_addr1 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER1);
			ram_addr2 = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_COEF);

			if( mltiply_test(ram_addr1, ram_addr2, &mt_ctl) != 0) errors++;
#if EFPGA_ERROR
			if(errors != 0)  {
				dbg_str("m1_m1_ctl_operation: <<FAILED>>\n\r\r\r");
			} else {
				dbg_str("m1_m1_ctl_operation: <<PASSED>>\n\r\r\r");
			}
#endif
						break;

			break;

		default:
			break;
		}
		test_no ++;
	}while(test_no < 5);

	(errors == 0)?(dbg_str("MULTIPLIER TEST:<<PASSED>>\r\n")):(dbg_str("MULTIPLIER TEST:<<FAILED>>\r\n"));
	vPortFree(message);
}


static void ram_test(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	    // Add functionality here
		char *message;
		uint32_t offset;
		apb_soc_ctrl_typedef *soc_ctrl;
		ram_word *ram_addr[6];
		unsigned int errors = 0;
		unsigned int global_err = 0;
		int i, j,k;
		soc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
		soc_ctrl->rst_efpga = 0x0;  //assert efpga reset
		soc_ctrl->rst_efpga = 0xf;  //release efpga reset
		soc_ctrl->ena_efpga = 0x7f; // enable all interfaces
		message  = pvPortMalloc(80);
		// Init all rams to 0
		for(k = 0; k < 6; k++) {
			ram_addr[k] = (EFPGA_BASE_ADDR + (k+1)* REG_M0_OPER0);
		}
		//TODO: Put the RAM in 32-bit mode.

#if EFPGA_ERROR
		sprintf(message,"Testing 6RAMs :");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{	//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0; i < 512; i++) {
				for(j = 0; j < 6; j++ ){
					ram_addr[j]->w[i] = 0;
				}
			}
			for (i = 512; i < 1024; i++) { // expect 0xffffffff in next 512 locations
				for(j = 0; j < 6; j++ ){
					if(ram_addr[j]->w[i] != 0xffffffff) errors++;
				}
			}
		}
		else
		{	//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0; i < 1024; i++) {
				for(j = 0; j < 6; j++ ){
					ram_addr[j]->w[i] = 0;
				}
			}
			for (i = 0; i < 1024; i++) { // expect 0 in all locations
				for(j = 0; j < 6; j++ ){
					if(ram_addr[j]->w[i] != 0) errors++;
				}
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;
#if EFPGA_ERROR
		sprintf(message,"Testing m0_oper0");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{	//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0; i < 512; i++) {
				ram_addr[0]->w[i] = i;
			}
			for (i = 0; i < 512; i++) {
				if (ram_addr[0]->w[i+512] != ~i) {
					if (errors++ < 10) {
#if EFPGA_DEBUG
						sprintf(message,"m0_oper0[%d] = %x\r\n",i,efpga->m0_oper0.w[i]);
						dbg_str(message);
#endif
					}
				}
			}
		}
		else
		{
			//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0; i < 1024; i++) {
				ram_addr[0]->w[i] = i;
			}
			for (i = 0; i < 1024; i++) {
				if (ram_addr[0]->w[i] != i) {
					errors++;
				}
			}
		}
		global_err += errors;

#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;
#if EFPGA_ERROR
		sprintf(message,"Testing m0_oper1");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{
			//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0 ; i < 512; i++) {
				ram_addr[1]->w[i] = i;
			}
			for (i = 0 ; i < 512; i++) {
				if (ram_addr[1]->w[i+512] != ~i)
					if (errors++ < 10) {
#if EFPGA_DEBUG
				sprintf(message,"m0_oper1[%d] = %x\r\n",i,efpga->m0_oper0.w[i]);
				dbg_str(message);
#endif
					}
			}
		}
		else
		{
			//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0 ; i < 1024; i++) {
				ram_addr[1]->w[i] = i;
			}
			for (i = 0 ; i < 1024; i++) {
				if (ram_addr[1]->w[i] != i)
					errors++;
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;

#if EFPGA_ERROR
		sprintf(message,"Testing m0_coef");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{
			//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0 ; i < 512; i++) {
				ram_addr[2]->w[i] = i;
			}
			for (i = 0 ; i < 512; i++) {
				if (ram_addr[2]->w[i+512] != ~i) errors++;
			}
		}
		else
		{
			//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0 ; i < 1024; i++) {
				ram_addr[2]->w[i] = i;
			}
			for (i = 0 ; i < 1024; i++) {
				if (ram_addr[2]->w[i] != i) errors++;
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;
#if EFPGA_ERROR
		sprintf(message,"Testing m1_oper0");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{
			//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0 ; i < 512; i++) {
				ram_addr[3]->w[i] = i;
			}
			for (i = 0 ; i < 512; i++) {
				if (ram_addr[3]->w[i+512] != ~i) errors++;
			}
		}
		else
		{
			//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0 ; i < 1024; i++) {
				ram_addr[3]->w[i] = i;
			}
			for (i = 0 ; i < 1024; i++) {
				if (ram_addr[3]->w[i] != i) errors++;
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;
#if EFPGA_ERROR
		sprintf(message,"Testing m1_oper1");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{
			//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0 ; i < 512; i++) {
				ram_addr[4]->w[i] = i;
			}
			for (i = 0 ; i < 512; i++) {
				if (ram_addr[4]->w[i+512] != ~i) errors++;
			}
		}
		else
		{
			//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0 ; i < 1024; i++) {
				ram_addr[4]->w[i] = i;
			}
			for (i = 0 ; i < 1024; i++) {
				if (ram_addr[4]->w[i] != i) errors++;
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;
#if EFPGA_ERROR
		sprintf(message,"Testing m1_coef");
		dbg_str(message);
#endif
		if( gSimulatorEnabledFlg == 0 )
		{
			//To run on FPGA emulation, the eFPGA RAM is not fully instantiated. So half of it will appear inverted
			for (i = 0 ; i < 512; i++) {
				ram_addr[5]->w[i] = i;
			}
			for (i = 0 ; i < 512; i++) {
				if (ram_addr[5]->w[i+512] != ~i) errors++;
			}
		}
		else
		{
			//To run on Questa Sim simulation, the eFPGA RAM is fully instantiated. So it will appear as it is.
			for (i = 0 ; i < 1024; i++) {
				ram_addr[5]->w[i] = i;
			}
			for (i = 0 ; i < 1024; i++) {
				if (ram_addr[5]->w[i] != i) errors++;
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			sprintf(message," <<PASSED>>\r\n");
		else
			sprintf(message," <<FAILED>>\r\n");
		dbg_str(message);
#endif
		errors = 0;
		(global_err == 0)?(dbg_str("eFPGA RAM TEST: <<PASSED>>\r\n")):(dbg_str("eFPGA RAM TEST: <<FAILED>>\r\n"));
		vPortFree(message);
}

static void tcdm_test(const struct cli_cmd_entry *pEntry)
{

    (void)pEntry;
    // Add functionality here
	uint32_t *scratch;
	char *message;
	uint32_t lDestinationAddress = 0;
	apb_soc_ctrl_typedef *soc_ctrl;
	//efpga_typedef *efpga;
	volatile unsigned int *m0_ctl, *m1_ctl, *tcdm_ctl[4];
	ram_word *ram_addr[4];
	message  = pvPortMalloc(80);
	scratch = pvPortMalloc(256);
	//efpga = (efpga_typedef*)EFPGA_BASE_ADDR;  // base address of efpga
	lDestinationAddress = (unsigned int)scratch & 0xFFFFF;
	soc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
	soc_ctrl->control_in = 0;
	soc_ctrl->rst_efpga = 0xf;
	soc_ctrl->ena_efpga = 0x7f;

	m0_ctl = EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL;
	m1_ctl = EFPGA_BASE_ADDR + REG_M1_RAM_CONTROL;
	*m0_ctl = 0x0;
	*m1_ctl = 0x0;
#if EFPGA_DEBUG
	sprintf(message,"TCDM test - Scratch offset = %x\r\n", offset);
	dbg_str(message);
#endif
	{
		unsigned int i, j, k;
		unsigned int errors = 0;
		unsigned int global_err = 0;
		//i = efpga->test_read;
#if EFPGA_DEBUG
		sprintf(message,"eFPGA access test read = %x \r\n", i);
		dbg_str(message);
#endif
		//Set the TCDM control registers to correct base addresses
		tcdm_ctl[0] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P0 );
		tcdm_ctl[1] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P1 );
		tcdm_ctl[2] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P2 );
		tcdm_ctl[3] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P3 );

		//Set the Multiplier operand RAM addresses. Each of which is 4096 bytes (4 KB)
		ram_addr[0] = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER0);
		ram_addr[1] = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER1);
		ram_addr[2] = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER0);
		ram_addr[3] = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER1);

		soc_ctrl->control_in = 0x100000;
		for(i = 0; i < 4; i++) {
			*tcdm_ctl[i] = 0x00000000 | (lDestinationAddress +i*0x40);
		}
// Initialize eFPGA RAMs
		for (i = 0; i < 0x40; i = i + 1) {
			scratch[i] = 0;
			for(k = 0; k < 4; k++) {
				ram_addr[k]->w[i] = i + (k*0x10);
			}
		}
		soc_ctrl->control_in = 0x10000f;
		vTaskDelay(1);
		for (i = 0;i < 0x40;i = i+1) {
			j = scratch[i];
			if (j != i) {
				errors++;


#if EFPGA_DEBUG
				sprintf(message,"scratch  = %x expected %x \r\n", j, i);
				dbg_str(message);
#endif
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			dbg_str("eFPGA RAM Write Test: <<PASSED>>\r\n");
		else {
			dbg_str("eFPGA RAM Write Test: <<FAILED>>\r\n");
		}
#endif
		// Test for read from main memory and transfer into operand RAM
		errors = 0;
		soc_ctrl->control_in = 0x100000;
		for(i = 0; i < 4; i++) {
			*tcdm_ctl[i] = 0x80000000 | (lDestinationAddress +i*0x40);
		}
		for (i = 0;i < 0x40;i = i+1) {
			for(k = 0; k < 4; k++) {	//Reset the operand ram to 0 so the it can be verified if the transfer from main memory happened or not.
				ram_addr[k]->w[i] = 0;
			}
			scratch[i] = i;		//Initialize the main memory with a known pattern.
		}
		soc_ctrl->control_in = 0x10000f;
		vTaskDelay(1);
		for (i = 0;i < 0x40;i = i+1) {
			if(i < 0x10)
			j = ram_addr[0]->w[i];
			else if (i < 0x20)
			j = ram_addr[1]->w[i-0x10];
			else if (i < 0x30)
			j = ram_addr[2]->w[i-0x20];
			else
			j = ram_addr[3]->w[i-0x30];
			if (j != i) {
				errors++;
#if EFPGA_DEBUG
				sprintf(message,"mX_operY  = %x expected %x \r\n", j, i);
				dbg_str(message);
#endif
			}
		}
		global_err += errors;
#if EFPGA_ERROR
		if (errors == 0)
			dbg_str("eFPGA RAM Read Test: <<PASSED>>\r\n");
		else {
#if EFPGA_DEBUG
			sprintf(message,"*** %d Test Failures\r\n",errors);
			dbg_str(message);
#endif
			dbg_str("eFPGA RAM Read Test: FAILED\r\n");
		}
#endif
		(global_err == 0)?(dbg_str("TCDM TEST: <<PASSED>>\r\n")):(dbg_str("TCDM TEST: <<FAILED>>\r\n"));
	}
	vPortFree(scratch);
	vPortFree(message);
}

void tcdm_task( void *pParameter )
{

    (void)pParameter;
    // Add functionality here
	uint32_t *scratch;
	char *message;
	uint32_t lDestinationAddress = 0;;
	apb_soc_ctrl_typedef *soc_ctrl;
	//efpga_typedef *efpga;
	volatile unsigned int *m0_ctl, *m1_ctl, *tcdm_ctl[4];
	ram_word *ram_addr[4];
	message  = pvPortMalloc(80);
	scratch = pvPortMalloc(256);
	//efpga = (efpga_typedef*)EFPGA_BASE_ADDR;  // base address of efpga
	lDestinationAddress = (unsigned int)scratch & 0xFFFFF;
	soc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
	soc_ctrl->rst_efpga = 0xf;
	soc_ctrl->ena_efpga = 0x7f;

#if EFPGA_DEBUG
	sprintf(message,"TCDM test - Scratch offset = %x\r\n", offset);
	dbg_str(message);
#endif
	for(;;){
		m0_ctl = EFPGA_BASE_ADDR + REG_M0_RAM_CONTROL;
		m1_ctl = EFPGA_BASE_ADDR + REG_M1_RAM_CONTROL;
		*m0_ctl = 0x0;
		*m1_ctl = 0x0;
		unsigned int i, j, k;
		int errors = 0;
		//i = efpga->test_read;
#if EFPGA_DEBUG
		sprintf(message,"eFPGA access test read = %x \r\n", i);
		dbg_str(message);
#endif

		//Set the TCDM control registers to correct base addresses
		tcdm_ctl[0] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P0 );
		tcdm_ctl[1] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P1 );
		tcdm_ctl[2] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P2 );
		tcdm_ctl[3] = (unsigned int *)(EFPGA_BASE_ADDR + REG_TCDM_CTL_P3 );

		//Set the Multiplier operand RAM addresses. Each of which is 4096 bytes (4 KB)
		ram_addr[0] = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER0);
		ram_addr[1] = (ram_word *)(EFPGA_BASE_ADDR + REG_M0_OPER1);
		ram_addr[2] = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER0);
		ram_addr[3] = (ram_word *)(EFPGA_BASE_ADDR + REG_M1_OPER1);

		soc_ctrl->control_in = 0x100000;

		//Setup the TCDM control to write into a destination memory pointed by lDestinationAddress.
		//lDestinationAddress is an area in the heap memory which is a part of the main system memory.
		//The 'lDestinationAddress' is a 20 bit address which is stored in the TCDM control register.
		//31st bit - 0 is for write and 1 is for read from destination address.

		for(i = 0; i < 4; i++) {
			*tcdm_ctl[i] = 0x00000000 | (lDestinationAddress +i*0x40);
		}
// Initialize eFPGA RAMs
		for (i = 0; i < 0x40; i = i + 1) {
			scratch[i] = 0;				//Before initiating the transfer ensure that the destination is zeroed out.
			for(k = 0; k < 4; k++) {	//Fill in the pattern in the operand RAM which gets transferred into the main memory
				ram_addr[k]->w[i] = i + (k*0x10);
			}
		}
		soc_ctrl->control_in = 0x10000f;
		//Start the TCDM transfer of 16 words (0x10) indicates 16 words. = 64 bytes. 4 channels = 64*4 = 256 bytes ?? No description found
		vTaskDelay(1);
		gTCDMWriteStatus.totalTestsCount++;
		//Verify the contents if the transfer from operand RAM is moved into main memory pointed by 'lDestinationAddress'
		for (i = 0;i < 0x40;i = i+1) {
			j = scratch[i];
			if (j != i) {
				errors++;
#if EFPGA_DEBUG
				sprintf(message,"scratch  = %x expected %x \r\n", j, i);
				dbg_str(message);
#endif
			}
		}
		if (errors == 0)
		{
			//dbg_str("eFPGA RAM Write Test: <<PASSED>>\r\n");
		}
		else {
			//dbg_str("eFPGA RAM Write Test: <<FAILED>>\r\n");
			gTCDMWriteStatus.totalFailedCount++;
			gTCDMWriteStatus.totalMismatchCount += errors;
		}

		// Test for read from main memory and transfer into operand RAM
		errors = 0;
		soc_ctrl->control_in = 0x100000;
		for(i = 0; i < 4; i++) {
			*tcdm_ctl[i] = 0x80000000 | (lDestinationAddress +i*0x40);
		}

		for (i = 0;i < 0x40;i = i+1) {
			for(k = 0; k < 4; k++) {	//Reset the operand ram to 0 so the it can be verified if the transfer from main memory happened or not.
				ram_addr[k]->w[i] = 0;
			}
			scratch[i] = i;		//Initialize the main memory with a known pattern.
		}
		soc_ctrl->control_in = 0x10000f;	//Start the TCDM transfer
		vTaskDelay(1);
		gTCDMReadStatus.totalTestsCount++;
		//Verify if all the contents from the main memory are shifted into the operand RAM
		for (i = 0;i < 0x40;i = i+1) {
			if(i < 0x10)
			j = ram_addr[0]->w[i];
			else if (i < 0x20)
			j = ram_addr[1]->w[i-0x10];
			else if (i < 0x30)
			j = ram_addr[2]->w[i-0x20];
			else
			j = ram_addr[3]->w[i-0x30];
			if (j != i) {
				errors++;
#if EFPGA_DEBUG
				sprintf(message,"mX_operY  = %x expected %x \r\n", j, i);
				dbg_str(message);
#endif
			}
		}
		if (errors == 0)
		{
			//dbg_str("eFPGA RAM Read Test: <<PASSED>>\r\n");
		}
		else {
#if EFPGA_DEBUG
			sprintf(message,"*** %d Test Failures\r\n",errors);
			dbg_str(message);
#endif
			//dbg_str("eFPGA RAM Read Test: <<FAILED>>\r\n");
			gTCDMReadStatus.totalFailedCount++;
			gTCDMReadStatus.totalMismatchCount += errors;
		}
		vTaskDelay(10);
	}
	vPortFree(scratch);
	vPortFree(message);
	}


static void tcdm_task_start(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	//if( gDebugEnabledFlg == 1 )
	//	gDebugEnabledFlg = 0;

	gTCDMReadStatus.totalFailedCount = 0;
	gTCDMReadStatus.totalMismatchCount = 0;
	gTCDMReadStatus.totalTestsCount = 0;

	gTCDMWriteStatus.totalFailedCount = 0;
	gTCDMWriteStatus.totalMismatchCount = 0;
	gTCDMWriteStatus.totalTestsCount = 0;

	xTaskCreate ( tcdm_task, "tcdm_task", 1000, NULL, (UBaseType_t)(tskIDLE_PRIORITY+1), &xHandleTcmdTest);
	configASSERT( xHandleTcmdTest );
	CLI_printf("TCDM TASK STARTED <<DONE>>\n");
}


static void tcdm_task_stop(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	if( gDebugEnabledFlg == 0 )
		gDebugEnabledFlg = 1;
	if(xHandleTcmdTest != NULL) {
		vTaskDelete(xHandleTcmdTest);
		dbg_str("TCDM TASK DELETED <<DONE>>\r\n");
	}
	else {
		dbg_str("NO TCDM TASK STARTED <<PASSED>>\r\n");
		xHandleTcmdTest = NULL;
	}
}

static void tcdm_task_status(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	if( gTCDMWriteStatus.totalFailedCount == 0 )
	{
		CLI_printf("Write: Total [%d] / Failed [%d] / Mismatch [%d] <<PASSED>>\n",gTCDMWriteStatus.totalTestsCount, gTCDMWriteStatus.totalFailedCount, gTCDMWriteStatus.totalMismatchCount);
	}
	else
	{
		CLI_printf("Write: Total [%d] / Failed [%d] / Mismatch [%d] <<FAILED>>\n",gTCDMWriteStatus.totalTestsCount, gTCDMWriteStatus.totalFailedCount, gTCDMWriteStatus.totalMismatchCount);
	}

	if( gTCDMReadStatus.totalFailedCount == 0 )
	{
		CLI_printf("Read : Total [%d] / Failed [%d] / Mismatch [%d] <<PASSED>>\n",gTCDMReadStatus.totalTestsCount, gTCDMReadStatus.totalFailedCount, gTCDMReadStatus.totalMismatchCount);
	}
	else
	{
		CLI_printf("Read : Total [%d] / Failed [%d] / Mismatch [%d] <<FAILED>>\n",gTCDMReadStatus.totalTestsCount, gTCDMReadStatus.totalFailedCount, gTCDMReadStatus.totalMismatchCount);
	}
}


static void efpga_autotest(const struct cli_cmd_entry *pEntry) {
	ram_test(NULL);
	m_mltiply_test(NULL);
	ram_32bit_16bit_8bit_test(NULL);
	tcdm_test(NULL);
}

