/*
 ============================================================================
 Name        : main.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello RISC-V World in C
 ============================================================================
 */

#include <stdio.h>

/*
 * Demonstrate how to print a greeting message on standard output
 * and exit.
 *
 * WARNING: This is a build-only project. Do not try to run it on a
 * physical board, since it lacks the device specific startup.
 *
 * If semihosting is not available, use `--specs=nosys.specs` during link.
 */
#include "core-v-mcu-config.h"
#include "apb_soc_ctrl_reg_defs.h"
#include <string.h>
#include "flash.h"
#include "dbg.h"
#include "hal_apb_i2cs.h"
#include "I2CProtocol.h"
#include "crc.h"


#define FAKE_PLL		0
#define PERCEPTIA_PLL	1

#define FLL1_START_ADDR 0x1A100000
#define FLL2_START_ADDR 0x1A100020
#define FLL3_START_ADDR 0x1A100040

uint16_t udma_uart_open (uint8_t uart_id, uint32_t xbaudrate);
uint16_t udma_uart_writeraw(uint8_t uart_id, uint16_t write_len, uint8_t* write_buffer) ;
extern uint8_t gStopUartMsgFlg;

#define PLP_L2_DATA      __attribute__((section(".ram")))

PLP_L2_DATA static boot_code_t    bootCode;

static void load_section(boot_code_t *data, flash_v2_mem_area_t *area) {
  unsigned int flash_addr = area->start;
  unsigned int area_addr = area->ptr;
  unsigned int size = area->size;
  unsigned int i;

  int isL2Section = area_addr >= 0x1C000000 && area_addr < 0x1D000000;

  for (i = 0; i < area->blocks; i++) { // 4KB blocks

    unsigned int iterSize = data->blockSize;
    if (iterSize > size) iterSize = (size + 3) & 0xfffffffc;

    if (isL2Section) {
      udma_flash_read(flash_addr, area_addr, iterSize);
    } else {
      udma_flash_read(flash_addr, (unsigned int)(long)data->flashBuffer, iterSize);
      memcpy((void *)(long)area_addr, (void *)(long)data->flashBuffer, iterSize);
    }

    area_addr  += iterSize;
    flash_addr += iterSize;
    size       -= iterSize;
  }

}



static inline void __attribute__((noreturn)) jump_to_entry(flash_v2_header_t *header) {

  //apb_soc_bootaddr_set(header->bootaddr);
  jump_to_address(header->entry);
  while(1);
}

__attribute__((noreturn)) void changeStack(boot_code_t *data, unsigned int entry, unsigned int stack);

static void getMemAreas(boot_code_t *data)
{
	udma_flash_read(0, (unsigned int)(long)&data->header, sizeof(data->header));
  int nbArea = data->header.nbAreas;
  if (nbArea >= MAX_NB_AREA) {
    nbArea = MAX_NB_AREA;
  }

  if (nbArea)
  {
	  udma_flash_read(sizeof(flash_v2_header_t), (unsigned int)(long)data->memArea, nbArea*sizeof(flash_v2_mem_area_t));
  }
}

static __attribute__((noreturn)) void loadBinaryAndStart(boot_code_t *data)
{

  getMemAreas(data);

  unsigned int i;
  for (i=0; i<data->header.nbAreas; i++) {
	char string[32];
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
  unsigned int i;

  for (i=0; i<data->header.nbAreas; i++) {
    flash_v2_mem_area_t *area = &data->memArea[i];
    if ((addr >= area->ptr && addr < area->ptr + area->size)
      || (addr < area->ptr && addr + sizeof(boot_code_t) > area->ptr)) {
	addr = ((area->ptr + area->size) + data->blockSize - 1) & ~(data->blockSize - 1);
      }
  }
  return (boot_code_t *)(long)addr;
}

static void bootFromRom(int hyperflash, int qpi)
{
  boot_code_t *data = &bootCode;

  data->hyperflash = hyperflash;
  data->step = 0;
  if (hyperflash) data->blockSize = HYPER_FLASH_BLOCK_SIZE;
  else data->blockSize = FLASH_BLOCK_SIZE;
  data->qpi = qpi;

  getMemAreas(data);

  boot_code_t *newData = findDataFit(data);
  newData->hyperflash = hyperflash;
  newData->qpi = qpi;
  if (hyperflash) newData->blockSize = HYPER_FLASH_BLOCK_SIZE;
  else newData->blockSize = FLASH_BLOCK_SIZE;

  loadBinaryAndStart_newStack(newData);

}



int main(void)
{
	int id = 1, i = 0;
	unsigned int bootsel, flash_present;
	char tstring[8];
	uint32_t lCfgVal = 0;
	volatile uint32_t *lFFL1StartAddress = (uint32_t *)FLL1_START_ADDR;
	volatile uint32_t *lFFL2StartAddress = (uint32_t *)FLL2_START_ADDR;
	volatile uint32_t *lFFL3StartAddress = (uint32_t *)FLL3_START_ADDR;

#if FAKE_PLL == 1
	//FLL1 is connected to soc_clk_o. Run at reference clock, use by pass.
	//FLL1 Config 0 register
	*lFFL1StartAddress = 0;
	//FLL1 Config 1 register
	*(lFFL1StartAddress + 1) = 0x0000000C;	//Already this is the default value set in HW.
	//FLL1 Config 2 register
	*(lFFL1StartAddress + 2) = 0;
	//FLL1 Config 3 register
	*(lFFL1StartAddress + 3) = 0;


	//FLL2 is connected to peripheral clock. Run at half of reference clock. Set the divisor to 0 and disable bypass
	//FLL2 Config 0 register
	*lFFL2StartAddress = 0;		//Set divisor to half of reference clock.
	//FLL2 Config 1 register
	*(lFFL2StartAddress + 1) = 0;	//Disable bypass.
	//FLL2 Config 2 register
	*(lFFL2StartAddress + 2) = 0;
	//FLL2 Config 3 register
	*(lFFL2StartAddress + 3) = 0;

	//FLL3 is connected to Cluster clock. Run at quarter of reference clock. Set the divisor to 1 and disable bypass
	//FLL3 Config 0 register
	*lFFL3StartAddress = 0x00000010;	//Set divisor to quarter of reference clock.
	//FLL3 Config 1 register
	*(lFFL3StartAddress + 1) = 0;	//Disable bypass.
	//FLL3 Config 2 register
	*(lFFL3StartAddress + 2) = 0;
	//FLL3 Config 3 register
	*(lFFL3StartAddress + 3) = 0;

#elif (PERCEPTIA_PLL == 1 )

	*(uint32_t*)0x1c000000 = 0x55667788;

	//FLL1 is connected to soc_clk_o. Run at reference clock, use by pass.
	//FLL1 Config 0 register
	*(lFFL1StartAddress + 1) = 4;//Bypass on;
	*lFFL1StartAddress = 4;   //Reset high
	*lFFL1StartAddress = 0;   //PS0_L1 Cfg[1:0] = 00; PS0_L2 Cfg [11:4] =0

	//FLL1 Config 2 register
	*(lFFL1StartAddress + 2) = 0x64;
	//FLL1 Config 3 register
	*(lFFL1StartAddress + 3) = 0x269;

	//FLL1 Config 1 register
	lCfgVal = 4; // bypass
	lCfgVal |= (1 << 0 ); //PS0_EN
	lCfgVal |= (0x28 << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz)
	lCfgVal |= (1 << 27 ); //INTEGER_MODE is enabled
	lCfgVal |= (1 << 28 ); //PRESCALE value (Divide Ratio R = 1)
	*(lFFL1StartAddress + 1) = lCfgVal;
	
	*lFFL1StartAddress = 4;   // release reset
	while (!(*(lFFL1StartAddress+2)& 0x80000000)) ;

	*(lFFL1StartAddress + 1) &= ~(0x4) ;//Bypass off;
/*-------------------------------------------------------------------------*/
	//FLL2 Config 0 register
	*(lFFL2StartAddress + 1) = 4;//Bypass on;
	*lFFL2StartAddress = 4;   //Reset high
	*lFFL2StartAddress = 0;   //Reset Low
	*lFFL2StartAddress |= 1;   //PS0_L1 1 which is /2

	//FLL2 Config 2 register
	*(lFFL2StartAddress + 2) = 0x64;
	//FLL2 Config 3 register
	*(lFFL2StartAddress + 3) = 0x269;

	//FLL2 Config 1 register
	lCfgVal = 4; // bypass
	lCfgVal |= (1 << 0 ); //PS0_EN
	lCfgVal |= (0x28 << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz)
	lCfgVal |= (1 << 27 ); //INTEGER_MODE is enabled
	lCfgVal |= (1 << 28 ); //PRESCALE value (Divide Ratio R = 1)
	*(lFFL2StartAddress + 1) = lCfgVal;
	
	*lFFL2StartAddress |= 1<<2;   // release reset
	while (!(*(lFFL2StartAddress+2)& 0x80000000)) ;

	*(lFFL2StartAddress + 1) &= ~(0x4) ;//Bypass off;

/*-------------------------------------------------------------------------*/
	//FLL3 Config 0 register
	*(lFFL3StartAddress + 1) = 4;//Bypass on;
	*lFFL3StartAddress = 4;   //Reset high
	*lFFL3StartAddress = 0;   //Reset Low
	*lFFL3StartAddress |= 2;   //PS0_L1 2 which is /4

	//FLL3 Config 2 register
	*(lFFL3StartAddress + 2) = 0x64;
	//FLL3 Config 3 register
	*(lFFL3StartAddress + 3) = 0x269;

	//FLL3 Config 1 register
	lCfgVal = 4; // bypass
	lCfgVal |= (1 << 0 ); //PS0_EN
	lCfgVal |= (0x28 << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz)
	lCfgVal |= (1 << 27 ); //INTEGER_MODE is enabled
	lCfgVal |= (1 << 28 ); //PRESCALE value (Divide Ratio R = 1)
	*(lFFL3StartAddress + 1) = lCfgVal;
	
	*lFFL3StartAddress |= 1<<2;   // release reset
	while (!(*(lFFL3StartAddress+2)& 0x80000000)) ;

	*(lFFL3StartAddress + 1) &= ~(0x4) ;//Bypass off;

#else
	#error "Enable any one of the PLL configurations FAKE_PLL or PERCEPTIA_PLL"
#endif
	//TODO: FLL clock settings need to be taken care in the actual chip.
	//TODO: 5000000 to be changed to #define PERIPHERAL_CLOCK_FREQ_IN_HZ
	volatile SocCtrl_t* psoc = (SocCtrl_t*)SOC_CTRL_START_ADDR;
	bootsel = *(volatile int*)0x1c010000;
	bootsel = psoc->bootsel & 0x1;

	hal_set_apb_i2cs_slave_on_off(1);
	if( hal_get_apb_i2cs_slave_address() !=  MY_I2C_SLAVE_ADDRESS )
			hal_set_apb_i2cs_slave_address(MY_I2C_SLAVE_ADDRESS);

	udma_uart_open (id,115200);
	dbg_str(__DATE__);
	dbg_str("  ");
	dbg_str(__TIME__);
	dbg_str("\nA2 Bootloader Bootsel=");

	if (bootsel == 1) dbg_str("1");
	else dbg_str("0");
#ifdef VERILATOR
	dbg_str("\nJumping to address 0x1C000880");
	jump_to_address(0x1C000880);
#endif

	udma_qspim_open(0, 2500000);
	udma_flash_reset_enable(0, 0);
	//for (i = 0; i < 10000; i++);
	udma_flash_reset_memory(0, 0);
	//for (i = 0; i < 10000; i++);
	udma_flash_readid(tstring);
	if (tstring[0] != 0xFF) flash_present = 1;
	else flash_present = 0;
	if (bootsel == 0)
	 tstring[0] = '.';
	else if (flash_present == 0)
	 tstring[0] = '!';
	tstring[1] = 0;
	if ((bootsel == 1) && (flash_present == 1)) { //boot from SPI flash
	 bootFromRom(0,0);
	}
	else
	{
		/*
		 * Compute the CRC of the test message, more efficiently.
		 */
		crcInit();
		bootsel = 0;
		//TODO: Send a single byte message indicating the reset type. POR / Button reset / WDT
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
			processI2CProtocolFrames();
			bootsel++;
			//for (bootsel = 0; bootsel < 1000000; bootsel++);
			if( bootsel >= 500000 )
			{
				if( gStopUartMsgFlg == 0 )
					dbg_str(tstring);
				bootsel = 0;
			}
		}
	}
}
