/*==========================================================
 * Copyright 2020 QuickLogic Corporation
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

/*==========================================================
 *                                                          
 *    File   : cli_platform.c
 *    Purpose: command line interface for smart remote demo application. 
 * $Revision: 4224$
 * $Date: 2011-02-22$
 *=========================================================*/

/** @file cli_platform.c */


#include "libs/cli/include/cli.h"
#include "FreeRTOS.h"
#include "task.h"
//#include <eoss3_hal_uart.h>
#include "drivers/include/udma_uart_driver.h"
//#include "RtosTask.h"
#include "SDKConfig.h"
#include <setjmp.h>
#include "libs/utils/include/dbg_uart.h"
#include "string.h"
/* These are PLATFORM specific functions that the CLI code requires */

struct cli CLI_common;
extern const char *SOFTWARE_VERSION_STR;
void CLI_dispatch(void);
extern uint8_t gSimulatorEnabledFlg;
extern uint8_t gFilterPrintMsgFlg;
uint8_t gSimulatorCmdTableIndex = 0;

const char *gSimulatorCmdTable[] = {
		"exit",
		"misc info",
		"efpga tcdm",
		"efpga math0mult0",
		"efpga math0mult1",
		"efpga math1mult0",
		"efpga math1mult1",
		"efpga ram",
		"efpga mlt",
		"efpga rw",
		"efpga auto",
		"efpga tcdm_st",
		"efpgaio all",
		"fcb pgm",
		"i2cs on",
		"advtmr all",
		"gpio event",
		"gpio evnt",
		"gpio all",
		"i2cm0 all",
		"i2cm1 all",
		"mem test barr 32",
		"qspi flashid",
		"qspi erase 0x00100000",
		"qspi init",
		"qspi flash_qpeek 0x00100000 0xFFFFFFFF",
		"qspi flash_qpoke 0x00100000 0x01234567",
		"qspi flash_qpeek 0x00100000 0x01234567",
		"qspi flash_peek 0x00100000 0x01234567",
		"qspi reset",
		"qspi erase 0x00100000",
		"qspi flash_peek 0x00100000 0xFFFFFFFF",
		"qspi flash_poke 0x00100000 0x76543210",
		"qspi flash_peek 0x00100000 0x76543210",
		"qspi init",
		"qspi flash_qpeek 0x00100000 0x76543210",
		"intr all",
		"i2cs all",
		"uart1 tx the_quick_brown_fox_jumped_over_the_lazy_dog!",
		"efpga tcdm_status",
		"efpga tcdm_sp",
		NULL
};
#ifdef DISABLE_UART_PRINTS
#define uart_tx(x,y)		do{}while(0);
#else
//extern void uart_tx(int, int);
#endif

xTaskHandle xHandleTestCli;

uint32_t CLI_time_now(void)
{
  return xTaskGetTickCount();
}

intptr_t CLI_timeout_start(void)
{
  return (intptr_t)CLI_time_now();
}

void CLI_beep(void)
{
  /* ascii bell */
  CLI_putc( 0x07 );
}

int CLI_timeout_expired( intptr_t token, int timeout )
{
  int32_t delta;
  if( timeout == 0 ){
    return 1;
  }
  if( timeout < 0 ){
    /* forever */
    return 0;
  }
  uint32_t now;
  
  now = CLI_time_now();
  
  delta = ((int32_t)(now))- (int32_t)(token);
  if( delta > timeout ){
    return 1;
  } else {
    return 0;
  }
}

void CLI_putc_raw(int c)
{
	udma_uart_writeraw(UART_ID_CONSOLE, 1, (uint8_t*) &c);
}

int CLI_getkey_raw( int timeout )
{
  intptr_t tstart;
  uint16_t x;
  
  tstart = CLI_timeout_start();
  for(;;){
    //uart_rx_wait( UART_ID_CONSOLE, timeout );
    if( udma_uart_control( UART_ID_CONSOLE , kUartDataValid, NULL) ){
    	x = uart_getchar(UART_ID_CONSOLE);
//      x = udma_uart_getchar( UART_ID_CONSOLE );
      if (x != 0)							// FIXME: why do we get nullls?
    	  return (int)x;
    }
    /* no key */
    if( CLI_timeout_expired(tstart, timeout ) ){
      break;
    }
    vTaskDelay( 10 );
  }
  return EOF;
}

void CLI_task( void *pParameter )
{
    (void)(pParameter);
    int k;

    //wait_ffe_fpga_load();
    /* set to 1 to have a timestamp on the side */
    vTaskDelay(100);
    
    CLI_common.timestamps = 0;

    CLI_printf("#*******************\n");
    CLI_printf("Command Line Interface\n");
    CLI_printf("%s %s\n", __DATE__, __TIME__ );
    CLI_printf("App SW Version: %s\n", SOFTWARE_VERSION_STR );
    CLI_printf("#*******************\n");
    CLI_print_prompt();
    for(;;){
    	if( gSimulatorEnabledFlg == 0 )
    	{
			k = CLI_getkey( 10*1000 );
			if( k == EOF ){
				continue;
			}
			CLI_rx_byte( k );
    	}
    	else
    	{
    		if( gSimulatorCmdTable[gSimulatorCmdTableIndex] != NULL )
    		{
    			memcpy( (void *)(&CLI_common.cmdline[0]), gSimulatorCmdTable[gSimulatorCmdTableIndex], strlen(gSimulatorCmdTable[gSimulatorCmdTableIndex]) );
    			CLI_dispatch();
				/*
				 * NOTE: Above dispatch() call might not return!
				 * If an error occurs, the long jump will occur.
				 */
    			/* clean up from last */
				memset( (void *)(&CLI_common.cmdline[0]), 0, sizeof(CLI_common.cmdline) );
    			gSimulatorCmdTableIndex++;
    		}
    		else
    		{
    			gSimulatorEnabledFlg = 0;
    			if( gFilterPrintMsgFlg == 1 )
    				gFilterPrintMsgFlg = 0;

    			CLI_cmd_stack_clear();
				memset( (void *)(&(CLI_common.cmdline[0])), 0, sizeof(CLI_common.cmdline) );
				CLI_printf("Simul Done\n");
				CLI_print_prompt();
    		}
    	}

    }
}



void CLI_start_task(const struct cli_cmd_entry *pMainMenu)
{
    CLI_init( pMainMenu );
    xTaskCreate ( CLI_task, "CLI", 14 * CLI_TASK_STACKSIZE, NULL, (UBaseType_t)(tskIDLE_PRIORITY+2), &xHandleTestCli);
    configASSERT( xHandleTestCli );
}
