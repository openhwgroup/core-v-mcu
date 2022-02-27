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

//#include "drivers/include/udma_i2cm_driver.h"
#include "drivers/include/udma_uart_driver.h"
#include "hal/include/hal_fc_event.h"
#include "barrMemTest.h"

extern uint8_t gDebugEnabledFlg;
extern uint8_t gSimulatorEnabledFlg;
extern uint8_t gFilterPrintMsgFlg;
extern uint8_t gSimulatorCmdTableIndex;

extern const struct cli_cmd_entry io_functions[];
extern const struct cli_cmd_entry intr_functions[];
extern const struct cli_cmd_entry adv_timer_unit_test_functions[];
extern const struct cli_cmd_entry gpio_functions[];
extern const struct cli_cmd_entry efpgaio_functions[];
extern const struct cli_cmd_entry i2cm0_functions[];
extern const struct cli_cmd_entry i2cm1_functions[];
extern const struct cli_cmd_entry i2cs_functions[];
extern const struct cli_cmd_entry efpga_cli_tests[];
extern const struct cli_cmd_entry fcb_cli_tests[];
extern const struct cli_cmd_entry qspi_cli_tests[];
extern const struct cli_cmd_entry sdio_cli_tests[];
extern const struct cli_cmd_entry cam_tests[];


// MISC functions
static void misc_info(const struct cli_cmd_entry *pEntry);
static void debug_on_off(const struct cli_cmd_entry *pEntry);
static void simulator_on_off(const struct cli_cmd_entry *pEntry);
static void FLLTest(const struct cli_cmd_entry *pEntry);

// UART functions
static void uart1_tx(const struct cli_cmd_entry *pEntry);

// MEM functions
static void mem_print_start(const struct cli_cmd_entry *pEntry);
static void mem_peek(const struct cli_cmd_entry *pEntry);
static void mem_poke(const struct cli_cmd_entry *pEntry);
static void mem_peek_16(const struct cli_cmd_entry *pEntry);
static void mem_poke_16(const struct cli_cmd_entry *pEntry);
static void mem_peek_8(const struct cli_cmd_entry *pEntry);
static void mem_poke_8(const struct cli_cmd_entry *pEntry);

// MEM tests
static void mem_check(const struct cli_cmd_entry *pEntry);
static void barr_mem_check(const struct cli_cmd_entry *pEntry);

const struct cli_cmd_entry misc_functions[] =
{
		CLI_CMD_SIMPLE( "info", misc_info, "print build info" ),
		CLI_CMD_SIMPLE( "dbg", debug_on_off, "debug prints on / off" ),
		CLI_CMD_SIMPLE( "simul", simulator_on_off, "debug prints on / off" ),
		CLI_CMD_SIMPLE( "flltest", FLLTest, "debug prints on / off" ),
		CLI_CMD_TERMINATE()
};

// MISC menu

// UART1 menu
const struct cli_cmd_entry uart1_functions[] =
{
		CLI_CMD_SIMPLE( "tx", uart1_tx, "<string>: write <string> to uart1" ),
		CLI_CMD_TERMINATE()
};

// mem menu
const struct cli_cmd_entry mem_tests[] =
{
		CLI_CMD_SIMPLE( "check", 	mem_check,         	"print start of unused memory" ),
		CLI_CMD_SIMPLE( "barr", 	barr_mem_check,         	"print start of unused memory" ),
		CLI_CMD_TERMINATE()
};

// mem menu
const struct cli_cmd_entry mem_functions[] =
{
		CLI_CMD_SIMPLE( "start", 	mem_print_start,   	"print start of unused memory" ),
		CLI_CMD_SIMPLE( "peek", 	mem_peek,         	"0xaddr -- print memory location " ),
		CLI_CMD_SIMPLE( "poke",   mem_poke,         	"0xaddr 0xvalue -- write value to addr" ),
		CLI_CMD_SIMPLE( "md.b", 	mem_peek_8,         	"0xaddr -- print 8-bit memory location " ),
		CLI_CMD_SIMPLE( "mw.b",   mem_poke_8,         	"0xaddr 0xvalue -- write 8-bit alue to addr" ),
		CLI_CMD_SIMPLE( "md.w", 	mem_peek_16,         	"0xaddr -- print 16-bit memory location " ),
		CLI_CMD_SIMPLE( "mw.w",   mem_poke_16,         	"0xaddr 0xvalue -- write 16-bit value to addr" ),
		CLI_CMD_SIMPLE( "md.l", 	mem_peek,         	"0xaddr -- print 32-bit memory location " ),
		CLI_CMD_SIMPLE( "mw.l",   	mem_poke,         	"0xaddr 0xvalue -- write value to addr" ),
		CLI_CMD_SUBMENU( "test", 	mem_tests, 			"tests" ),
		CLI_CMD_TERMINATE()
};



// Main menu
const struct cli_cmd_entry my_main_menu[] = {

		CLI_CMD_SUBMENU( "misc", 	misc_functions, 	"miscellaneous functions" ),
		CLI_CMD_SUBMENU( "uart1", 	uart1_functions, 	"commands for uart1" ),
		CLI_CMD_SUBMENU( "mem", 	mem_functions, 		"commands for memory" ),
		CLI_CMD_SUBMENU( "io", 		io_functions, 		"commands for io" ),
		CLI_CMD_SUBMENU( "intr", 	intr_functions, 		"commands for interrupt" ),
		CLI_CMD_SUBMENU( "advtmr", 	adv_timer_unit_test_functions, 		"commands for testing advance timers" ),
		CLI_CMD_SUBMENU( "gpio", 	gpio_functions, 	"commands for gpio" ),
		CLI_CMD_SUBMENU( "efpgaio", efpgaio_functions,   "commands for efpgaio"),
		CLI_CMD_SUBMENU( "i2cm0", 	i2cm0_functions, 	"commands for i2cm0" ),
		CLI_CMD_SUBMENU( "i2cm1", 	i2cm1_functions, 	"commands for i2cm1" ),
		CLI_CMD_SUBMENU( "i2cs", 	i2cs_functions, 	"commands for i2cSlave" ),
		CLI_CMD_SUBMENU( "efpga", 	efpga_cli_tests,    "commands for efpga connectivity"),
		CLI_CMD_SUBMENU( "fcb", 	fcb_cli_tests,    "commands for fabric control block tests"),
		CLI_CMD_SUBMENU( "qspi", qspi_cli_tests, "commands for efpga tests"),
		CLI_CMD_SUBMENU( "sdio", sdio_cli_tests, "commands for sdio tests"),
		CLI_CMD_SUBMENU( "cam", cam_tests, "commands for Himax camera tests"),
		CLI_CMD_TERMINATE()

};




// MISC functions
static void misc_info(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	char pzTemp[] = "0000-00-00 00:00";
	SocCtrl_t* 	psocctrl = SOC_CTRL_START_ADDR;
	uint32_t 	xval;

	xval = psocctrl->build_date;
	pzTemp[0] += (char)((xval >> 28) & 0xFU);
	pzTemp[1] += (char)((xval >> 24) & 0xFU);
	pzTemp[2] += (char)((xval >> 20) & 0xFU);
	pzTemp[3] += (char)((xval >> 16) & 0xFU);

	pzTemp[5] += (char)((xval >> 12) & 0xFU);
	pzTemp[6] += (char)((xval >>  8) & 0xFU);

	pzTemp[8] += (char)((xval >>  4) & 0xFU);
	pzTemp[9] += (char)((xval >>  0) & 0xFU);

	xval = psocctrl->build_time;
	pzTemp[11] += (char)((xval >> 20) & 0xFU);
	pzTemp[12] += (char)((xval >> 16) & 0xFU);

	pzTemp[14] += (char)((xval >> 12) & 0xFU);
	pzTemp[15] += (char)((xval >>  8) & 0xFU);

	CLI_printf("HW build_info %s\n", pzTemp);
	CLI_printf("SW build_info %s %s\n", __DATE__, __TIME__ );

	dbg_str("<<DONE>>\r\n");
}

static void debug_on_off(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	lDbgStatus = 0;

	CLI_uint8_required( "debug flag", &lDbgStatus );
	gDebugEnabledFlg = lDbgStatus;
	dbg_str("<<DONE>>\r\n");
}

static void simulator_on_off(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint8_t	lSimulatorFlg = 0;
	uint8_t	lFilterPrintMsgFlg = 0;

	CLI_uint8_required("Simul flag", &lSimulatorFlg );
	CLI_uint8_required("Msg filter flag", &lFilterPrintMsgFlg );
	gSimulatorEnabledFlg = lSimulatorFlg;
	gFilterPrintMsgFlg = lFilterPrintMsgFlg;

	if( lSimulatorFlg == 1 )
		gSimulatorCmdTableIndex = 0;
	CLI_cmd_stack_clear();
	memset( (void *)(&(CLI_common.cmdline[0])), 0, sizeof(CLI_common.cmdline) );
	dbg_str("<<DONE>>\r\n");
}

static void FLLTest(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t *lFFL1StartAddress = (uint32_t *)FLL1_START_ADDR;
	uint32_t *lFFL2StartAddress = (uint32_t *)FLL2_START_ADDR;
	uint32_t *lFFL3StartAddress = (uint32_t *)FLL3_START_ADDR;

	CLI_printf("FLL1 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL1StartAddress, *(lFFL1StartAddress + 1), *(lFFL1StartAddress + 2), *(lFFL1StartAddress + 3) );
	CLI_printf("FLL2 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL2StartAddress, *(lFFL2StartAddress + 1), *(lFFL2StartAddress + 2), *(lFFL2StartAddress + 3) );
	CLI_printf("FLL3 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL3StartAddress, *(lFFL3StartAddress + 1), *(lFFL3StartAddress + 2), *(lFFL3StartAddress + 3) );


	*lFFL1StartAddress = 0x00000000;
	*(lFFL1StartAddress + 1) = 0x00000000;
	*(lFFL1StartAddress + 2) = 0x00000000;
	*(lFFL1StartAddress + 3) = 0x00000000;

	CLI_printf("FLL1 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL1StartAddress, *(lFFL1StartAddress + 1), *(lFFL1StartAddress + 2), *(lFFL1StartAddress + 3) );

	*lFFL1StartAddress = 0x05050505;
	*(lFFL1StartAddress + 1) = 0x05050505;
	*(lFFL1StartAddress + 2) = 0x05050505;
	*(lFFL1StartAddress + 3) = 0x05050505;

	CLI_printf("FLL1 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL1StartAddress, *(lFFL1StartAddress + 1), *(lFFL1StartAddress + 2), *(lFFL1StartAddress + 3) );

	*lFFL1StartAddress = 0x0A0A0A0A;
	*(lFFL1StartAddress + 1) = 0x0A0A0A0A;
	*(lFFL1StartAddress + 2) = 0x0A0A0A0A;
	*(lFFL1StartAddress + 3) = 0x0A0A0A0A;

	CLI_printf("FLL1 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL1StartAddress, *(lFFL1StartAddress + 1), *(lFFL1StartAddress + 2), *(lFFL1StartAddress + 3) );

	*lFFL2StartAddress = 0x00000000;
	*(lFFL2StartAddress + 1) = 0x00000000;
	*(lFFL2StartAddress + 2) = 0x00000000;
	*(lFFL2StartAddress + 3) = 0x00000000;

	CLI_printf("FLL2 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL2StartAddress, *(lFFL2StartAddress + 1), *(lFFL2StartAddress + 2), *(lFFL2StartAddress + 3) );

	*lFFL2StartAddress = 0x05050505;
	*(lFFL2StartAddress + 1) = 0x05050505;
	*(lFFL2StartAddress + 2) = 0x05050505;
	*(lFFL2StartAddress + 3) = 0x05050505;

	CLI_printf("FLL2 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL2StartAddress, *(lFFL2StartAddress + 1), *(lFFL2StartAddress + 2), *(lFFL2StartAddress + 3) );

	*lFFL2StartAddress = 0x0A0A0A0A;
	*(lFFL2StartAddress + 1) = 0x0A0A0A0A;
	*(lFFL2StartAddress + 2) = 0x0A0A0A0A;
	*(lFFL2StartAddress + 3) = 0x0A0A0A0A;

	CLI_printf("FLL2 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL2StartAddress, *(lFFL2StartAddress + 1), *(lFFL2StartAddress + 2), *(lFFL2StartAddress + 3) );

	*lFFL3StartAddress = 0x00000000;
	*(lFFL3StartAddress + 1) = 0x00000000;
	*(lFFL3StartAddress + 2) = 0x00000000;
	*(lFFL3StartAddress + 3) = 0x00000000;

	CLI_printf("FLL3 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL3StartAddress, *(lFFL3StartAddress + 1), *(lFFL3StartAddress + 2), *(lFFL3StartAddress + 3) );

	*lFFL3StartAddress = 0x05050505;
	*(lFFL3StartAddress + 1) = 0x05050505;
	*(lFFL3StartAddress + 2) = 0x05050505;
	*(lFFL3StartAddress + 3) = 0x05050505;

	CLI_printf("FLL3 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL3StartAddress, *(lFFL3StartAddress + 1), *(lFFL3StartAddress + 2), *(lFFL3StartAddress + 3) );

	*lFFL3StartAddress = 0x0A0A0A0A;
	*(lFFL3StartAddress + 1) = 0x0A0A0A0A;
	*(lFFL3StartAddress + 2) = 0x0A0A0A0A;
	*(lFFL3StartAddress + 3) = 0x0A0A0A0A;

	CLI_printf("FLL3 0x%08x 0x%08x 0x%08x 0x%08x\n",*lFFL3StartAddress, *(lFFL3StartAddress + 1), *(lFFL3StartAddress + 2), *(lFFL3StartAddress + 3) );
}

// UART functions
static void uart1_tx(const struct cli_cmd_entry *pEntry)
{
	char*  pzArg = NULL;
	(void)pEntry;
	// Add functionality here
	while (CLI_peek_next_arg() != NULL) {
		if (pzArg != NULL) {
			udma_uart_writeraw(1, 2, " ");
		}
		CLI_string_ptr_required("string", &pzArg);
		udma_uart_writeraw(1, strlen(pzArg), pzArg);
	}
	udma_uart_writeraw(1, 2, "\r\n");
	dbg_str("<<DONE>>\r\n");
	return;
}

// MEM functions
static void mem_print_start(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	extern char __l2_shared_end;
	CLI_printf("l2_shared_end 0x%08x\n", (uint32_t)(&__l2_shared_end));
	dbg_str("<<DONE>>\r\n");
}

static void mem_check(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	bool  fPassed = true;
	extern char __l2_shared_end;
	uint32_t*  pl;
	for (pl = (uint32_t*)(&__l2_shared_end); (uint32_t)pl < 0x1c080000; pl++) {
		*pl = (uint32_t)pl;
	}

	// pl=0x1c070000; *pl = 76;  // Enable to force an error

	for (pl = (uint32_t*)(&__l2_shared_end); (uint32_t)pl < 0x1c080000; pl++) {
		if (*pl != (uint32_t)pl) {
			CLI_printf("mem check fail at 0x%08x\n", (uint32_t)pl);
			CLI_printf("read back        0x%08x\n", *pl);
			fPassed = false;
			break;
		}
	}
	if (fPassed) {
		dbg_str("mem check <<PASSED>>\r\n");
	} else {
		dbg_str("mem check <<FAILED>>\r\n");
	}
}

static void barr_mem_check(const struct cli_cmd_entry *pEntry)
{
	uint32_t lNumOfKBs = 0;
	(void)pEntry;
	CLI_uint32_required( "num of KBs to test", &lNumOfKBs );
	if( memTest(lNumOfKBs) == 0 )
	{
		dbg_str("BARR <<PASSED>>\r\n");
	}
	else
	{
		dbg_str("BARR <<FAILED>>\r\n");
	}
}
static void mem_peek(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	xValue = 0;
	uint32_t    lExpVal = 0;
	uint8_t 	lExpValTrueOrFalse = 0;
	uint32_t	lAddress = 0;
	uint32_t*	pAddr = 0;

	CLI_uint32_required( "addr", &lAddress );

	if( CLI_is_more_args() ){
		lExpValTrueOrFalse = 1;
		CLI_uint32_required("exp", &lExpVal);
	}

	pAddr = (uint32_t*)lAddress;
	xValue = *pAddr;
	CLI_printf("value 0x%08x\n", xValue);


	if( lExpValTrueOrFalse )
	{
		if( xValue == lExpVal )
		{
			CLI_printf("mem peek 0x%08x <<PASSED>>\n",lAddress);
		}
		else
		{
			CLI_printf("mem peek 0x%08x <<FAILED>>\n",lAddress);
		}
	}
	else
	{
		dbg_str("<<mem peek DONE>>\r\n");
	}

}

static void mem_poke(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	xValue = 0;
	uint32_t	lAddress = 0;
	uint32_t*	pAddr = 0;

	CLI_uint32_required( "addr", &lAddress );
	CLI_uint32_required( "value", &xValue);
	pAddr = (uint32_t*)lAddress;

	*pAddr = xValue;
	dbg_str("mem poke <<DONE>>\r\n");

}

static void mem_peek_16(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint16_t	xValue, lExpVal;
	uint16_t*	pAddr;
	uint8_t lExpValTrueOrFalse = 0;

	CLI_uint32_required( "addr", &pAddr );
	if( CLI_is_more_args() ){
		lExpValTrueOrFalse = 1;
		CLI_uint16_required("exp", &lExpVal);
	}
	xValue = *pAddr;
	CLI_printf("value 0x%04x\n", xValue);

	if( lExpValTrueOrFalse )
	{
		if( xValue == lExpVal )
		{
			CLI_printf("mem peek 16 0x%08x <<PASSED>>\n",pAddr);
		}
		else
		{
			CLI_printf("mem peek 16 0x%08x <<FAILED>>\n",pAddr);
		}
	}
	else
	{
		dbg_str("mem peek 16 <<DONE>>\r\n");
	}
}

static void mem_poke_16(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint16_t	xValue;
	uint16_t*	pAddr;

	CLI_uint32_required( "addr", &pAddr );
	CLI_uint16_required( "value", &xValue);
	*pAddr = xValue;
	dbg_str("mem poke 16 <<DONE>>\r\n");
}

static void mem_peek_8(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint8_t	xValue, lExpVal;
	uint8_t*	pAddr;
	uint8_t lExpValTrueOrFalse = 0;

	CLI_uint32_required( "addr", &pAddr );
	if( CLI_is_more_args() ){
		lExpValTrueOrFalse = 1;
		CLI_uint8_required("exp", &lExpVal);
	}

	xValue = *pAddr;
	CLI_printf("value 0x%02x\n", xValue);
	if( lExpValTrueOrFalse )
	{
		if( xValue == lExpVal )
		{
			CLI_printf("mem peek 8 0x%08x <<PASSED>>\n",pAddr);
		}
		else
		{
			CLI_printf("mem peek 8 0x%08x <<FAILED>>\n",pAddr);
		}
	}
	else
	{
		dbg_str("mem peek 8 <<DONE>>\r\n");
	}
}

static void mem_poke_8(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint8_t	xValue;
	uint8_t*	pAddr;

	CLI_uint32_required( "addr", &pAddr );
	CLI_uint32_required( "value", &xValue);
	*pAddr = xValue;
	dbg_str("mem peek 8 <<DONE>>\r\n");
}
