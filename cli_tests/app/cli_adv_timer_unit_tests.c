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
#include "hal/include/hal_apb_soc_ctrl_regs.h"
#include "hal/include/hal_gpio.h"
#include "hal/include/hal_fc_event.h"
#include "hal/include/adv_timer_unit_reg_defs.h"

extern uint8_t gDebugEnabledFlg;

static void test_adv_timer_unit(const struct cli_cmd_entry *pEntry);
static void test_all_adv_timer_units(const struct cli_cmd_entry *pEntry);
static uint32_t testAdvTimerForFourEvents(uint32_t aAdvTimerNum, uint32_t aAdvTimerChannelNum);

extern int handler_count[];

// IO menu
const struct cli_cmd_entry adv_timer_unit_test_functions[] =
{
		CLI_CMD_SIMPLE( "tsttmr", test_adv_timer_unit,         "test the 4 events for a particular timer and its channel number" ),
		CLI_CMD_SIMPLE( "all", test_all_adv_timer_units,         "test the 4 events for a particular timer and its channel number" ),
		CLI_CMD_TERMINATE()
};

static void test_adv_timer_unit(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t lAdvTimerNum = 0;
	uint32_t lAdvTimerChannelNum = 0;

	CLI_uint32_required( "timer number", &lAdvTimerNum);
	CLI_uint32_required( "channel number", &lAdvTimerChannelNum);

	testAdvTimerForFourEvents(lAdvTimerNum, lAdvTimerChannelNum);

}

static void test_all_adv_timer_units(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	//
	uint32_t lAdvTimerNum = 0;
	uint32_t lAdvTimerChannelNum = 0;
	uint32_t lTestResult = 0;

	gDebugEnabledFlg = 0;
	for( lAdvTimerNum=0; lAdvTimerNum<4 ; lAdvTimerNum++ )
	{
		for( lAdvTimerChannelNum=0; lAdvTimerChannelNum<4; lAdvTimerChannelNum++ )
		{
			lTestResult = testAdvTimerForFourEvents(lAdvTimerNum, lAdvTimerChannelNum);
			if( ( lTestResult & 0x0F ) == 0 )
			{
				CLI_printf("TIMER %d CHN %d EVENTS(0-3) <<PASSED>>\n",lAdvTimerNum,lAdvTimerChannelNum);
			}
			else if( lTestResult == 0xDEADCAFE )
			{
				CLI_printf("TIMER %d CHN %d <<INVALID>>\n",lAdvTimerNum,lAdvTimerChannelNum);
			}
			else
			{
				CLI_printf("TIMER %d CHN %d <<FAILED>> (0x%08x)\n",lAdvTimerNum,lAdvTimerChannelNum, lTestResult);
			}
		}
	}
	gDebugEnabledFlg = 1;


}

static uint32_t testAdvTimerForFourEvents(uint32_t aAdvTimerNum, uint32_t aAdvTimerChannelNum)
{
	int lCurrentCount = 0;
	AdvTimerUnit_t *adv_timer;
	uint32_t lTestStatus = 0;
	uint32_t lEventNum = 0;
	uint32_t RegReadVal = 0;
	uint32_t lRegCfgVal = 0;
	if( ( aAdvTimerNum >= 4 ) && ( aAdvTimerChannelNum >= 4 ) )
	{
		lTestStatus = 0xDEADCAFE;	//Invalid timer or channel number
	}
	else	//Valid channel number
	{
		adv_timer = (AdvTimerUnit_t*) ADV_TIMER_START_ADDR;
		switch( aAdvTimerNum )
		{
			case 0:		//Timer number
			{
				adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_RESET_COMMAND_LSB; // reset

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_0_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_0_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_0_config_register = lRegCfgVal;

				adv_timer->timer_0_threshold_register = 0x20000;
				if( aAdvTimerChannelNum == 0 )  //Channel number
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_0_threshold_channel_0_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 0;  //Timer 0 channel 0
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 0; //Timer 0 channel 0
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 0; //Timer 0 channel 0
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 0; //Timer 0 channel 0
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 1 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_0_threshold_channel_1_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 1;  //Timer 0 channel 1
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 1; //Timer 0 channel 1
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 1; //Timer 0 channel 1
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 1; //Timer 0 channel 1
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 2 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_0_threshold_channel_2_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 2;  //Timer 0 channel 2
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 2; //Timer 0 channel 2
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 2; //Timer 0 channel 2
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 2; //Timer 0 channel 2
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 3 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_0_threshold_channel_3_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 3;  //Timer 0 channel 3
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 3; //Timer 0 channel 3
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 3; //Timer 0 channel 3
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 3; //Timer 0 channel 3
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0

						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
			}
			break;
			case 1:			//Timer number
			{
				adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_RESET_COMMAND_LSB; // reset

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_1_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_1_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_1_config_register = lRegCfgVal;

				adv_timer->timer_1_threshold_register = 0x20000;
				if( aAdvTimerChannelNum == 0 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_1_threshold_channel_0_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 4;  //Timer 1 channel 0
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 4; //Timer 1 channel 0
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 4; //Timer 1 channel 0
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 4; //Timer 1 channel 0
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x2; // enable clock for timer1

						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 1 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_1_threshold_channel_1_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 5;  //Timer 1 channel 1
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 5; //Timer 1 channel 1
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 5; //Timer 1 channel 1
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 5; //Timer 1 channel 1
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x2; // enable clock for timer1

						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 2 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_1_threshold_channel_2_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 6;  //Timer 1 channel 2
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 6; //Timer 1 channel 2
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 6; //Timer 1 channel 2
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 6; //Timer 1 channel 2
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x2; // enable clock for timer1

						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num", aAdvTimerNum);
						CLI_printf("Chn num", aAdvTimerChannelNum);
						CLI_printf("Event num", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 3 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_1_threshold_channel_3_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 7;  //Timer 1 channel 3
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 7; //Timer 1 channel 3
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 7; //Timer 1 channel 3
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 7; //Timer 1 channel 3
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x2; // enable clock for timer1

						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_1_cmd_register = 1 << REG_TIMER_1_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
			}
			break;
			case 2:			//Timer number
			{
				adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_RESET_COMMAND_LSB; // reset

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_2_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_2_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_2_config_register = lRegCfgVal; //

				adv_timer->timer_2_threshold_register = 0x20000;
				if( aAdvTimerChannelNum == 0 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_2_threshold_channel_0_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 8;  //Timer 2 channel 0
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 8; //Timer 2 channel 0
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 8; //Timer 2 channel 0
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 8; //Timer 2 channel 0
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x4; // enable clock for timer2

						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num", aAdvTimerNum);
						CLI_printf("Chn num", aAdvTimerChannelNum);
						CLI_printf("Event num", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 1 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_2_threshold_channel_1_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 9;  //Timer 2 channel 1
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 9; //Timer 2 channel 1
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 9; //Timer 2 channel 1
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 9; //Timer 2 channel 1
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x4; // enable clock for timer2

						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 2 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_2_threshold_channel_2_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 10;  //Timer 2 channel 2
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 10; //Timer 2 channel 2
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 10; //Timer 2 channel 2
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 10; //Timer 2 channel 2
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x4; // enable clock for timer2

						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num", aAdvTimerNum);
						CLI_printf("Chn num", aAdvTimerChannelNum);
						CLI_printf("Event num", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 3 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_2_threshold_channel_3_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 11;  //Timer 2 channel 3
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 11; //Timer 2 channel 3
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 11; //Timer 2 channel 3
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 11; //Timer 2 channel 3
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x4; // enable clock for timer2

						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_2_cmd_register = 1 << REG_TIMER_2_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
			}
			break;
			case 3:			//Timer number
			{
				adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_RESET_COMMAND_LSB; // reset

				lRegCfgVal = 0;
				lRegCfgVal |= 8 << REG_TIMER_3_CONFIG_REGISTER_PRESCALER_VALUE_LSB;
				lRegCfgVal |= 1 << REG_TIMER_3_CONFIG_REGISTER_CLOCK_SEL_LSB;

				adv_timer->timer_3_config_register = lRegCfgVal;

				adv_timer->timer_3_threshold_register = 0x20000;
				if( aAdvTimerChannelNum == 0 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_3_threshold_channel_0_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 12;  //Timer 3 channel 0
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 12; //Timer 3 channel 0
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 12; //Timer 3 channel 0
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 12; //Timer 3 channel 0
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x8; // enable clock for timer3

						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num", aAdvTimerNum);
						CLI_printf("Chn num", aAdvTimerChannelNum);
						CLI_printf("Event num", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 1 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_3_threshold_channel_1_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 13;  //Timer 3 channel 1
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 13; //Timer 3 channel 1
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 13; //Timer 3 channel 1
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 13; //Timer 3 channel 1
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x8; // enable clock for timer3

						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 2 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_3_threshold_channel_2_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 14;  //Timer 3 channel 2
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 14; //Timer 3 channel 2
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 14; //Timer 3 channel 2
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 14; //Timer 3 channel 2
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x8; // enable clock for timer3

						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num", aAdvTimerNum);
						CLI_printf("Chn num", aAdvTimerChannelNum);
						CLI_printf("Event num", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
				else if( aAdvTimerChannelNum == 3 )
				{
					lTestStatus |= aAdvTimerNum;
					lTestStatus <<= 4;
					lTestStatus |= aAdvTimerChannelNum;
					lTestStatus <<= 4;
					for( lEventNum = 0; lEventNum < 4; lEventNum++ )  //4Events
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
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//Do nothing.
						}
						else
						{
							//open the event interrupt mask.
							csr_read_set(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");

						}

						adv_timer->timer_3_threshold_channel_3_reg = 0x30001;

						/* Somesh: Added to generate events */
						if( lEventNum == 0 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event0_sel = 15;  //Timer 3 channel 3
						}
						else if( lEventNum == 1 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event1_sel = 15; //Timer 3 channel 3
						}
						else if( lEventNum == 2 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event2_sel = 15; //Timer 3 channel 3
						}
						else if( lEventNum == 3 )
						{
							adv_timer->adv_timer_event_cfg_register_b.event3_sel = 15; //Timer 3 channel 3
						}

						adv_timer->adv_timer_event_cfg_register_b.event_enable = (1 << lEventNum); //For event 0
						/* */
						adv_timer->adv_timer_cfg_register = 0x8; // enable clock for timer3

						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_START_COMMAND_LSB; //start
						lCurrentCount = handler_count[21 + lEventNum];
						vTaskDelay(2);
						CLI_printf("Timer num 0x%02x\n", aAdvTimerNum);
						CLI_printf("Chn num 0x%02x\n", aAdvTimerChannelNum);
						CLI_printf("Event num 0x%02x\n", lEventNum);
						if( ( handler_count[21 + lEventNum] - lCurrentCount)  >= 2 )
						{
							dbg_str("<<PASSED>>\r\n");
						}
						else
						{
							lTestStatus |= (1 << lEventNum);
							dbg_str("<<FAILED>>\r\n");
						}
						adv_timer->timer_3_cmd_register = 1 << REG_TIMER_3_CMD_REGISTER_STOP_COMMAND_LSB; //stop

						RegReadVal = csr_read(CSR_MIE);
						if( ( RegReadVal & BIT(21 + lEventNum) ) != 0 )	//Check if the event interrupt mask is open.
						{
							//close the event interrupt mask.
							csr_read_clear(CSR_MIE, BIT(21 + lEventNum));
							RegReadVal = csr_read(CSR_MIE);
							CLI_printf("CSR_MIE 0x%08x\n", RegReadVal);
							dbg_str("<<DONE>>\r\n");
						}
					}
				}
			}
			break;
			default:
				break;
		}
	}
	return lTestStatus;
}

