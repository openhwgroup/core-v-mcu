/*
 * Copyright 2020 ETH Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * Author: Robert Balas (balasr@iis.ee.ethz.ch)
 */

#include <stdint.h>
#include <assert.h>

#include <FreeRTOS.h>
#include "FreeRTOSConfig.h"

#include <target/core-v-mcu/include/core_pulp_cluster.h>
#include <target/core-v-mcu/include/core-v-mcu-config.h>

//#include "pmsis/implem/drivers/fc_event/fc_event.h"
#include "hal/include/hal_fc_event.h"
/* TODO: weird include */
#include "target/core-v-mcu/include/core-v-mcu-properties.h"
#include "hal/include/hal_irq.h"
#include "hal/include/hal_soc_eu.h"
#include "hal/include/hal_apb_soc_ctrl_reg_defs.h"

#include "drivers/include/udma_uart_driver.h"
#include "drivers/include/udma_i2cm_driver.h"
#include "drivers/include/udma_qspi_driver.h"

#include "../../app/N25Q_16Mb-1Gb_Device_Driver V2.1/N25Q.h"
#include "hal/include/hal_apb_i2cs.h"

FLASH_DEVICE_OBJECT gFlashDeviceObject;
uint8_t gQSPIFlashPresentFlg = 0;
uint8_t gMicronFlashDetectedFlg = 0;

/* test some assumptions we make about compiler settings */
static_assert(sizeof(uintptr_t) == 4,
	      "uintptr_t is not 4 bytes. Make sure you are using -mabi=ilp32*");

/* Allocate heap to special section. Note that we have no references in the
 * whole program to this variable (since its just here to allocate space in the
 * section for our heap), so when using LTO it will be removed. We force it to
 * stay with the "used" attribute
 */
__attribute__((section(".heap"), used)) uint8_t ucHeap[configTOTAL_HEAP_SIZE];

/* Inform linker script about .heap section size. Note: GNU ld seems to
 * internally represent integers with the bfd_vma type, that is a type that can
 * contain memory addresses (typdefd to some int type depending on the
 * architecture). uint32_t seems to me the most fitting candidate for rv32.
 */
uint32_t __heap_size = configTOTAL_HEAP_SIZE;

volatile uint32_t system_core_clock = DEFAULT_SYSTEM_CLOCK;

/* FreeRTOS task handling */
BaseType_t xTaskIncrementTick(void);
void vTaskSwitchContext(void);

/* interrupt handling */
void timer_irq_handler(uint32_t mcause);
void undefined_handler(uint32_t mcause);
extern void fc_soc_event_handler1 (uint32_t mcause);
void (*isr_table[32])(uint32_t);
void flash_readid (const struct cli_cmd_entry *pEntry);
/**
 * Board init code. Always call this before anything else.
 */

uint8_t setFLLFrequencyInIntegerMode(uint8_t aFLLNum, uint8_t aRefFreqInMHz, uint16_t aMultiplier, uint8_t aDivideRatio_R_Prescale, uint8_t aPS0_L1, uint8_t aPS0_L2  )
{
    uint8_t lSts = 0;
	volatile uint32_t *lPLLStartAddress = (uint32_t *)NULL;
    uint32_t lCounter = 0;
    uint32_t lCfgVal = 0;

    uint8_t lPS0_L1 = aPS0_L1 & 0x03;
    uint8_t lPS0_L2 = aPS0_L2 & 0xFF;

    if( aFLLNum == 0 )
        lPLLStartAddress = (uint32_t *)FLL1_START_ADDR;
    else if( aFLLNum == 1 )
        lPLLStartAddress = (uint32_t *)FLL2_START_ADDR;
    else if( aFLLNum == 2 )
        lPLLStartAddress = (uint32_t *)FLL3_START_ADDR;
    else
        lPLLStartAddress = (uint32_t *)NULL;

    if( lPLLStartAddress != NULL )
    {
	    if( ( aRefFreqInMHz >= 5 ) && ( aRefFreqInMHz <= 500 ) )
	    {
	        if( ( aMultiplier > 0 ) && ( aMultiplier < 2048 ) )
	        {
	            if( aDivideRatio_R_Prescale < 16 )
	            {
                    *lPLLStartAddress |= (1 << 19);//Bypass on;
                    *lPLLStartAddress |= (1 << 2);   //Reset high
                    *lPLLStartAddress &= ~(1 << 2) ;//Reset low;
                    *lPLLStartAddress &= ~(1 << 18); //PS0_EN is set to low
                    *lPLLStartAddress |= (lPS0_L1 << 0);   //PS0_L1 0 which gives L01 = 1
                    *lPLLStartAddress |= (lPS0_L2 << 4);   //PS0_L2_INT 0 and PS0_L2_FRAC 0 which gives L02 = 1
                    *lPLLStartAddress |= (0 << 12);   //PS0_L2_INT 0 and PS0_L2_FRAC 0 which gives L02 = 1


                    //FLL1 Config 1 register not configuring PS1
                    *(lPLLStartAddress + 1) = 0;

                    //FLL1 Config 2 register
                    lCfgVal = 0;
                    lCfgVal |= (aMultiplier << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz) Multiplier cannot hold 0
                    lCfgVal |= (1 << 27 ); //INTEGER_MODE is enabled
                    lCfgVal |= (aDivideRatio_R_Prescale << 28 ); //PRESCALE value (Divide Ratio R = 1)

                    *(lPLLStartAddress + 2) = lCfgVal;

                    //FLL1 Config 3 register not configuring SSC
                    *(lPLLStartAddress + 3) = 0;

                    //FLL1 Config 4 register
                    *(lPLLStartAddress + 4) = 0x64;

                    //FLL1 Config 5 register
                    *(lPLLStartAddress + 5) = 0x269;

                    *lPLLStartAddress |= (1<<2);   //Reset high
                    *lPLLStartAddress |= (1<<18); //PS0_EN;
                    //lCounter = 0;
                    while ( (*(lPLLStartAddress+4) & 0x80000000) == 0 )  //Wait for lock detect to go high
                    {
                        lCounter++;
                        if( lCounter >= 0x00010000)
                        {
                            lSts = 5;     //Unable to achieve lock
                            lCounter = 0;
                            break;
                        }
                    }
                    if( lSts == 0 )
                        *(lPLLStartAddress) &= ~(1<<19) ;//Bypass off;
                }
                else
                {
                    lSts = 1;   //aDivideRatio_R_Prescale
                }
            }
            else
            {
                lSts = 2;   //Invalid aMultiplier
            }
        }
        else
        {
            lSts = 3;   //Invalid reference freq
        }
    }
    else
    {
        lSts = 4;   //Invalid PLL number
    }
    return lSts;
}


int handler_count[32];
uint32_t gSpecialHandlingIRQCnt = 0;
void system_init(void)
{
	uint32_t lFlashID = 0;
	SocCtrl_t *soc=APB_SOC_CTRL_ADDR;
	soc->soft_reset = 1;
	uint32_t val = 0;
	timer_irq_disable();

	uint32_t *lFFL1StartAddress = (uint32_t *)FLL1_START_ADDR;
	uint32_t *lFFL2StartAddress = (uint32_t *)FLL2_START_ADDR;
	uint32_t *lFFL3StartAddress = (uint32_t *)FLL3_START_ADDR;

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

    setFLLFrequencyInIntegerMode(0, 10, 40, 1, 0, 1);   // 400

    setFLLFrequencyInIntegerMode(1, 10, 40, 1, 0, 2);   // 200

    setFLLFrequencyInIntegerMode(2, 10, 40, 1, 0, 4);   // 100

#if 0
	*(uint32_t*)0x1c000000 = 0x55667788;

	//FLL1 is connected to soc_clk_o.
	//FLL1 Config 0 register
	*lFFL1StartAddress |= (1<<19);//Bypass on;
	*lFFL1StartAddress |= (1<<2);   //Reset high
	*lFFL1StartAddress &= ~(1<<2) ;//Reset low;
	*lFFL1StartAddress |= 0;   //PS0_L1 0 which is / by 1
    *lFFL1StartAddress |= (1<<18); //PS0_EN;

    //FLL1 Config 1 register not configuring PS1
    *(lFFL1StartAddress + 1) = 0;

	//FLL1 Config 2 register
	*(lFFL1StartAddress + 2) |= (0x28 << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz)
	*(lFFL1StartAddress + 2)|= (1 << 27 ); //INTEGER_MODE is enabled
	*(lFFL1StartAddress + 2)|= (1 << 28 ); //PRESCALE value (Divide Ratio R = 1)

	//FLL1 Config 3 register not configuring SSC
	*(lFFL1StartAddress + 3) = 0;

	//FLL1 Config 4 register
	*(lFFL1StartAddress + 4) = 0x64;
	//FLL1 Config 5 register
	*(lFFL1StartAddress + 5) = 0x269;

	*lFFL1StartAddress |= (1<<2);   //Reset high
	while (!(*(lFFL1StartAddress+4)& 0x80000000)) ; //Wait for lock detect to go high

	*(lFFL1StartAddress) &= ~(1<<19) ;//Bypass off;
/*-------------------------------------------------------------------------*/
	//FLL2 is connected to peripheral clock per_clk_o.
	//FLL2 Config 0 register
	*lFFL2StartAddress |= (1<<19);//Bypass on;
	*lFFL2StartAddress |= (1<<2);   //Reset high
	*lFFL2StartAddress &= ~(1<<2) ;//Reset low;
	*lFFL2StartAddress |= 1;   //PS0_L1 1 which is / by 2
    *lFFL2StartAddress |= (1<<18); //PS0_EN;

    //FLL2 Config 1 register not configuring PS1
    *(lFFL2StartAddress + 1) = 0;

	//FLL2 Config 2 register
	*(lFFL2StartAddress + 2) |= (0x28 << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz)
	*(lFFL2StartAddress + 2)|= (1 << 27 ); //INTEGER_MODE is enabled
	*(lFFL2StartAddress + 2)|= (1 << 28 ); //PRESCALE value (Divide Ratio R = 1)

	//FLL2 Config 3 register not configuring SSC
	*(lFFL2StartAddress + 3) = 0;

	//FLL2 Config 4 register
	*(lFFL2StartAddress + 4) = 0x64;
	//FLL2 Config 5 register
	*(lFFL2StartAddress + 5) = 0x269;

	*lFFL2StartAddress |= (1<<2);   //Reset high
	while (!(*(lFFL2StartAddress+4)& 0x80000000)) ; //Wait for lock detect to go high

	*(lFFL2StartAddress) &= ~(1<<19) ;//Bypass off;

/*-------------------------------------------------------------------------*/
	//FLL3 is connected to cluster clock cluster_clk_o.
	//FLL3 Config 0 register
	*lFFL3StartAddress |= (1<<19);//Bypass on;
	*lFFL3StartAddress |= (1<<2);   //Reset high
	*lFFL3StartAddress &= ~(1<<2) ;//Reset low;
	*lFFL3StartAddress |= 2;   //PS0_L1 0 which is / by 4
    *lFFL3StartAddress |= (1<<18); //PS0_EN;

    //FLL3 Config 1 register not configuring PS1
    *(lFFL3StartAddress + 1) = 0;

	//FLL3 Config 2 register
	*(lFFL3StartAddress + 2) |= (0x28 << 4 ); //MULT_INT	0x28 = 40 (40*10 = 400MHz)
	*(lFFL3StartAddress + 2)|= (1 << 27 ); //INTEGER_MODE is enabled
	*(lFFL3StartAddress + 2)|= (1 << 28 ); //PRESCALE value (Divide Ratio R = 1)

	//FLL3 Config 3 register not configuring SSC
	*(lFFL3StartAddress + 3) = 0;

	//FLL3 Config 4 register
	*(lFFL3StartAddress + 4) = 0x64;
	//FLL3 Config 5 register
	*(lFFL3StartAddress + 5) = 0x269;

	*lFFL3StartAddress |= (1<<2);   //Reset high
	while (!(*(lFFL3StartAddress+4)& 0x80000000)) ; //Wait for lock detect to go high

	*(lFFL3StartAddress) &= ~(1<<19) ;//Bypass off;
#endif
#else
	#error "Enable any one of the PLL configurations FAKE_PLL or PERCEPTIA_PLL"
#endif

	/* init flls */
	//for (int i = 0; i < ARCHI_NB_FLL; i++) {
	//	pi_fll_init(i, 0);
	//}

	/* make sure irq (itc) is a good state */
//	irq_init();

	/* Hook up isr table. This table is temporary until we figure out how to
	 * do proper vectored interrupts.
	 */
for (int i = 0 ; i < 32 ; i ++){
	isr_table[i] = undefined_handler;
	handler_count[i] = 0;
}
	isr_table[0x7] = timer_irq_handler;
	isr_table[0xb] = (void(*)(uint32_t))fc_soc_event_handler1; // 11 for cv32

	/* mtvec is set in crt0.S */

	/* deactivate all soc events as they are enabled by default */
	pulp_soc_eu_event_init();

	/* Setup soc events handler. */
	//pi_fc_event_handler_init(FC_SOC_EVENT);
	pi_fc_event_handler_init(11);

	/* TODO: I$ enable*/
	/* enable core level interrupt (mie) */
	irq_clint_enable();

	val = csr_read(CSR_MIE);

	/* TODO: enable uart */
	for (uint8_t id = 0; id != N_UART; id++) {
		udma_uart_open(id, 115200);
	}
	for (uint8_t id = 0; id != N_I2CM; id++) {
		udma_i2cm_open(id, 400000);  //200000
	}
	udma_qspim_open(0,2500000);

	udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);

	lFlashID = udma_flash_readid(0,0);
	if( ( lFlashID == 0xFFFFFFFF ) || ( lFlashID == 0 ) )
	{
		gQSPIFlashPresentFlg = 0;
	}
	else
	{
		gQSPIFlashPresentFlg = 1;
		if( ( lFlashID & 0xFF ) == 0x20 )
		{
			gMicronFlashDetectedFlg = 1;
		}
		else
			gMicronFlashDetectedFlg = 0;
	}

	hal_set_apb_i2cs_slave_on_off(1);
	if( hal_get_apb_i2cs_slave_address() !=  MY_I2C_SLAVE_ADDRESS )
			hal_set_apb_i2cs_slave_address(MY_I2C_SLAVE_ADDRESS);

}

void system_core_clock_update(void)
{
	system_core_clock = pi_fll_get_frequency(FLL_SOC, 0);
}

void system_core_clock_get(void)
{
	system_core_clock_update();
	return ;
}

void timer_irq_handler(uint32_t mcause)
{
#warning requires critical section if interrupt nesting is used.
	if (xTaskIncrementTick() != 0) {
		vTaskSwitchContext();
	}
}

void undefined_handler(uint32_t mcause)
{
	uint32_t RegReadVal = 0;
#ifdef __PULP_USE_LIBC
	abort();
#else
//	taskDISABLE_INTERRUPTS();
//	for(;;);
	if( ( mcause == 18 ) || ( mcause == 19 ) || ( mcause == 31 ))
	{
		gSpecialHandlingIRQCnt++;
		if( gSpecialHandlingIRQCnt >= 20 )
		{
			RegReadVal = csr_read(CSR_MIE);
			if( ( RegReadVal & BIT(mcause) ) != 0 )	//Check if the event interrupt mask is open.
			{
				//close the event interrupt mask.
				csr_read_clear(CSR_MIE, BIT(mcause));
			}
		}
	}
	else
	{
		handler_count[mcause]++;
	}

#endif
}

void vPortSetupTimerInterrupt(void)
{
	extern int timer_irq_init(uint32_t ticks);

	/* No CLINT so use the PULP timer to generate the tick interrupt. */
	/* TODO: configKERNEL_INTERRUPT_PRIORITY - 1 ? */
	timer_irq_init(ARCHI_FPGA_FREQUENCY / configTICK_RATE_HZ);
	/* TODO: allow setting interrupt priority (to super high(?)) */
	//irq_enable(IRQ_FC_EVT_TIMER0_HI); // not needed as timer comes in irq7
//	irq_enable (IRQ_FC_EVT_SW7);  // enable MTIME
}

void vSystemIrqHandler(uint32_t mcause)
{
	uint32_t val = 0;
//	extern void (*isr_table[32])(uint32_t);
	isr_table[mcause & 0x1f](mcause & 0x1f);

}
