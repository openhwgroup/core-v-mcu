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
#include "hal/include/hal_pinmux.h"
#include "hal/include/hal_gpio.h"
#include "hal/include/hal_fc_event.h"
#include "include/gpio_tests.h"
#include "include/efpga_tests.h"

extern uint8_t gDebugEnabledFlg;

// EFPGAIO functions
static void efpgaio_set(const struct cli_cmd_entry *pEntry);
static void efpgaio_clr(const struct cli_cmd_entry *pEntry);
static void efpgaio_mode(const struct cli_cmd_entry *pEntry);
static void efpgaio_get_status(const struct cli_cmd_entry *pEntry);
static void efpgaio_sct_test(const struct cli_cmd_entry *pEntry);
static void efpgaio_sct_test_all(const struct cli_cmd_entry *pEntry);
//static void gpio_event_test(const struct cli_cmd_entry *pEntry);
//static void apb_gpio_tests(const struct cli_cmd_entry *pEntry);
//static void apb_gpio_event_tests(const struct cli_cmd_entry *pEntry);

static uint32_t efpgaio_set_clr_toggle_mode_test(uint32_t aEfpgaio_num);

// EPGPAIO menu
const struct cli_cmd_entry efpgaio_functions[] =
{
		CLI_CMD_SIMPLE( "set", 	efpgaio_set,         		"fpgaio_num	-- set to one" ),
		CLI_CMD_SIMPLE( "clr", 	efpgaio_clr,         		"fpgaio_num	-- clear to zero" ),
		CLI_CMD_SIMPLE( "mode",	efpgaio_mode,        "gpio_num	-- toggle state of gpio" ),
		CLI_CMD_SIMPLE( "status",	efpgaio_get_status,   "gpio_num	-- read status of gpio: in, out, interrupt type and mode" ),
		CLI_CMD_SIMPLE( "sct",	efpgaio_sct_test,   "run the set clear toggle test on mentioned efpgaio number" ),
		CLI_CMD_SIMPLE( "all",	efpgaio_sct_test_all,   "run the set clear toggle test on mentioned efpgaio number" ),
		//CLI_CMD_SIMPLE( "event",	gpio_event_test,       "io_num, mux_sel, gpio_num, gpio_int_type	-- set interrupt of gpio" ),
		//CLI_CMD_SIMPLE( "evnt",	efpga_io_events,        "None	-- All events of gpio" ),
		//CLI_CMD_SIMPLE( "all",	efpga_io_tests,         "None	-- All gpio tests " ),
		CLI_CMD_TERMINATE()
};


// GPIO functions
static void efpgaio_set(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	efpgaio_num;

	CLI_uint32_required( "efgpaio_num", &efpgaio_num );
	hal_efpgaio_outen((uint8_t)efpgaio_num,SET);
	hal_efpgaio_output((uint8_t)efpgaio_num,SET);
	dbg_str("<<DONE>>");
}

static void efpgaio_clr(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	efpgaio_num;

	CLI_uint32_required( "efgpaio_num", &efpgaio_num );
	hal_efpgaio_output((uint8_t)efpgaio_num, CLEAR);
	dbg_str("<<DONE>>");
}

static void efpgaio_mode(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	efpgaio_num, efpgaio_mode;

	CLI_uint32_required( "efgpaio_num", &efpgaio_num );
	CLI_uint32_required( "mode", &efpgaio_mode );
	hal_efpgaio_outen((uint8_t)efpgaio_num,efpgaio_mode ? SET : CLEAR);
	dbg_str("<<DONE>>");
}

static void efpgaio_get_status(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	gpio_hal_typedef efpgaio;
	// Add functionality here
	uint32_t efpgaio_num;
	uint8_t	input_value;
	uint8_t	output_value;
	uint8_t	interrupt_type;
	uint8_t	gpio_mode;

	CLI_uint32_required( "gpio_num", &efpgaio_num );
	efpgaio.number = efpgaio_num;
	hal_efpgaio_status(&efpgaio);
	CLI_printf("input 0x%02x\n", (uint32_t)efpgaio.in_val);
	CLI_printf("output 0x%02x\n", (uint32_t)efpgaio.out_val);
	CLI_printf("output_en 0x%02x\n", (uint32_t)efpgaio.mode);
	dbg_str("<<DONE>>");
}

static void efpgaio_sct_test_all(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	uint32_t lTestResult = 0;
	uint32_t efpgaio_num = 0;

	gDebugEnabledFlg = 0;
	for( efpgaio_num = 0; efpgaio_num < 40; efpgaio_num++ )
	{
		lTestResult = efpgaio_set_clr_toggle_mode_test(efpgaio_num);
		if( lTestResult == 0 )
		{
			CLI_printf("EFPGAIO %02d SCT <<PASSED>>\r\n",efpgaio_num);
		}
		else if( lTestResult == 0xDEADCAFE )
		{
			CLI_printf("EFPGAIO %02d SCT <<ABSENT>>\r\n",efpgaio_num);
		}
		else
		{
			CLI_printf("EFPGAIO %02d / 0x%08x SCT <<FAILED>>\r\n",efpgaio_num, lTestResult);
		}
	}
	gDebugEnabledFlg = 1;
}

static void efpgaio_sct_test(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	uint32_t lTestResult = 0;
	uint32_t efpgaio_num = 0;

	CLI_uint32_required( "efpgaio_num", &efpgaio_num );
	lTestResult = efpgaio_set_clr_toggle_mode_test(efpgaio_num);
	if( lTestResult == 0 )
	{
		CLI_printf("EFPGAIO %d SCT <<PASSED>>\r\n",efpgaio_num);
	}
	else if( lTestResult == 0xDEADCAFE )
	{
		CLI_printf("EFPGAIO %d SCT <<ABSENT>>\r\n",efpgaio_num);
	}
	else
	{
		CLI_printf("EFPGAIO %d / 0x%08x SCT <<FAILED>>\r\n",efpgaio_num, lTestResult);
	}

}

static uint32_t efpgaio_set_clr_toggle_mode_test(uint32_t aEfpgaio_num)
{
	gpio_hal_typedef efpgaio;
	uint32_t lTestStatus = 0;
	uint32_t lIONumber = 0;
	uint32_t lExpectedResult = 0;
	uint8_t	save_mux = 0;
	apb_soc_ctrl_typedef *lsoc_ctrl;  //Somesh: We need to use SocCtrl_t present in hal_apb_soc_ctrl_regs.h
	int i = 0;

	if( ( aEfpgaio_num >= 4 ) && ( aEfpgaio_num < 40 ) )
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

		if( aEfpgaio_num <= 36 )
			lIONumber = aEfpgaio_num + 7;
		else
			lIONumber = aEfpgaio_num + 8;

		//TODO: Save pin mux value and restore
		save_mux = hal_getpinmux((uint8_t)lIONumber);
		hal_setpinmux(lIONumber, 3);

		hal_efpgaio_outen((uint8_t)aEfpgaio_num,SET);

		for( i=0; i<4; i++ )
		{
			if( i == GPIO_SET)
			{
				hal_efpgaio_output((uint8_t)aEfpgaio_num,SET);
				lExpectedResult = 1;
			}
			else if( i == GPIO_CLR )
			{
				hal_efpgaio_output((uint8_t)aEfpgaio_num, CLEAR);
				lExpectedResult = 0;
			}
			else if ( i== GPIO_TOGGLE_H )
			{
				hal_efpgaio_output((uint8_t)aEfpgaio_num,SET);
				hal_efpgaio_output((uint8_t)aEfpgaio_num,TOGGLE);
				lExpectedResult = 0;
			}
			else if ( i == GPIO_TOGGLE_L )
			{
				hal_efpgaio_output((uint8_t)aEfpgaio_num,CLEAR);
				hal_efpgaio_output((uint8_t)aEfpgaio_num,TOGGLE);
				lExpectedResult = 1;
			}
			efpgaio.number = aEfpgaio_num;
			hal_efpgaio_status(&efpgaio);
			if( ( efpgaio.in_val == lExpectedResult ) && ( efpgaio.out_val == lExpectedResult ) )
			{
				//Do nothing;
			}
			else
			{
				if( i == GPIO_SET )
					lTestStatus |= (1 << 0 );
				else if ( i == GPIO_CLR )
					lTestStatus |= (1 << 1 );
				else if( i == GPIO_TOGGLE_H )
					lTestStatus |= ( 1<< 2 );
				else if ( i == GPIO_TOGGLE_L )
					lTestStatus |= ( 1 << 3 );
			}
		}
		//TODO: restore pinmux
		hal_setpinmux(lIONumber,save_mux);
	}
	else
	{
		lTestStatus = 0xDEADCAFE;
	}
	return lTestStatus;
}
