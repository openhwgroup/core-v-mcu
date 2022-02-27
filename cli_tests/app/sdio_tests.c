/*
 * sdio_tests.c
 *
 *  Created on: 20-Oct-2021
 *      Author: somesh
 */

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

#include "hal/include/hal_fc_event.h"
#include "hal/include/hal_pinmux.h"
#include "drivers/include/udma_sdio_driver.h"

static void sdio_CardStdbyToTrsfrMode(const struct cli_cmd_entry *pEntry);
static void sdio_cardInit(const struct cli_cmd_entry *pEntry);
static void sdio_test (const struct cli_cmd_entry *pEntry);
static void sdio_cardRead(const struct cli_cmd_entry *pEntry);
static void sdio_cardWrite(const struct cli_cmd_entry *pEntry);

uint16_t gRelativeCardAddress = 0;
uint32_t gBlockReadBuf[130] = {0};
uint32_t gBlockWriteBuf[130] = {0};
// EFPGA menu
const struct cli_cmd_entry sdio_cli_tests[] =
{
  CLI_CMD_SIMPLE( "trsfr", sdio_CardStdbyToTrsfrMode, "sdio init" ),
  CLI_CMD_WITH_ARG( "cread", sdio_cardRead, 0, "sdio card read" ),
  CLI_CMD_WITH_ARG( "cwrite", sdio_cardWrite, 0, "sdio card write" ),
  CLI_CMD_WITH_ARG( "cinit", sdio_cardInit, 0, "sdio card init" ),
  CLI_CMD_WITH_ARG( "test", sdio_test, 0, "read flash id" ),
  CLI_CMD_TERMINATE()
};

static void sdio_cardWrite(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	uint8_t lSts = 0;
	uint8_t lCmd = 0;
	uint32_t lCmdArg = 0;
	uint32_t lRspBuf[4] = {0};
	uint32_t i = 0;
	uint32_t lBlockAddr = 0;
	(void)pEntry;

	CLI_uint32_required( "block Address", &lBlockAddr );
	udma_sdio_writeBlockData(0, 1, gBlockWriteBuf, 512);

	lCmd = 0x18;	//CMD24
	lCmdArg = lBlockAddr;	//SD card block address as the argument
	lSts = udma_sdio_sendCmd(0, lCmd, 0x02, lCmdArg, lRspBuf);

	udma_sdio_clearDataSetup(0);
	if( lSts == 5 )
		udma_sdio_open(0);
	CLI_printf("\nCMD %d Arg = 0x%08x sts 0x%02x\n",lCmd, lCmdArg, lSts);
	CLI_printf("Rsp 0x%08x 0x%08x\n", lRspBuf[0], lRspBuf[1]);

}
static void sdio_cardRead(const struct cli_cmd_entry *pEntry)
{
	uint8_t lSts = 0;
	uint8_t lCmd = 0;
	uint32_t lCmdArg = 0;
	uint32_t lRspBuf[4] = {0};
	uint32_t i = 0;
	uint32_t lBlockAddr = 0;
	(void)pEntry;
	CLI_uint32_required( "block Address", &lBlockAddr );

	for(i=0; i<128; i++ )
	{
		gBlockReadBuf[i] = 0x10101010 + i;
	}
	udma_sdio_readBlockData(0, 1, gBlockReadBuf, 512);

	lCmd = 0x11;	//CMD17
	lCmdArg = lBlockAddr;	//SD card block address as the argument
	lSts = udma_sdio_sendCmd(0, lCmd, 0x02, lCmdArg, lRspBuf);

	udma_sdio_clearDataSetup(0);
	if( lSts == 5 )
			udma_sdio_open(0);
	CLI_printf("\nCMD %d Arg = 0x%08x sts 0x%02x\n",lCmd, lCmdArg, lSts);
	CLI_printf("Rsp 0x%08x 0x%08x\n", lRspBuf[0], lRspBuf[1]);
	for(i=0; i<16; i++ )
	{
		CLI_printf("0x%08x\n", gBlockReadBuf[i]);
	}

}

static void sdio_readCardSpecificData(void)
{

}

static void sdio_CardStandbyToTransferMode(void)
{
	uint8_t lSts = 0;
	uint8_t lCmd = 0;
	uint8_t lRspCmdIndex = 0;
	uint32_t lCmdArg = 0;
	uint32_t lCardStatus = 0;
	uint32_t lRspBuf[4] = {0};

	if( gRelativeCardAddress != 0 )
	{
		lCmd = 0x07;
		lCmdArg = 0;
		lCmdArg |= ( gRelativeCardAddress << 16 );
		lSts = udma_sdio_sendCmd(0, lCmd, 0x04, lCmdArg, lRspBuf);	//CMD 07
		CLI_printf("\nCMD %d Arg 0x%08x sts 0x%02x\n",lCmd, lCmdArg, lSts);

		CLI_printf("Rsp R1b = 0x%08x 0x%08x\n", lRspBuf[0], lRspBuf[1]);


		lCmd = 0x37;
		lCmdArg = 0;
		lCmdArg |= ( gRelativeCardAddress << 16 );
		lSts = udma_sdio_sendCmd(0, lCmd, 0x02, lCmdArg, lRspBuf);	//CMD 55
		CLI_printf("\nCMD %d sts 0x%02x\n",lCmd, lSts);
		lCardStatus = lRspBuf[0];
		lRspCmdIndex = lRspBuf[1] & 0x3F;
		CLI_printf("Rsp R1 card status = 0x%08x\n", lCardStatus);

		CLI_printf("Rsp R1 cmd Index = 0x%02x\n", lRspCmdIndex);
		if( lRspCmdIndex == lCmd )
		{
			dbg_str("Cmd Index correct\r\n");
		}

		lCmd = 0x06;
		lCmdArg = 0x02;	//arg=2 means quad mode (4 data lines)
		lSts = udma_sdio_sendCmd(0, lCmd, 0x02, lCmdArg, lRspBuf);	//ACMD 41
		CLI_printf("\nCMD %d Arg = 0x%08x sts 0x%02x\n",lCmd, lCmdArg, lSts);
		lCardStatus = lRspBuf[0];
		lRspCmdIndex = lRspBuf[1] & 0x3F;
		CLI_printf("Rsp R1 card status = 0x%08x\n", lCardStatus);

		CLI_printf("Rsp R1 cmd Index = 0x%02x\n", lRspCmdIndex);
		if( lRspCmdIndex == lCmd )
		{
			dbg_str("Cmd Index correct\r\n");
		}
	}
	else
	{
		CLI_printf("Init card first\n");
	}

}

static void sdio_CardStdbyToTrsfrMode(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	sdio_CardStandbyToTransferMode();
}

static void sdio_cardInit(const struct cli_cmd_entry *pEntry)
{
	uint8_t lSts = 0;
	uint8_t lCmd = 0;
	uint8_t lRspCmdIndex = 0;
	uint8_t lS18A = 0, lBusyBit = 0, lCCSBit = 0, lUHS2Bit = 0;
	uint16_t lOperatingConditionRegister = 0;
	uint32_t lRspBuf[4] = {0};
	uint32_t lCmdArg = 0;
	uint32_t lCardStatus = 0;
	uint16_t i = 0, j = 0;

	uint8_t lCheckPattern = 0xAA;
	uint8_t lVoltageSupplied = 0x01;	//2.7 - 3.3v
	(void)pEntry;

	// Add functionality here

	udma_sdio_open(0);

	lCmd = 0x0;
	lSts = udma_sdio_sendCmd(0, lCmd, 0x00, 0x00000000, NULL);	//CMD 0
	CLI_printf("\nCMD %d sts 0x%02x\n",lCmd, lSts);

	lCmd = 0x08;
	lCmdArg = 0;
	lCmdArg |= ( lCheckPattern << 0 );
	lCmdArg |= ( lVoltageSupplied << 8 );
	lSts = udma_sdio_sendCmd(0, lCmd, 0x02, lCmdArg, lRspBuf);	//CMD 8
	CLI_printf("\nCMD %d Arg = 0x%08x sts 0x%02x\n",lCmd, lCmdArg, lSts);
	CLI_printf("Rsp R7 = 0x%08x\n", lRspBuf[0]);
	if( ( lRspBuf[0] & 0xFF ) == lCheckPattern )
	{
		dbg_str("Check pattern echoback correct\r\n");
	}

	if( ( lRspBuf[0] & 0x000F0000 ) >> 8 == lVoltageSupplied)
	{
		dbg_str("2.7-3.3v accepted\r\n");
	}

	lRspCmdIndex = lRspBuf[1] & 0x3F;
	CLI_printf("Rsp R7 cmd Index = 0x%02x\n", lRspCmdIndex);
	if( lRspCmdIndex == lCmd )
	{
		dbg_str("Cmd Index correct\r\n");
	}

	lCmd = 0x37;
	lSts = udma_sdio_sendCmd(0, lCmd, 0x02, 0x00000000, lRspBuf);	//CMD 55
	CLI_printf("\nCMD %d sts 0x%02x\n",lCmd, lSts);
	lCardStatus = lRspBuf[0];
	lRspCmdIndex = lRspBuf[1] & 0x3F;
	CLI_printf("Rsp R1 card status = 0x%08x\n", lCardStatus);

	CLI_printf("Rsp R1 cmd Index = 0x%02x\n", lRspCmdIndex);
	if( lRspCmdIndex == lCmd )
	{
		dbg_str("Cmd Index correct\r\n");
	}

	if( lSts == 0 )
	{
		for(i=0; i<5; i++ )
		{
			lCmd = 0x37;
			lSts = udma_sdio_sendCmd(0, lCmd, 0x02, 0x00000000, lRspBuf);	//CMD 55
			CLI_printf("\nCMD %d sts 0x%02x\n",lCmd, lSts);
			lCardStatus = lRspBuf[0];
			lRspCmdIndex = lRspBuf[1] & 0x3F;
			CLI_printf("Rsp R1 card status = 0x%08x\n", lCardStatus);

			CLI_printf("Rsp R1 cmd Index = 0x%02x\n", lRspCmdIndex);
			if( lRspCmdIndex == lCmd )
			{
				dbg_str("Cmd Index correct\r\n");
			}

			vTaskDelay(50);

			lCmd = 0x29;
			lCmdArg = 0;
			lCmdArg |= (1 << 31);	//
			lCmdArg |= (1 << 30);	//Set to SDHC or SDXC card capacity (2-32GB)
			lCmdArg |= (1 << 20);	//


			lSts = udma_sdio_sendCmd(0, lCmd, 0x02, lCmdArg, lRspBuf);	//ACMD 41
			CLI_printf("\nCMD %d Arg = 0x%08x sts 0x%02x\n",lCmd, lCmdArg, lSts);

			CLI_printf("Rsp R3 = 0x%08x\n", lRspBuf[0]);

			lOperatingConditionRegister = ( lRspBuf[0] & 0x00FFFF00 ) >> 8;
			lS18A = ( lRspBuf[0] & 0x01000000 ) >> 24;
			lBusyBit = ( lRspBuf[0] & 0x80000000 ) >> 31;
			lCCSBit = ( lRspBuf[0] & 0x40000000 ) >> 30;
			lUHS2Bit = ( lRspBuf[0] & 0x20000000 ) >> 29;

			CLI_printf("lS18A 0x%02x, lBusyBit 0x%02x, lCCSBit 0x%02x, lUHS2Bit 0x%02x\n", lS18A, lBusyBit, lCCSBit, lUHS2Bit);

			lRspCmdIndex = lRspBuf[1] & 0x3F;
			CLI_printf("Rsp R3 cmd Index = 0x%02x\n", lRspCmdIndex);
			if( lRspCmdIndex == 0x3F )
			{
				dbg_str("Cmd Index correct\r\n");
			}

			if( lBusyBit == 1 )
				break;

			vTaskDelay(50);
		}

		if( i == 5 )
			dbg_str("Card init failed\r\n");
		else
		{
			dbg_str("Card init passed\r\n");
			vTaskDelay(50);
			i = 0;
			lCmd = 0x02;
			lSts = udma_sdio_sendCmd(0, lCmd, 0x03, 0x00000000, lRspBuf);	//CMD 02
			CLI_printf("\nCMD %d sts 0x%02x\n",lCmd, lSts);
			CLI_printf("CID 0x%08x 0x%08x 0x%08x 0x%08x\n", lRspBuf[0], lRspBuf[1], lRspBuf[2], lRspBuf[3]);

			CLI_printf("Manufacturer ID = 0x%02x\n", ( ( lRspBuf[3] & 0xFF000000) >> 24));
			CLI_printf("OEM ID = 0x%04x\n", ( ( lRspBuf[3] & 0x00FFFF00) >> 8));
			CLI_printf("Product Name = %c%c%c%c%c\n",  ( ( lRspBuf[3] & 0x000000FF) >> 0), ( ( lRspBuf[2] & 0xFF000000) >> 24),( ( lRspBuf[2] & 0x00FF0000) >> 16),( ( lRspBuf[2] & 0x0000FF00) >> 8),( ( lRspBuf[2] & 0x000000FF) >> 0) );
			CLI_printf("Product Rev = 0x%02x\n",( ( lRspBuf[1] & 0xFF000000) >> 24));
			CLI_printf("Product Serial Number = 0x%08x\n",( ( lRspBuf[1] & 0x00FFFFFF) << 8) | ( ( lRspBuf[0] & 0xFF000000) >> 24));
			CLI_printf("Mfg Dt = 0x%08x\n", ( ( lRspBuf[0] & 0x000FFF00) >> 8));

			vTaskDelay(50);
			lCmd = 0x03;
			lSts = udma_sdio_sendCmd(0, lCmd, 0x02, 0x00000000, lRspBuf);	//CMD 03
			CLI_printf("\nCMD %d sts 0x%02x\n",lCmd, lSts);
			CLI_printf("0x%08x\n", lRspBuf[0]);
			gRelativeCardAddress = ( lRspBuf[0] & 0xFFFF0000 ) >> 16;
			CLI_printf("RCA 0x%04x\n", gRelativeCardAddress);

			sdio_readCardSpecificData();
			sdio_CardStandbyToTransferMode();
		}
	}

	for(i=0; i<128; i++ )
	{
		gBlockWriteBuf[i] = 0x12340000 + i;
		gBlockReadBuf[i] = 0x10101010 + i;
	}

	CLI_printf("Read buf init\n");
	for(i=0; i<16; i++ )
	{
		CLI_printf("0x%08x\n", gBlockReadBuf[i]);
	}

	CLI_printf("Write buf init\n");
	for(i=0; i<16; i++ )
	{
		CLI_printf("0x%08x\n", gBlockWriteBuf[i]);
	}
}

static void sdio_test(const struct cli_cmd_entry *pEntry)
{
	uint8_t lSts = 0;
	uint8_t lCmdOp = 0;
	(void)pEntry;
	CLI_uint8_required( "Command Op code", &lCmdOp );
	// Add functionality here
	lSts = udma_sdio_sendCmd(0, lCmdOp, 0, 0, NULL);
	CLI_printf("DONE 0x%02x\n", lSts);
}

