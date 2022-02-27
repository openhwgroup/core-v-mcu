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

#include "FreeRTOS.h"
#include "semphr.h"	// Required for configASSERT

#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"
#include "drivers/include/udma_i2cm_driver.h"
#include "hal/include/hal_apb_soc_ctrl_regs.h"
#include "hal/include/hal_gpio.h"
#include "hal/include/hal_fc_event.h"
#include "hal/include/efpga_template_reg_defs.h"
#include "hal/include/adv_timer_unit_reg_defs.h"
#include "hal/include/hal_apb_i2cs.h"
#include "include/efpga_tests.h"
#include "hal/include/hal_apb_i2cs_reg_defs.h"
#include "hal/include/hal_apb_event_cntrl_reg_defs.h"

extern uint8_t gDebugEnabledFlg;
uint32_t gpio_event_test_forevent31(void);

static void csr_mstatus_reg_read(const struct cli_cmd_entry *pEntry);
static void csr_mstatus_reg_set(const struct cli_cmd_entry *pEntry);
static void csr_mstatus_reg_clear(const struct cli_cmd_entry *pEntry);

static void csr_mie_reg_read(const struct cli_cmd_entry *pEntry);
static void csr_mie_reg_set(const struct cli_cmd_entry *pEntry);
static void csr_mie_reg_clear(const struct cli_cmd_entry *pEntry);

static void csr_mip_reg_read(const struct cli_cmd_entry *pEntry);
static void csr_mip_reg_set(const struct cli_cmd_entry *pEntry);
static void csr_mip_reg_clear(const struct cli_cmd_entry *pEntry);

static void efpgaon_function(const struct cli_cmd_entry *pEntry);
static void generate_event(const struct cli_cmd_entry *pEntry);
static void test_all_events(const struct cli_cmd_entry *pEntry);

static uint32_t testEvents(uint32_t aEventNum);

extern int handler_count[];
extern uint32_t gSpecialHandlingIRQCnt;

// IO menu
const struct cli_cmd_entry intr_functions[] =
{
		CLI_CMD_SIMPLE( "mstatus", csr_mstatus_reg_read,   "mstatus has the global interrupt enable bit" ),
		CLI_CMD_SIMPLE( "mstatuss", csr_mstatus_reg_set,   "mstatuss is used to set a particular bit of mstatus" ),
		CLI_CMD_SIMPLE( "mstatusc", csr_mstatus_reg_clear,   "mstatuss is used to clear a particular bit of mstatus" ),
		CLI_CMD_SIMPLE( "mie", csr_mie_reg_read,         "mie has 32 interrupt enable" ),
		CLI_CMD_SIMPLE( "mies", csr_mie_reg_set,         "mies is used to set a particular bit of mie" ),
		CLI_CMD_SIMPLE( "miec", csr_mie_reg_clear,         "miec is used to clear a particular bit of mie" ),
		CLI_CMD_SIMPLE( "mip", csr_mip_reg_read,         "mip has 32 interrupt pending" ),
		CLI_CMD_SIMPLE( "mips", csr_mip_reg_set,         "mips is used to set a particular bit of mie" ),
		CLI_CMD_SIMPLE( "mipc", csr_mip_reg_clear,         "mipc is used to clear a particular bit of mie" ),
		CLI_CMD_SIMPLE( "efpgaon", efpgaon_function,         "efpgaon is used to initialize efpga to test events from 30-25" ),
		CLI_CMD_SIMPLE( "gen", generate_event,         "generate an event with an event number" ),
		CLI_CMD_SIMPLE( "all", test_all_events,         "test all events 18 - 31" ),
		CLI_CMD_TERMINATE()
};


static void csr_mstatus_reg_read(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	//uint32_t	ionum;
	uint32_t RegReadVal = 0;

	//CLI_uint32_required( "mux_sel", &mux_sel);
	//hal_setpinmux(ionum, mux_sel);

	RegReadVal = csr_read(CSR_MSTATUS);
	CLI_printf("CSR_MSTATUS 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void csr_mstatus_reg_set(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t bitNum = 0;
	uint32_t RegReadVal = 0;

	CLI_uint32_required( "bit number", &bitNum);
	//hal_setpinmux(ionum, mux_sel);

	csr_read_set(CSR_MSTATUS, BIT(bitNum));
	RegReadVal = csr_read(CSR_MSTATUS);
	CLI_printf("CSR_MSTATUS 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void csr_mstatus_reg_clear(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t bitNum = 0;
	uint32_t RegReadVal = 0;

	CLI_uint32_required( "bit number", &bitNum);
	//hal_setpinmux(ionum, mux_sel);

	csr_read_clear(CSR_MSTATUS, BIT(bitNum));
	RegReadVal = csr_read(CSR_MSTATUS);
	CLI_printf("CSR_MSTATUS 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void csr_mie_reg_read(const struct cli_cmd_entry *pEntry)
{
	uint32_t val = 0;
	(void)pEntry;
	// Add functionality here
	//uint32_t	ionum;
	//uint32_t	mux_sel;

	//CLI_uint32_required( "ionum", &ionum );

	val = csr_read(CSR_MIE);

	CLI_printf("CSR_MIE 0x%08x\n", val);
	dbg_str("<<DONE>>");
}

static void csr_mie_reg_set(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t bitNum = 0;
	uint32_t RegReadVal = 0;

	CLI_uint32_required( "bit number", &bitNum);
	//hal_setpinmux(ionum, mux_sel);

	csr_read_set(CSR_MIE, BIT(bitNum));
	RegReadVal = csr_read(CSR_MIE);
	CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void csr_mie_reg_clear(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t bitNum = 0;
	uint32_t RegReadVal = 0;

	CLI_uint32_required( "bit number", &bitNum);
	//hal_setpinmux(ionum, mux_sel);

	csr_read_clear(CSR_MIE, BIT(bitNum));
	RegReadVal = csr_read(CSR_MIE);
	CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void csr_mip_reg_read(const struct cli_cmd_entry *pEntry)
{
	uint32_t val = 0;
	(void)pEntry;
	// Add functionality here
	//uint32_t	ionum;
	//uint32_t	mux_sel;

	//CLI_uint32_required( "ionum", &ionum );

	val = csr_read(CSR_MIP);

	CLI_printf("CSR_MIP 0x%08x\n", val);
	dbg_str("<<DONE>>");
}

static void csr_mip_reg_set(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t bitNum = 0;
	uint32_t RegReadVal = 0;

	CLI_uint32_required( "bit number", &bitNum);
	//hal_setpinmux(ionum, mux_sel);

	csr_read_set(CSR_MIP, BIT(bitNum));
	RegReadVal = csr_read(CSR_MIP);
	CLI_printf("CSR_MIP 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void csr_mip_reg_clear(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t bitNum = 0;
	uint32_t RegReadVal = 0;

	CLI_uint32_required( "bit number", &bitNum);
	//hal_setpinmux(ionum, mux_sel);

	csr_read_clear(CSR_MIP, BIT(bitNum));
	RegReadVal = csr_read(CSR_MIP);
	CLI_printf("CSR_MIP 0x%08x\n", RegReadVal);
	dbg_str("<<DONE>>");
}

static void efpgaon_function(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	apb_soc_ctrl_typedef *lsoc_ctrl;  //Somesh: We need to use SocCtrl_t present in hal_apb_soc_ctrl_regs.h
	lsoc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
	lsoc_ctrl->control_in = 0;
	lsoc_ctrl->rst_efpga = 0xf;
	lsoc_ctrl->ena_efpga = 0x7f;
	dbg_str("<<DONE>>");
}

static void generate_event(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t eventNum = 0;

	CLI_uint32_required( "event number", &eventNum);

	testEvents(eventNum);
}

static void test_all_events(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t eventNum = 0;
	uint32_t lTestResult = 0;

	gDebugEnabledFlg = 0;
	for( eventNum = 18; eventNum < 32; eventNum++ )
	{
		lTestResult = testEvents(eventNum);
		if( lTestResult == 0 )
		{
			CLI_printf("Event %02d <<PASSED>>\r\n",eventNum);
		}
		else if( lTestResult == 0xDEADCAFE )
		{
			CLI_printf("Event %02d <<ABSENT>>\r\n",eventNum);
		}
		else
		{
			CLI_printf("Event %02d / 0x%08x <<FAILED>>\r\n",eventNum, lTestResult);
		}
	}
	gDebugEnabledFlg = 1;

}

static uint32_t testEvents(uint32_t aEventNum)
{
	uint32_t lEvent = 0;
	uint32_t lErrors = 0;
	uint32_t levent_err0 = 0;
	uint32_t lTestStatus = 0;
	uint32_t lRegCfgVal = 0;
	int lCurrentCount = 0;
	uint32_t RegReadVal = 0;
	uint8_t lI2CTxBuf[4] = {0};
	AdvTimerUnit_t *adv_timer;
	apb_soc_ctrl_typedef *lsoc_ctrl;  //Somesh: We need to use SocCtrl_t present in hal_apb_soc_ctrl_regs.h
	ApbI2cs_t *apbI2cSlave = (ApbI2cs_t*) I2CS_START_ADDR;
	ApbEventCntrl_t *ApbEventCntrl = (ApbEventCntrl_t *)SOC_EVENT_GEN_START_ADDR;
	if( aEventNum < 32 )
	{
		RegReadVal = csr_read(CSR_MSTATUS);
		if( ( RegReadVal & MSTATUS_IE ) != 0 )	//Check if global interrupt is enabled.
		{
			//Do nothing.
		}
		else
		{
			//enable global interrupt.
			csr_read_set(CSR_MSTATUS, MSTATUS_IE);
			RegReadVal = csr_read(CSR_MSTATUS);
			CLI_printf("CSR_MSTATUS 0x%08x\n", RegReadVal);
			dbg_str("<<DONE>>\r\n");

		}

		RegReadVal = csr_read(CSR_MIE);
		if( ( RegReadVal & BIT(aEventNum) ) != 0 )	//Check if the event interrupt mask is open.
		{
			//Do nothing.
		}
		else
		{
			if( ( aEventNum == 18 ) || ( aEventNum == 19 ) )
				gSpecialHandlingIRQCnt = 0;	//Reset the counter to zero before enabling the interrupt
			//open the event interrupt mask.
			csr_read_set(CSR_MIE, BIT(aEventNum));
			RegReadVal = csr_read(CSR_MIE);
			CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
			dbg_str("<<DONE>>\r\n");

		}

		if( ( aEventNum >= 16 ) && ( aEventNum <= 20 ) )
		{
			if( ( aEventNum == 18 ) || ( aEventNum == 19 ) )
			{
				//lCurrentCount = handler_count[aEventNum];
				vTaskDelay(2);
				if( gSpecialHandlingIRQCnt  >= 5 )
				{
					dbg_str("<<PASSED>>\r\n");
				}
				else
				{
					lTestStatus |= ( 1 << aEventNum );
					dbg_str("<<FAILED>>\r\n");
				}
			}
			else if( aEventNum == 20 )
			{
				hal_set_apb_i2cs_slave_on_off(1);
				if( hal_get_apb_i2cs_slave_address() !=  MY_I2C_SLAVE_ADDRESS )
					hal_set_apb_i2cs_slave_address(MY_I2C_SLAVE_ADDRESS);

				lCurrentCount = handler_count[aEventNum];

				//Enable new message available for APB to pick up interrupt.
				apbI2cSlave->i2cs_interrupt_to_apb_enable_b.new_i2c_apb_msg_avail_enable = 1;

				//Trigger an APB interrupt by writing a message from I2C side
				lI2CTxBuf[0] = 0x45;
				udma_i2cm_write (0, MY_I2C_SLAVE_ADDRESS_7BIT, I2C_MASTER_REG_MSG_I2C_APB, 1, lI2CTxBuf,  false);

				vTaskDelay(1);
				if( handler_count[aEventNum] == ( lCurrentCount + 1) )
				{
					dbg_str("<<PASSED>>\r\n");
				}
				else
				{
					lTestStatus |= ( 1 << aEventNum );
					dbg_str("<<FAILED>>\r\n");
				}
			}
			else
			{
				lTestStatus = 0xDEADCAFE;
				dbg_str("<<UNKNOWN1>>\r\n");
			}

		}
		else if( ( aEventNum >= 21 ) && ( aEventNum <= 24 ) )
		{
			if( aEventNum == 21 )
			{
				adv_timer = (AdvTimerUnit_t*) ADV_TIMER_START_ADDR;

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_0_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_0_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_RESET_COMMAND_LSB; // reset
				adv_timer->timer_0_config_register = lRegCfgVal;

				adv_timer->timer_0_threshold_register = 0x20000;
				adv_timer->timer_0_threshold_channel_0_reg = 0x30001;

				/* Somesh: Added to generate events */
				adv_timer->adv_timer_event_cfg_register_b.event0_sel = 0;
				adv_timer->adv_timer_event_cfg_register_b.event_enable = 0x01; //(1 << 0) //For event 0
				/* */
				adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
				lCurrentCount = handler_count[aEventNum];
				vTaskDelay(2);
				if( ( handler_count[aEventNum] - lCurrentCount)  >= 2 )
				{
					dbg_str("<<PASSED>>\r\n");
				}
				else
				{
					lTestStatus |= ( 1 << aEventNum );
					dbg_str("<<FAILED>>\r\n");
				}
				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop
			}
			else if( aEventNum == 22 )
			{
				adv_timer = (AdvTimerUnit_t*) ADV_TIMER_START_ADDR;

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_0_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_0_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_RESET_COMMAND_LSB; // reset
				adv_timer->timer_0_config_register = lRegCfgVal;

				adv_timer->timer_0_threshold_register = 0x20000;
				adv_timer->timer_0_threshold_channel_0_reg = 0x30001;

				/* Somesh: Added to generate events */
				adv_timer->adv_timer_event_cfg_register_b.event1_sel = 0;
				adv_timer->adv_timer_event_cfg_register_b.event_enable = 0x02; //(1 << 1) //For event 1
				/* */
				adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
				lCurrentCount = handler_count[aEventNum];
				vTaskDelay(2);
				if( ( handler_count[aEventNum] - lCurrentCount)  >= 2 )
				{
					dbg_str("<<PASSED>>\r\n");
				}
				else
				{
					lTestStatus |= ( 1 << aEventNum );
					dbg_str("<<FAILED>>\r\n");
				}
				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop
			}
			else if( aEventNum == 23 )
			{
				adv_timer = (AdvTimerUnit_t*) ADV_TIMER_START_ADDR;
				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_0_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_0_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_RESET_COMMAND_LSB; // reset
				adv_timer->timer_0_config_register = lRegCfgVal;

				adv_timer->timer_0_threshold_register = 0x20000;
				adv_timer->timer_0_threshold_channel_0_reg = 0x30001;

				/* Somesh: Added to generate events */
				adv_timer->adv_timer_event_cfg_register_b.event2_sel = 0;
				adv_timer->adv_timer_event_cfg_register_b.event_enable = 0x04; //(1 << 2) //For event 2
				/* */
				adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
				lCurrentCount = handler_count[aEventNum];
				vTaskDelay(2);
				if( ( handler_count[aEventNum] - lCurrentCount)  >= 2 )
				{
					dbg_str("<<PASSED>>\r\n");
				}
				else
				{
					lTestStatus |= ( 1 << aEventNum );
					dbg_str("<<FAILED>>\r\n");
				}
				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop
			}
			else if( aEventNum == 24 )
			{
				adv_timer = (AdvTimerUnit_t*) ADV_TIMER_START_ADDR;

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_0_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_0_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_RESET_COMMAND_LSB; // reset
				adv_timer->timer_0_config_register = lRegCfgVal;

				adv_timer->timer_0_threshold_register = 0x20000;
				adv_timer->timer_0_threshold_channel_0_reg = 0x30001;

				/* Somesh: Added to generate events */
				adv_timer->adv_timer_event_cfg_register_b.event3_sel = 0;
				adv_timer->adv_timer_event_cfg_register_b.event_enable = 0x08; //(1 << 3) //For event 3
				/* */
				adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
				lCurrentCount = handler_count[aEventNum];
				vTaskDelay(2);
				if( ( handler_count[aEventNum] - lCurrentCount)  >= 2 )
				{
					dbg_str("<<PASSED>>\r\n");
				}
				else
				{
					lTestStatus |= ( 1 << aEventNum );
					dbg_str("<<FAILED>>\r\n");
				}
				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop
			}
		}
		else if( ( aEventNum >= 25 ) && ( aEventNum <= 30 ) )
		{
			lsoc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
			if( lsoc_ctrl->ena_efpga == 0 ) //efpga not initialized
			{
				lsoc_ctrl->control_in = 0;
				lsoc_ctrl->rst_efpga = 0xf;
				lsoc_ctrl->ena_efpga = 0x7f;
				dbg_str("eFPGA events TURNED ON\r\n");
			}
			else
			{
				dbg_str("eFPGA events READY\r\n");
			}

			lEvent = aEventNum - 25;
			lCurrentCount = handler_count[aEventNum];
			hal_efpgaio_event(lEvent); //Trigger the event

			vTaskDelay(1);
			if( handler_count[aEventNum] == ( lCurrentCount + 1) )
			{
				dbg_str("<<PASSED>>\r\n");
			}
			else
			{
				lTestStatus |= ( 1 << aEventNum );
				dbg_str("<<FAILED>>\r\n");
			}

		}
		else if( aEventNum == 31 )
		{
#if 0
			lsoc_ctrl = (apb_soc_ctrl_typedef*)APB_SOC_CTRL_BASE_ADDR;
			if( lsoc_ctrl->ena_efpga == 0 ) //efpga not initialized
			{
				lsoc_ctrl->control_in = 0;
				lsoc_ctrl->rst_efpga = 0xf;
				lsoc_ctrl->ena_efpga = 0x7f;
				dbg_str("eFPGA events TURNED ON\r\n");
				hal_soc_eu_set_fc_mask(112);
			}
			else
			{
				dbg_str("eFPGA events READY\r\n");
			}
			csr_read_clear(CSR_MIE, BIT(11));
			lCurrentCount = handler_count[aEventNum];
			for( i = 0; i< 5; i++ )
			{
				hal_efpgaio_event(0); //Trigger the event
				vTaskDelay(1);
			}
			hal_soc_eu_clear_fc_mask(112);
			csr_read_set(CSR_MIE, BIT(11));
			vTaskDelay(2);
			if( handler_count[aEventNum] == ( lCurrentCount + 1) )
			{
				dbg_str("<<PASSED>>\r\n");
			}
			else
			{
				lTestStatus |= ( 1 << aEventNum );
				dbg_str("<<FAILED>>\r\n");
			}
#endif
			//Turn off interrupt 11.
			csr_read_clear(CSR_MIE, BIT(11));

			//Save existing handler_count.
			//lCurrentCount = handler_count[aEventNum];
			gSpecialHandlingIRQCnt = 0;
			//Trigger the 31 error event, by running a gpio event test without enabling interrupt 11.
			lErrors = gpio_event_test_forevent31();

			vTaskDelay(1);
			levent_err0 = ApbEventCntrl->event_err0;
			//if( handler_count[aEventNum] == ( lCurrentCount + 1) )
			if( gSpecialHandlingIRQCnt >= 1 )
			{
				csr_read_set(CSR_MIE, BIT(11));
				vTaskDelay(2);
				dbg_str("<<PASSED>>\r\n");
			}
			else
			{
				lTestStatus |= ( 1 << aEventNum );
				csr_read_set(CSR_MIE, BIT(11));
				vTaskDelay(2);
				dbg_str("<<FAILED>>\r\n");
			}
		}
		else
		{
			lTestStatus = 0xDEADCAFE;
			dbg_str("<<UNKNOWN3>>\r\n");
		}

		RegReadVal = csr_read(CSR_MIE);
		if( ( RegReadVal & BIT(aEventNum) ) != 0 )	//Check if the event interrupt mask is open.
		{
			//close the event interrupt mask.
			csr_read_clear(CSR_MIE, BIT(aEventNum));
			RegReadVal = csr_read(CSR_MIE);
			CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
			dbg_str("<<DONE>>\r\n");
		}
	}
	else
	{
		dbg_str("<<INVALID EVENT NUM>>\r\n");
	}
	return lTestStatus;
}


