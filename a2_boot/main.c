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
 *    File   : main.c
 *    Purpose: Bootloader implementation of Arnold 2 chip.
 *    If a SPI flash part is detected and the bootsel switch is set to 1,
 *    the bootloader loads the application image from it.
 *    If there is no SPI flash part detected or a bootsel switch is set to 0
 *    the bootloader waits for an external host to load the application image
 *    over I2C bus.
 *=========================================================*/

#include <stdio.h>
#include "core-v-mcu-config.h"
#include "apb_soc_ctrl_reg_defs.h"
#include <string.h>
#include "flash.h"
#include "dbg.h"
#include "hal_apb_i2cs.h"
#include "I2CProtocol.h"
#include "crc.h"

//#defines
#define PLP_L2_DATA      __attribute__((section(".ram")))
#define FLL_START_ADDR 0x1A100000

//Function prototypes
uint16_t udma_uart_open (uint8_t uart_id, uint32_t xbaudrate);
uint16_t udma_qspim_open (uint8_t qspim_id, uint32_t clk_freq);
void udma_flash_readid(uint32_t l2addr);
uint32_t udma_flash_reset_enable(uint8_t qspim_id, uint8_t cs);
uint32_t udma_flash_reset_memory(uint8_t qspim_id, uint8_t cs);
void udma_flash_read(uint32_t flash_addr,uint32_t l2addr,uint16_t read_len );
void dbg_str(const char *s);

__attribute__((noreturn)) void changeStack(boot_code_t *data, unsigned int entry, unsigned int stack);

extern uint8_t gStopUartMsgFlg;

PLP_L2_DATA static boot_code_t    bootCode;

static void load_section(boot_code_t *data, flash_v2_mem_area_t *area)
{
	unsigned int flash_addr = area->start;
	unsigned int area_addr = area->ptr;
	unsigned int size = area->size;
	unsigned int i = 0;
	unsigned int iterSize = 0;

	int isL2Section = area_addr >= 0x1C000000 && area_addr < 0x1D000000;

	for (i = 0; i < area->blocks; i++) // 4KB blocks
	{
		iterSize = data->blockSize;

		if (iterSize > size)
			iterSize = (size + 3) & 0xfffffffc;

		if (isL2Section)
		{
			udma_flash_read(flash_addr, area_addr, iterSize);
		}
		else
		{
			udma_flash_read(flash_addr, (unsigned int)(long)data->flashBuffer, iterSize);
			memcpy((void *)(long)area_addr, (void *)(long)data->flashBuffer, iterSize);
		}
		area_addr  += iterSize;
		flash_addr += iterSize;
		size       -= iterSize;
	}
}


static inline void __attribute__((noreturn)) jump_to_entry(flash_v2_header_t *header)
{
	//apb_soc_bootaddr_set(header->bootaddr);
	jump_to_address(header->entry);
	while(1);
}


static void getMemAreas(boot_code_t *data)
{
	int nbArea = 0;
	udma_flash_read(0, (unsigned int)(long)&data->header, sizeof(data->header));
	nbArea = data->header.nbAreas;
	if (nbArea >= MAX_NB_AREA)
	{
		nbArea = MAX_NB_AREA;
	}

	if (nbArea)
	{
		udma_flash_read(sizeof(flash_v2_header_t), (unsigned int)(long)data->memArea, nbArea*sizeof(flash_v2_mem_area_t));
	}
}

static __attribute__((noreturn)) void loadBinaryAndStart(boot_code_t *data)
{
	unsigned int i = 0;
	char string[32] = {0};

	getMemAreas(data);
	for (i=0; i<data->header.nbAreas; i++)
	{
		dbg_str("\nLoading Section ");
		dbg_hex32(i);
		dbg_str(" to ");
		dbg_hex32(data->memArea[i].ptr);
		load_section(data, &data->memArea[i]);
	}

	dbg_str("\nJumping to ");
	dbg_hex32(data->header.entry);
	dbg_str(" ");
	jump_to_entry(&data->header);
}

static __attribute__((noreturn)) void loadBinaryAndStart_newStack(boot_code_t *data)
{
	changeStack(data, (unsigned int)(long)loadBinaryAndStart, ((unsigned int)(long)data->stack) + BOOT_STACK_SIZE);
}

static boot_code_t *findDataFit(boot_code_t *data)
{
	unsigned int addr = 0x1c000000;
	unsigned int i = 0;
	flash_v2_mem_area_t *area = (flash_v2_mem_area_t *)NULL;
	for (i=0; i<data->header.nbAreas; i++)
	{
		area = &data->memArea[i];
		if ( (addr >= area->ptr && addr < area->ptr + area->size) ||
			 (addr < area->ptr && addr + sizeof(boot_code_t) > area->ptr) )
		{
			addr = ((area->ptr + area->size) + data->blockSize - 1) & ~(data->blockSize - 1);
		}
	}
	return (boot_code_t *)(long)addr;
}

static void bootFromRom(int hyperflash, int qpi)
{
	boot_code_t *data = &bootCode;
	boot_code_t *newData = (boot_code_t *)NULL;

	data->hyperflash = hyperflash;
	data->step = 0;
	if (hyperflash)
		data->blockSize = HYPER_FLASH_BLOCK_SIZE;
	else
		data->blockSize = FLASH_BLOCK_SIZE;

	data->qpi = qpi;

	getMemAreas(data);

	newData = findDataFit(data);
	newData->hyperflash = hyperflash;
	newData->qpi = qpi;
	if (hyperflash)
		newData->blockSize = HYPER_FLASH_BLOCK_SIZE;
	else
		newData->blockSize = FLASH_BLOCK_SIZE;

	loadBinaryAndStart_newStack(newData);

}

void setFLLInResetAndBypass(uint8_t aFLLNum)
{
	volatile uint32_t *lPLLStartAddress = (uint32_t *)NULL;
	if( aFLLNum <= 2 ) {
        lPLLStartAddress = (uint32_t *)(FLL_START_ADDR+(aFLLNum*32));
        *lPLLStartAddress |= (1 << 19);//Bypass on;
        *lPLLStartAddress &= ~(1 << 2) ;//Reset low;
    }
}

int main(void)
{
    uint8_t i = 0, flash_present = 0;
    uint32_t bootsel = 0;
    uint32_t lFlashID = 0;
	char tstring[8] = {0};
	volatile SocCtrl_t* psoc = (SocCtrl_t*)SOC_CTRL_START_ADDR;

	//TODO: FLL clock settings need to be taken care in the actual chip.
	//TODO: 5000000 to be changed to #define PERIPHERAL_CLOCK_FREQ_IN_HZ

	//Set soc clock, peripheral clock and cluster clock in reset and bypass mode.
    for (i=0;i<3;i++)
        setFLLInResetAndBypass(i);

	bootsel = psoc->bootsel & 0x1;	//This reads the bootsel pin status

	//Turn on the slave peripheral of Arnold 2.
	//Arnold 2 will be an I2C slave during the bootloader process from an external host.
	hal_set_apb_i2cs_slave_on_off(1);

	//Set the I2C slave ID which will be used by an external host to load the application code via I2C
	if( hal_get_apb_i2cs_slave_address() !=  MY_I2C_SLAVE_ADDRESS )
		hal_set_apb_i2cs_slave_address(MY_I2C_SLAVE_ADDRESS);

	udma_uart_open (1, 115200);	//UART 1 is used to print debug msgs from Bootloader
	dbg_str(__DATE__);
	dbg_str("  ");
	dbg_str(__TIME__);
	dbg_str("\nA2 Bootloader Bootsel=");

    if (bootsel == 1)
    	dbg_str("1 ");
	else
		dbg_str("0 ");

    //For verilator we do not have a SPI flash model.
    //So we jump directly to the app in verilator simulation
#ifdef VERILATOR
	dbg_str("\nJumping to address 0x1C000880");
	jump_to_address(0x1C000880);
#endif

	udma_qspim_open(0, 2500000);	//Open QSPI for reading app code from SPI flash
	udma_flash_reset_enable(0, 0);

	udma_flash_reset_memory(0, 0);

	udma_flash_readid(lFlashID);		//Read the ID of the flash connected

	if ( (lFlashID & 0xFF) != 0xFF )	//If a flash is connected it will respond with a non 0xFF LSB
		flash_present = 1;
	else
		flash_present = 0;	//If a flash is not connected it will respond with 0xFF

	if (bootsel == 0)
		tstring[0] = '.';	//. will be printed indicating that bootsel = 0
	else if (flash_present == 0)
		tstring[0] = '!';

	tstring[1] = 0;

	if ((bootsel == 1) && (flash_present == 1))
	{
		//load the app code from SPI flash to RAM and boot from it
		bootFromRom(0,0);
	}
	else	//No flash detected or the bootsel is 0
	{
		//An external host can connect and load the application code via I2C bus.
		crcInit();		//Initialize CRC calculator used in I2C bootloader
		bootsel = 0;	//Reusing bootsel variable as a counter

		if( psoc->reset_reason == 1 )	//1 = POR
		{
			hal_set_i2cs_msg_apb_i2c(A2_RESET_REASON_POR);
		}
		else if( psoc->reset_reason & 0x02 )	//3 = WDT
		{
			hal_set_i2cs_msg_apb_i2c(A2_RESET_REASON_WDT);
		}

		psoc->jtagreg = 1;
		while (1) {
			if (psoc->jtagreg != 0x1)
				jump_to_address(0x1C008080);
			//Perform I2C bootloader functionality
			processI2CProtocolFrames();
			bootsel++;		//Reusing bootsel variable as a counter
			if( bootsel >= 500000 )
			{
				if( gStopUartMsgFlg == 0 )	//Flag to control the continuous print of characters
					dbg_str(tstring);
				bootsel = 0;
			}
		}
	}
}
