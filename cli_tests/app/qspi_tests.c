/*
 * qspi_tests.c
 *
 *  Created on: Apr 12, 2021
 *      Author: gregmartin
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
#include "drivers/include/udma_qspi_driver.h"
#include "hal/include/hal_pinmux.h"
#include "N25Q_16Mb-1Gb_Device_Driver V2.1/N25Q.h"

typedef union {
	uint32_t w;
	uint8_t b[4];
} split_4Byte_t ;

extern uint8_t gQSPIFlashPresentFlg;
extern uint8_t gMicronFlashDetectedFlg;

uint8_t gQuadModeSupportedFlg = 0;
uint8_t gMicronFlashInitDoneFlag = 0;

extern FLASH_DEVICE_OBJECT gFlashDeviceObject;

extern int x_main(void);

extern int x_main(void);

static void qspi_read(const struct cli_cmd_entry *pEntry);
static void qspi_write(const struct cli_cmd_entry *pEntry);
static void flash_readid (const struct cli_cmd_entry *pEntry);
static void flash_init (const struct cli_cmd_entry *pEntry);
static void flash_sector_erase (const struct cli_cmd_entry *pEntry);
static void flash_subsector_erase (const struct cli_cmd_entry *pEntry);
static void flash_bulk_erase (const struct cli_cmd_entry *pEntry);
static void flash_read (const struct cli_cmd_entry *pEntry);
static void flash_write (const struct cli_cmd_entry *pEntry);
static void program (const struct cli_cmd_entry *pEntry);
static void flash_peek (const struct cli_cmd_entry *pEntry);
static void flash_poke (const struct cli_cmd_entry *pEntry);
static void flash_reset(const struct cli_cmd_entry *pEntry);
static void flash_quad_peek (const struct cli_cmd_entry *pEntry);
static void flash_quad_poke (const struct cli_cmd_entry *pEntry);
// EFPGA menu
const struct cli_cmd_entry qspi_cli_tests[] =
{
  CLI_CMD_SIMPLE( "read", qspi_read, "qspi read" ),
  CLI_CMD_WITH_ARG( "write", qspi_write, 0, "qspi write" ),
  CLI_CMD_WITH_ARG( "flashid", flash_readid, 0, "read flash id" ),
  CLI_CMD_WITH_ARG( "init", flash_init, 0, "enter into quad io mode" ),
  CLI_CMD_WITH_ARG( "reset", flash_reset, 0, "Reset flash" ),
  CLI_CMD_WITH_ARG( "flash_read", flash_read, 0, "read spi flash address, num_bytes"),
  CLI_CMD_WITH_ARG( "flash_write", flash_write, 0, "write spi flash address, data"),
  CLI_CMD_WITH_ARG( "flash_peek", flash_peek, 0, "read spi flash address, 4 bytes fixed"),
  CLI_CMD_WITH_ARG( "flash_poke", flash_poke, 0, "write spi flash address, 4 bytes fixed"),
  CLI_CMD_WITH_ARG( "flash_qpeek", flash_quad_peek, 0, "read spi flash address in quad mode, 4 bytes fixed"),
  CLI_CMD_WITH_ARG( "flash_qpoke", flash_quad_poke, 0, "write spi flash address in quad mode, 4 bytes fixed"),
  CLI_CMD_WITH_ARG( "erase", flash_subsector_erase, 0, "Erase 4K subsector" ),
  CLI_CMD_WITH_ARG( "sector_erase", flash_sector_erase, 0, "Erase 64K sector" ),
  CLI_CMD_WITH_ARG( "bulk_erase", flash_bulk_erase, 0, "Erase All 32MB" ),
  CLI_CMD_SIMPLE( "program", program, "Program <filename>"),
  CLI_CMD_TERMINATE()
};

int8_t flashWrite_Micron(uint32_t addr, uint8_t *aWritebuff, uint32_t aLen)
{
	ParameterType para;
	para.PageProgram.udAddr = addr;
	para.PageProgram.pArray = aWritebuff;
	para.PageProgram.udNrOfElementsInArray = aLen;
	if(gFlashDeviceObject.GenOp.DataProgram(PageProgram, &para)!=Flash_Success)
		return -1;
	return 0;
}

int8_t flashRead_Micron(uint32_t addr, uint8_t *aReadBuf, uint32_t aLen)
{
	ParameterType para;
	para.Read.udAddr = addr;
	para.Read.pArray = aReadBuf;
	para.Read.udNrOfElementsToRead = aLen;
	if(gFlashDeviceObject.GenOp.DataRead(Read, &para)!=Flash_Success)
		return -1;
	return 0;
}

int8_t flashQuadInputFastProgram_Micron(uint32_t addr, uint8_t *aWritebuff, uint32_t aLen)
{
	ParameterType para;
	para.PageProgram.udAddr = addr;
	para.PageProgram.pArray = aWritebuff;
	para.PageProgram.udNrOfElementsInArray = aLen;
	if(gFlashDeviceObject.GenOp.DataProgram(QuadInputProgram, &para)!=Flash_Success)
		return -1;
	return 0;
}

int8_t flashQuadOutputFastRead_Micron(uint32_t addr, uint8_t *aReadBuf, uint32_t aLen)
{
	ParameterType para;
	para.Read.udAddr = addr;
	para.Read.pArray = aReadBuf;
	para.Read.udNrOfElementsToRead = aLen;
	if(gFlashDeviceObject.GenOp.DataRead(QuadOutputFastRead, &para)!=Flash_Success)
		return -1;
	return 0;
}
/*
 * Memory Configuration
 * Each page of memory can be individually programmed. Bits are programmed from one
through zero. The device is subsector, sector, or bulk-erasable, but not page-erasable.
Bits are erased from zero through one. The memory is configured as 33,554,432 bytes (8
bits each); 512 sectors (64KB each); 8192 subsectors (4KB each); and 131,072 pages (256
bytes each); and 64 OTP bytes are located outside the main memory array.
 */
int8_t flashEraseSector_Micron(uint16_t startSecNum, uint16_t numOfSectors)
{
	int i;
	ReturnType ret;
	if((startSecNum + numOfSectors) > gFlashDeviceObject.Desc.FlashSectorCount)
		return -2;
	for (i=0; i<numOfSectors; i++) {
		do {
			ret = gFlashDeviceObject.GenOp.SectorErase(startSecNum + i);
			if(ret!=Flash_OperationOngoing && ret!=Flash_Success) {
				CLI_printf("Error number (%d) in sector number (%d)\n", ret, i);
				return -1;
			}
		} while(ret==Flash_OperationOngoing);
	}

	return 0;
}

int8_t flashEraseSubsector_Micron(uint16_t startSubsecNum, uint16_t numOfSubsectors)
{
	int i;
	ReturnType ret;
	if((startSubsecNum + numOfSubsectors) > gFlashDeviceObject.Desc.FlashSubSectorCount)
		return -2;
	for (i=0; i<numOfSubsectors; i++) {
		do {
			ret = gFlashDeviceObject.GenOp.SubSectorErase(startSubsecNum+i);
			if(ret!=Flash_OperationOngoing && ret!=Flash_Success) {
				CLI_printf("Error number (%d) in subsector number (%d)\n", ret, i);
				return -1;
			}
		} while(ret==Flash_OperationOngoing);
	}

	return 0;
}
void getSectorNumAndSubSectorNumFromAddress(uint32_t aAddress, uint32_t *aSectorNum, uint32_t *aSubSectorNum)
{
    uint32_t lSectorNum = 0;
    uint32_t lSubSectorNum = 0;
    lSectorNum = ( aAddress >> gFlashDeviceObject.Desc.FlashSectorSize_bit ) & 0x1FF;
    lSubSectorNum = ( ( lSectorNum * 16 ) + ( ( aAddress >> gFlashDeviceObject.Desc.FlashSubSectorSize_bit ) & 0xF ) );
    if( aSectorNum )
        *aSectorNum = lSectorNum;
     if( aSubSectorNum )
        *aSubSectorNum = lSubSectorNum;

}

static uint8_t gsProgramBuf[32] = {0};
static void program (const struct cli_cmd_entry *pEntry) {
char*  pzArg = NULL;
	(void)pEntry;
	union {
		int d32;
		char d8[4];
	} sdata;
	char type = 0;
	int count = 0;
	int i = 0;
	uint32_t fl_addr;
	uint8_t lChar = 'c';
	uint32_t lRemaingBytes = 0;
	uint32_t lBytesToExpect = 0;
	uint16_t lSectorNum = 0;
	uint32_t lSubSectorNum = 0;
	uint16_t lSectorsToErase = 0;
	// Add functionality here
	if( gMicronFlashInitDoneFlag == 0 )
		flash_init(NULL);
	CLI_string_ptr_required("Loading file: ", &pzArg);
	CLI_uint32_required( "addr", &fl_addr );
		if (pzArg != NULL) {
			udma_uart_writeraw(1, 5, "Load ");
			udma_uart_writeraw(1, strlen(pzArg), pzArg);
			udma_uart_writeraw(1,2,"\r\n");
			type = 0;
			while (type != 'z') {
				type = uart_getchar(1);
				if (type == 'C') {
					if( lRemaingBytes )
					{
						if( lRemaingBytes >= 32 )
						{
							lBytesToExpect = 32;
						}
						else
						{
							lBytesToExpect = lRemaingBytes;
						}

						for (i = 0; i < lBytesToExpect; i++)
							gsProgramBuf[i]= uart_getchar(1);
						//udma_flash_write(0, 0, fl_addr, &sdata.d32, 4);
						flashQuadInputFastProgram_Micron(fl_addr, gsProgramBuf, lBytesToExpect);
						count += lBytesToExpect;
						fl_addr += lBytesToExpect;
						lRemaingBytes -= lBytesToExpect;

						if ((count & 0x3ff) == 0)
						{
							//dbg_str(".");
							CLI_printf("%d/%d\n",count,sdata.d32);
						}
					}
					else
					{
						; //?
					}

				}
				else if (type == 's') {
					for (i = 0; i < 4; i++)
						sdata.d8[i]= uart_getchar(1);
					lRemaingBytes = sdata.d32;
					getSectorNumAndSubSectorNumFromAddress(fl_addr, &lSectorNum, &lSubSectorNum);
					lSectorsToErase = (lRemaingBytes / gFlashDeviceObject.Desc.FlashSectorSize);

					dbg_str("Expecting ");
					dbg_hex32(sdata.d32);
					dbg_str(" bytes\r\n");
					/*erase_addr = fl_addr & ~0xfff;
					while (sdata.d32 > 0) {
						if(sdata.d32 & 0xfff)
							sdata.d32 -= sdata.d32 & 0xfff;
						else
							sdata.d32 -= 0x1000;
						dbg_str("Erasing 4k page at ");
						dbg_hex32(erase_addr);
						dbg_str("\r");
						udma_flash_erase(0, 0, erase_addr, 0); // 4k Sector erase
						erase_addr += 0x1000;

					}*/
					dbg_str("Erasing. . .");

					flashEraseSector_Micron(lSectorNum ,lSectorsToErase + 1);
					//flashEraseSector_Micron(0 ,510);
					dbg_str("done");
					dbg_str("\r\n");
				}
				if (type != 'z')
					udma_uart_writeraw(1,1,&lChar);
			}
			CLI_printf("Received Bytes 0x%08x\n",count);
	}
}


static void flash_write (const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	char *message;
	int errors = 0;
	int addr, i;
	uint16_t length;
	uint8_t l2addr[4];
	uint32_t wdata;

	if( gQSPIFlashPresentFlg == 1)
	{
		CLI_uint32_required( "addr", &addr );
		CLI_uint32_required( "data", &wdata );
		l2addr[0] = (wdata >> 24) & 0xff;
		l2addr[1] = (wdata >> 16) & 0xff;
		l2addr[2] = (wdata >> 8) & 0xff;
		l2addr[3] = wdata  & 0xff;
		message  = pvPortMalloc(80);
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		sprintf(message,"Qspi Flash write\n");
		dbg_str(message);
		udma_flash_write(0, 0, addr, l2addr, 4);
		udma_flash_read(0, 0, addr, l2addr, 4);
		sprintf(message,"Read data = %02x",l2addr[0]);
		dbg_str(message);
		for (i = 1; i < 4; i++) {
			sprintf(message," %02x",l2addr[i]);
			dbg_str(message);
		}
		dbg_str("\n");
		vPortFree(message);
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}
static void flash_read(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	char *message;
	int errors = 0;
	uint32_t addr, i;
	uint16_t length;
	uint8_t *l2addr;
	if( gQSPIFlashPresentFlg == 1 )
	{
		CLI_uint32_required( "addr", &addr );
		CLI_uint16_required( "length", &length );
		message  = pvPortMalloc(80);
		l2addr = pvPortMalloc(length);
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		sprintf(message,"Qspi Flash Read\n");
		dbg_str(message);
		udma_flash_read(0, 0, addr, l2addr, length);
		sprintf(message,"Read data = %02x",l2addr[0]);
		dbg_str(message);
		for (i = 1; i < length; i++) {
			sprintf(message," %02x",l2addr[i]);
			dbg_str(message);
		}
		dbg_str("\n");
		vPortFree(l2addr);
		vPortFree(message);
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}

static void flash_bulk_erase (const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	char *message;
	int errors = 0;
	int addr,i;
	uint8_t result;
	if( gQSPIFlashPresentFlg == 1 )
	{
		message  = pvPortMalloc(80);
		CLI_uint32_required( "addr", &addr );
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		result = udma_flash_erase(0,0,addr,2);
		sprintf(message,"FLASH all erase = %s\n",
				result ? "<<PASSED>>" : "<<FAILED>>");
		dbg_str(message);
		vPortFree(message);
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}
static void flash_sector_erase (const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here

	char *message;
	int errors = 0;
	int addr,i;
	uint8_t result;
	if( gQSPIFlashPresentFlg == 1 )
	{
		message  = pvPortMalloc(80);
		CLI_uint32_required( "addr", &addr );
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		result = udma_flash_erase(0,0,addr,1);
		sprintf(message,"FLASH sector 0x%x = %s\n", addr,
				result ? "<<PASSED>>" : "<<FAILED>>");
		dbg_str(message);
		vPortFree(message);
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}

}

static void flash_subsector_erase (const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	char *message;
	int errors = 0;
	int addr,i;
	uint8_t result;
	if( gQSPIFlashPresentFlg == 1 )
	{
		message  = pvPortMalloc(80);
		CLI_uint32_required( "addr", &addr );
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		result = udma_flash_erase(0,0,addr,0);
		sprintf(message,"FLASH subsector 0x%x = %s\n", addr,
				result ? "<<PASSED>>" : "<<FAILED>>");
		dbg_str(message);
		vPortFree(message);
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}

static void flash_subsector_erase_new (const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	    // Add functionality here

	uint32_t lStartSubSectorNum = 0;
	uint32_t lNumOfSubSectors = 0;
	uint8_t result;
	if(gQSPIFlashPresentFlg == 1 )
	{
		CLI_uint32_required( "start addr", &lStartSubSectorNum );
		CLI_uint32_required( "Num of sub sectors", &lNumOfSubSectors );
		//udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		//result = udma_flash_erase(0,0,addr,0);
		if( flashEraseSubsector_Micron(lStartSubSectorNum, lNumOfSubSectors) == 0 )
			dbg_str("<<PASSED>>\r\n");
		else
			dbg_str("<<FAILED>>\r\n");
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}

static void flash_readid(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	// Add functionality here

	union {
		uint32_t w;
		uint8_t b[4];
	} result ;

	result.w = 0;
	if( gQSPIFlashPresentFlg == 1 )
	{
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);

		result.w = udma_flash_readid(0,0);

		CLI_printf("FLASH read ID results = 0x%08x %02x %02x %02x %02x\n",
				result.w, result.b[0],result.b[1],result.b[2],result.b[3]);
		if( result.w == 0x1019ba20 )
			CLI_printf("<<PASSED>>\n");
		else
			CLI_printf("<<FAILED>>\n");
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}

}

void udma_flash_enterQuadIOMode(uint8_t qspim_id, uint8_t cs );
static void flash_quad(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	// Add functionality here
	union {
		uint32_t w;
		uint8_t b[4];
	} result ;
	result.w = 0;
	if( gQSPIFlashPresentFlg == 1 )
	{
		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		udma_flash_enterQuadIOMode(0, 0 );
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}


void udma_flash_enterQuadIOMode(uint8_t qspim_id, uint8_t cs );

static void flash_init(const struct cli_cmd_entry *pEntry)
{

	(void)pEntry;
	// Add functionality here

	if( gQSPIFlashPresentFlg == 1 )
	{
		if( gMicronFlashDetectedFlg == 1 )
		{
			if( gMicronFlashInitDoneFlag == 0 )
			{
				Driver_Init(&gFlashDeviceObject);

				dbg_str("<<DONE>>\r\n");
				gMicronFlashInitDoneFlag = 1;
			}
		}
		else
		{
			CLI_printf("NON MICRON FLASH INIT <<ABSENT>>\n");
		}
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}

static void flash_reset(const struct cli_cmd_entry *pEntry)
{
	int i = 0;
	(void)pEntry;
	// Add functionality here

	if( gQSPIFlashPresentFlg == 1 )
	{
		udma_flash_reset_enable(0, 0);
		for (i = 0; i < 10000; i++);
		udma_flash_reset_memory(0, 0);
		for (i = 0; i < 10000; i++);

		dbg_str("<<DONE>>\r\n");
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}


static void qspi_read(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here

	uint8_t read_data[8] = {0xff,0xfe,0xfc,0xf8,0xf0,0xe0,0xc0,0x80};
	uint8_t lRead_data[8] = {0};

	udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
	udma_qspim_read(0, 0, 4, lRead_data);
	CLI_printf("[0x%02x]/[0x%02x]/[0x%02x]/[0x%02x]\n",lRead_data[0], lRead_data[1], lRead_data[2], lRead_data[3]);

}

static void qspi_write(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	char *message;
	int errors = 0;
	int i, length;
	CLI_uint32_required( "length", &length );
	message  = pvPortMalloc(80);
	udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
	sprintf(message,"Qspi Write tests");
	dbg_str(message);
	message[0] = 0x01;
	message[1] = 0x03;
	message[2] = 0x07;
	message[3] = 0x0f;
	message[4] = 0x1f;
	message[5] = 0x3f;
	message[6] = 0x7f;
	message[7] = 0xff;
	message[8] = 0xfe;
	message[9] = 0xfc;
	message[10] = 0xf8;
	message[11] = 0xf0;
	message[12] = 0xe0;
	message[13] = 0xc0;
	message[14] = 0x80;
	message[15] = 0x00;
	udma_qspim_write(0, 0, length, message);
	udma_qspim_write(0, 1, length, message);
	udma_qspim_write(0, 2, length, message);
	udma_qspim_write(0, 3, length, message);
	vPortFree(message);
}

static void flash_peek(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	split_4Byte_t	xValue;
	split_4Byte_t    lExpVal;
	uint8_t 	lExpValTrueOrFalse = 0;
	uint32_t	lAddress = 0;
	uint8_t lMuxSelSaveBuf[8] = {0};
	uint8_t i = 0;

	xValue.w = 0;
	lExpVal.w = 0;

	if( gQSPIFlashPresentFlg == 1 )
	{
		for(i=0; i<8; i++ )
		{
			//Save pin muxes
			lMuxSelSaveBuf[i] = hal_getpinmux(13+i);
		}

		for(i=0; i<8; i++ )
		{
			//set pin muxes
			hal_setpinmux(13+i, 0);
		}

		CLI_uint32_required( "addr", &lAddress );

		if( CLI_is_more_args() ){
			lExpValTrueOrFalse = 1;
			CLI_uint32_required("exp", &lExpVal.w);
		}

		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		dbg_str("Qspi Flash Read\n");
		udma_flash_read(0, 0, lAddress, &xValue.b[0], 4);
		CLI_printf("0x%08x - [0x%02x]/[0x%02x]/[0x%02x]/[0x%02x]\n", xValue.w, xValue.b[0], xValue.b[1], xValue.b[2], xValue.b[3]);

		if( lExpValTrueOrFalse )
		{
			if( xValue.w == lExpVal.w )
			{
				CLI_printf("flash peek 0x%08x exp val = 0x%08x / read val = 0x%08x <<PASSED>>\n",lAddress, lExpVal.w, xValue.w);
			}
			else
			{
				CLI_printf("flash peek 0x%08x exp val = 0x%08x / read val = 0x%08x <<FAILED>>\n",lAddress, lExpVal.w, xValue.w);
			}
		}
		else
		{
			dbg_str("<<DONE>>\r\n");
		}

		//Restore pin muxes
		for(i=0; i<8; i++ )
		{
			//Save pin muxes
			 hal_setpinmux(13+i, lMuxSelSaveBuf[i]);
		}
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}

static void flash_poke(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	split_4Byte_t	xValue;
	uint32_t	lAddress = 0;
	uint8_t i = 0;
	uint8_t lMuxSelSaveBuf[8] = {0};

	xValue.w = 0;

	if( gQSPIFlashPresentFlg == 1 )
	{
		for(i=0; i<8; i++ )
		{
			//Save pin muxes
			lMuxSelSaveBuf[i] = hal_getpinmux(13+i);
		}

		for(i=0; i<8; i++ )
		{
			//set pin muxes
			hal_setpinmux(13+i, 0);
		}

		CLI_uint32_required( "addr", &lAddress );
		CLI_uint32_required( "value", &xValue.w);

		udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
		dbg_str("Qspi Flash write\n");
		udma_flash_write(0, 0, lAddress, &xValue.b[0], 4);

		dbg_str("<<DONE>>\r\n");

		//Restore pin muxes
		for(i=0; i<8; i++ )
		{
			//Save pin muxes
			 hal_setpinmux(13+i, lMuxSelSaveBuf[i]);
		}
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}

static void flash_quad_peek(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	split_4Byte_t	xValue;
	split_4Byte_t    lExpVal;
	//split_8Byte_t lLongVal;
	uint8_t 	lExpValTrueOrFalse = 0;
	uint32_t	lAddress = 0;
	uint8_t lMuxSelSaveBuf[8] = {0};
	uint8_t i = 0;

	xValue.w = 0;
	lExpVal.w = 0;
	//lLongVal.w = 0;
	if( gQSPIFlashPresentFlg == 1 )
	{
		if( gMicronFlashDetectedFlg == 1 )
		{
			if( gQuadModeSupportedFlg == 1 )
			{
				for(i=0; i<8; i++ )
				{
					//Save pin muxes
					lMuxSelSaveBuf[i] = hal_getpinmux(13+i);
				}

				for(i=0; i<8; i++ )
				{
					//set pin muxes
					hal_setpinmux(13+i, 0);
				}

				CLI_uint32_required( "addr", &lAddress );

				if( CLI_is_more_args() ){
					lExpValTrueOrFalse = 1;
					CLI_uint32_required("exp", &lExpVal.w);
				}

				dbg_str("Qspi Flash Read\n");
				//udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);

				//udma_flash_read(0, 0, lAddress, &xValue.b[0], 4);
				//udma_flash_read_quad(0, 0, lAddress, &xValue.b[0], 4);
				//if( flashRead_Micron(lAddress, &xValue.b[0], 4) == 0 )
				if( flashQuadOutputFastRead_Micron(lAddress, &xValue.b[0], 4) == 0 )
					CLI_printf("0x%08x - [0x%02x]/[0x%02x]/[0x%02x]/[0x%02x]\n", xValue.w, xValue.b[0], xValue.b[1], xValue.b[2], xValue.b[3]);
				else
					dbg_str("flashRead_Micron Error\n");

				if( lExpValTrueOrFalse )
				{
					if( xValue.w == lExpVal.w )
					{
						CLI_printf("flash qpeek 0x%08x exp val = 0x%08x / read val = 0x%08x <<PASSED>>\n",lAddress, lExpVal.w, xValue.w);
					}
					else
					{
						CLI_printf("flash qpeek 0x%08x exp val = 0x%08x / read val = 0x%08x <<FAILED>>\n",lAddress, lExpVal.w, xValue.w);
					}
				}
				else
				{
					dbg_str("qpeek <<DONE>>\r\n");
				}

				//Restore pin muxes
				for(i=0; i<8; i++ )
				{
					//Save pin muxes
					 hal_setpinmux(13+i, lMuxSelSaveBuf[i]);
				}
			}
			else
			{
				CLI_printf("FLASH DOES NOT SUPPORT QUAD MODE <<FAILED>>\n");
			}
		}
		else
		{
			CLI_printf("NON MICRON FLASH QUAD MODE NOT SUPPORTED <<FAILED>>\n");
		}
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}
uint8_t gBuf[32] = {0};

static void flash_quad_poke(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	split_4Byte_t	xValue;
	uint32_t	lAddress = 0;
	uint8_t i = 0;
	uint8_t lMuxSelSaveBuf[8] = {0};

	if( gQSPIFlashPresentFlg == 1 )
	{
		if( gMicronFlashDetectedFlg == 1 )
		{
			if( gQuadModeSupportedFlg == 1 )
			{
				for( i=0 ;i <32; i++ )
				{
					gBuf[i] = i;
				}
				xValue.w = 0;
				for(i=0; i<8; i++ )
				{
					//Save pin muxes
					lMuxSelSaveBuf[i] = hal_getpinmux(13+i);
				}

				for(i=0; i<8; i++ )
				{
					//set pin muxes
					hal_setpinmux(13+i, 0);
				}

				CLI_uint32_required( "addr", &lAddress );
				CLI_uint32_required( "value", &xValue.w);

				dbg_str("Qspi Flash write\n");
				//udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
				//udma_flash_write(0, 0, lAddress, &xValue.b[0], 4);

				//flashWrite_Micron(lAddress, &xValue.b[0], 4);
				flashQuadInputFastProgram_Micron(lAddress, &xValue.b[0], 4);
				//flashQuadInputFastProgram_Micron(0, gBuf, 32);
				dbg_str("qpoke <<DONE>>\r\n");

				//Restore pin muxes
				for(i=0; i<8; i++ )
				{
					//Save pin muxes
					 hal_setpinmux(13+i, lMuxSelSaveBuf[i]);
				}
			}
			else
			{
				CLI_printf("FLASH DOES NOT SUPPORT QUAD MODE <<FAILED>>\n");
			}
		}
		else
		{
			CLI_printf("NON MICRON FLASH QUAD MODE NOT SUPPORTED <<FAILED>>\n");
		}
	}
	else
	{
		CLI_printf("FLASH NOT PRESENT <<FAILED>>\n");
	}
}


