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

#include "drivers/include/udma_i2cm_driver.h"
#include "libs/cli/include/cli.h"
#include "FreeRTOS.h"
#include "semphr.h"	// Required for configASSERT
#include "libs/utils/include/dbg_uart.h"


// I2CM0 functions
static void i2cm_readbyte(const struct cli_cmd_entry *pEntry);
static void i2cm_writebyte(const struct cli_cmd_entry *pEntry);
static void i2cm_writeMultiBytes(const struct cli_cmd_entry *pEntry);
static void i2cm_readMultiBytes(const struct cli_cmd_entry *pEntry);
static void i2cm_reset(const struct cli_cmd_entry *pEntry);
static void i2c_temp(const struct cli_cmd_entry *pEntry);
static void i2c_read_dev_id(const struct cli_cmd_entry *pEntry);
static void i2cm_singlebyte_test(const struct cli_cmd_entry *pEntry);
static void i2c_buffer_reset(const struct cli_cmd_entry *pEntry);
static void i2cm0_test_all(const struct cli_cmd_entry *pEntry);
static void i2cm1_test_all(const struct cli_cmd_entry *pEntry);

static uint8_t i2c_buffer[256] = {0};

// I2CM0 menu
const struct cli_cmd_entry i2cm0_functions[] =
{

  CLI_CMD_WITH_ARG( "readbyte", 	i2cm_readbyte,	0, "i2c_addr reg_addr 			-- read register" ),
  CLI_CMD_WITH_ARG( "writebyte", 	i2cm_writebyte,	0, "i2c_addr reg_addr value 	-- read register" ),
  CLI_CMD_WITH_ARG( "write", 	i2cm_writeMultiBytes,	0, "i2c_addr reg_addr value 	-- write register" ),
  CLI_CMD_WITH_ARG( "read", 	i2cm_readMultiBytes,	0, "i2c_addr reg_addr value 	-- read register" ),
  CLI_CMD_WITH_ARG( "testsinglebyte", 	i2cm_singlebyte_test,	0, "i2c_addr reg_addr	-- writes 0xA5 and then 0x5A to register and checks result" ),
  CLI_CMD_SIMPLE ( "rbuff", i2c_buffer_reset,		    "reset i2c device application buffer"),
  CLI_CMD_SIMPLE ( "all", i2cm0_test_all,		    "test all basic functionalites of i2cm0"),
  CLI_CMD_TERMINATE()

};


// I2CM1 menu
const struct cli_cmd_entry i2cm1_functions[] =
{
	CLI_CMD_WITH_ARG( "readbyte", i2cm_readbyte,	1, "i2c_addr reg_addr 	-- read register" ),
	CLI_CMD_WITH_ARG( "writebyte", 	i2cm_writebyte,	1, "i2c_addr reg_addr value 	-- read register" ),
    CLI_CMD_WITH_ARG( "write", 	i2cm_writeMultiBytes,	1, "i2c_addr reg_addr value 	-- write register" ),
    CLI_CMD_WITH_ARG( "read", 	i2cm_readMultiBytes,	1, "i2c_addr reg_addr value 	-- read register" ),
	CLI_CMD_SIMPLE ( "temp", i2c_temp,				   "read on board temperature"),
	CLI_CMD_SIMPLE ( "dev_id", i2c_read_dev_id,		    "read i2c device id"),
	CLI_CMD_SIMPLE ( "rbuff", i2c_buffer_reset,		    "reset i2c device application buffer"),
	CLI_CMD_SIMPLE ( "all", i2cm1_test_all,		    "test all basic functionalites of i2cm1"),
	CLI_CMD_TERMINATE()
};


/////////////////////////////////////////////////////////////////
//
// I2CM functions
//
/////////////////////////////////////////////////////////////////

static void i2c_buffer_reset(const struct cli_cmd_entry *pEntry)
{
	uint8_t 	lVal = 0;
	CLI_uint8_required( "Value to fill", &lVal );
	memset(i2c_buffer, lVal, 256);
	dbg_str("<<DONE>>\r\n");
}

static void i2cm_readbyte(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	i2c_addr;
	uint32_t	reg_addr;
	uint8_t 	lExpValTrueOrFalse = 0;
	uint8_t    lExpVal = 0;

	CLI_uint32_required( "i2c_addr", &i2c_addr );
	CLI_uint32_required( "reg_addr", &reg_addr );

	if( CLI_is_more_args() ){
		lExpValTrueOrFalse = 1;
		CLI_uint8_required("exp", &lExpVal);
	}

	if( udma_i2cm_read(pEntry->cookie, (uint8_t)i2c_addr, (uint8_t)reg_addr, 1, i2c_buffer, false) == pdTRUE )
	{
		CLI_printf("reg = 0x%02x\n", i2c_buffer[0]);
		if( lExpValTrueOrFalse )
		{
			if( i2c_buffer[0] == lExpVal )
			{
				CLI_printf("i2cm%d readbyte slv addr 0x%02x reg 0x%02x <<PASSED>>\n",pEntry->cookie, i2c_addr, reg_addr);
			}
			else
			{
				CLI_printf("i2cm%d readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n",pEntry->cookie, i2c_addr, reg_addr);
			}
		}
		else
		{
			CLI_printf("i2cm%d readbyte <<DONE>>\n",pEntry->cookie);
		}
	}
	else
	{
		CLI_printf("i2cm%d readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n",pEntry->cookie, i2c_addr, reg_addr);
	}
}

static void i2cm_readMultiBytes(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint8_t	i2c_addr = 0;
	uint8_t	reg_addr = 0;
	uint8_t lNumOfBytesToRead = 0;
	int i = 0;

	CLI_uint8_required( "i2c_addr", &i2c_addr );
	CLI_uint8_required( "reg_addr", &reg_addr );

	CLI_uint8_required( "num of bytes to read", &lNumOfBytesToRead );

	if( udma_i2cm_read(pEntry->cookie, (uint8_t)i2c_addr, (uint8_t)reg_addr, lNumOfBytesToRead, i2c_buffer, false) == pdTRUE )
	{
		dbg_str("Read value: \r\n");
		for( i=0; i<lNumOfBytesToRead; i++ )
		{
			CLI_printf("[%d] 0x%02x\n", i, i2c_buffer[i]);
		}
	}
	else
	{
		CLI_printf("i2cm%d readMultiBytes slv addr 0x%02x reg 0x%02x <<FAILED>>\n",pEntry->cookie, i2c_addr, reg_addr);
	}
}


static void i2cm_writebyte(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	i2c_addr;
	uint32_t	reg_addr;
	uint32_t	reg_value;

	CLI_uint32_required( "i2c_addr", &i2c_addr );
	CLI_uint32_required( "reg_addr", &reg_addr );
	CLI_uint32_required( "reg_value", &reg_value );

	i2c_buffer[0] = (uint8_t)reg_value;
	udma_i2cm_write (pEntry->cookie, i2c_addr, reg_addr, 1, i2c_buffer,  false);

	dbg_str("<<DONE>>\r\n");
}

static void i2cm_writeMultiBytes(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint8_t	i2c_addr = 0;
	uint8_t	reg_addr = 0;
	int i = 0;

	CLI_uint8_required( "i2c_addr", &i2c_addr );
	CLI_uint8_required( "reg_addr", &reg_addr );
	i = 0;
	while( CLI_is_more_args() )
	{
		CLI_uint8_required("reg value", &i2c_buffer[i]);
		i++;
	}

	udma_i2cm_write (pEntry->cookie, i2c_addr, reg_addr, i, i2c_buffer,  false);

	dbg_str("<<DONE>>\r\n");
}

static void i2cm_reset(const struct cli_cmd_entry *pEntry)
{
    (void)pEntry;
    // Add functionality here

    udma_i2cm_control(pEntry->cookie, kI2cmReset, NULL);
}

static void i2cm_singlebyte_test(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	i2c_addr;
	uint32_t	reg_addr;
	bool		fPassed = false;

	CLI_uint32_required( "i2c_addr", &i2c_addr );
	CLI_uint32_required( "reg_addr", &reg_addr );

	i2c_buffer[0] = 0xA5;
	udma_i2cm_write (pEntry->cookie, i2c_addr, reg_addr, 1, i2c_buffer,  false);
	i2c_buffer[0] = 0xFF;
	udma_i2cm_read(pEntry->cookie, (uint8_t)i2c_addr, (uint8_t)reg_addr, 1, i2c_buffer, false);
	CLI_printf("First access = 0x%02x\n", i2c_buffer[0]);
	if (i2c_buffer[0] == 0xA5) {
		i2c_buffer[0] = 0x5A;
		udma_i2cm_write (pEntry->cookie, i2c_addr, reg_addr, 1, i2c_buffer,  false);
		i2c_buffer[0] = 0xFF;
		udma_i2cm_read(pEntry->cookie, (uint8_t)i2c_addr, (uint8_t)reg_addr, 1, i2c_buffer, false);
		CLI_printf("Second access = 0x%02x\n", i2c_buffer[0]);
		if (i2c_buffer[0] == 0x5A) {
			fPassed = true;
		}
	}
	if (fPassed) {
		CLI_printf("i2cm%d singlebyte_test slv addr 0x%02x reg 0x%02x <<PASSED>>\n",pEntry->cookie, i2c_addr, reg_addr);
	} else {
		CLI_printf("i2cm%d singlebyte_test slv addr 0x%02x reg 0x%02x <<FAILED>>\n",pEntry->cookie, i2c_addr, reg_addr);
	}
}

static void i2c_temp (const struct cli_cmd_entry *pEntry)
{

	int temp;

	udma_i2cm_read(1, 0x96, 0x00, 2, i2c_buffer, false);
	temp = (i2c_buffer[0] << 8) + i2c_buffer[1];
	temp = ((temp *625) / 44000) + 32;
	CLI_printf(" Board temp = %d F\r\n", temp);
	dbg_str("<<DONE>>\r\n");
}

static void i2c_read_dev_id(const struct cli_cmd_entry *pEntry)
{
	char *message = 0;
	int temp;
	message  = pvPortMalloc(80);
	configASSERT (message);
	udma_i2cm_read(1, 0x96, 0x0B, 1, i2c_buffer, false);

	sprintf(message," i2c_dev_id:= 0x%x \r\n", i2c_buffer[0]);
	dbg_str(message);
	if(i2c_buffer[0] == 0xCB) {
		dbg_str("Dev Id Test: <<PASSED>>\r\n");
	}
	else {
		dbg_str("Dev Id Test: <<FAILED>>\r\n");
	}
	vPortFree(message);
}

static void i2cm0_test_all(const struct cli_cmd_entry *pEntry)
{

	bool		fPassed = false;

	hal_setpinmux(23, 2);
	hal_setpinmux(24, 2);
	i2c_buffer[0] = 0x3D;
	udma_i2cm_write (0, 0xDE, 0x10, 1, i2c_buffer,  false);

	udma_i2cm_read(0, 0xDE, 0x10, 1, &i2c_buffer[1], false);
	if( i2c_buffer[1] == 0xFF )
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<PASSED>>\n",0xDE, 0x10);
	}
	else
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n",0xDE, 0x10);
	}

	i2c_buffer[0] = 0x5C;
	udma_i2cm_write (0, 0xC4, 0x10, 1, i2c_buffer,  false);

	udma_i2cm_read(0, 0xC4, 0x10, 1, &i2c_buffer[1], false);
	if( i2c_buffer[1] == 0xFF )
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<PASSED>>\n", 0xC4, 0x10);
	}
	else
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n", 0xC4, 0x10);
	}

	hal_setpinmux(23, 0);
	hal_setpinmux(24, 0);

	i2c_buffer[0] = 0x5C;
	udma_i2cm_write (0, 0xDE, 0x10, 1, i2c_buffer,  false);

	udma_i2cm_read(0, 0xDE, 0x10, 1, &i2c_buffer[1], false);
	if( i2c_buffer[1] == 0x5C )
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<PASSED>>\n", 0xDE, 0x10);
	}
	else
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n", 0xDE, 0x10);
	}

	i2c_buffer[0] = 0xA5;
	udma_i2cm_write (0, 0xDE, 0x10, 1, i2c_buffer,  false);
	i2c_buffer[0] = 0xFF;
	udma_i2cm_read(0, 0xDE, 0x10, 1, i2c_buffer, false);
	CLI_printf("First access = 0x%02x\n", i2c_buffer[0]);
	if (i2c_buffer[0] == 0xA5) {
		i2c_buffer[0] = 0x5A;
		udma_i2cm_write (0, 0xDE, 0x10, 1, i2c_buffer,  false);
		i2c_buffer[0] = 0xFF;
		udma_i2cm_read(0, 0xDE, 0x10, 1, i2c_buffer, false);
		CLI_printf("Second access = 0x%02x\n", i2c_buffer[0]);
		if (i2c_buffer[0] == 0x5A) {
			fPassed = true;
		}
	}
	if (fPassed) {
		CLI_printf("i2cm0 singlebyte_test slv addr 0x%02x reg 0x%02x <<PASSED>>\n", 0xDE, 0x10);
	} else {
		CLI_printf("i2cm0 singlebyte_test slv addr 0x%02x reg 0x%02x <<FAILED>>\n", 0xDE, 0x10);
	}

	i2c_buffer[0] = 0x5C;
	udma_i2cm_write (0, 0xC4, 0x10, 1, i2c_buffer,  false);

	udma_i2cm_read(0, 0xC4, 0x10, 1, &i2c_buffer[1], false);
	if( i2c_buffer[1] == 0x5C )
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<PASSED>>\n", 0xC4, 0x10);
	}
	else
	{
		CLI_printf("i2cm0 readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n", 0xC4, 0x10);
	}

	i2c_buffer[0] = 0xA5;
	udma_i2cm_write (0, 0xC4, 0x10, 1, i2c_buffer,  false);
	i2c_buffer[0] = 0xFF;
	udma_i2cm_read(0, 0xC4, 0x10, 1, i2c_buffer, false);
	CLI_printf("First access = 0x%02x\n", i2c_buffer[0]);
	if (i2c_buffer[0] == 0xA5) {
		i2c_buffer[0] = 0x5A;
		udma_i2cm_write (0, 0xC4, 0x10, 1, i2c_buffer,  false);
		i2c_buffer[0] = 0xFF;
		udma_i2cm_read(0, 0xC4, 0x10, 1, i2c_buffer, false);
		CLI_printf("Second access = 0x%02x\n", i2c_buffer[0]);
		if (i2c_buffer[0] == 0x5A) {
			fPassed = true;
		}
	}
	if (fPassed) {
		CLI_printf("i2cm0 singlebyte_test slv addr 0x%02x reg 0x%02x <<PASSED>>\n", 0xC4, 0x10);
	} else {
		CLI_printf("i2cm0 singlebyte_test slv addr 0x%02x reg 0x%02x <<FAILED>>\n", 0xC4, 0x10);
	}
}

static void i2cm1_test_all(const struct cli_cmd_entry *pEntry)
{

	hal_setpinmux(46, 2);
	hal_setpinmux(47, 2);

	udma_i2cm_read(0, 0x96, 0x0B, 1, &i2c_buffer[1], false);
	if( i2c_buffer[1] == 0xFF )
	{
		CLI_printf("i2cm1 readbyte slv addr 0x%02x reg 0x%02x <<PASSED>>\n", 0x96, 0x0B);
	}
	else
	{
		CLI_printf("i2cm1 readbyte slv addr 0x%02x reg 0x%02x <<FAILED>>\n", 0x96, 0x0B);
	}
	hal_setpinmux(46, 0);
	hal_setpinmux(47, 0);
	i2c_temp(NULL);
	i2c_read_dev_id(NULL);
}

