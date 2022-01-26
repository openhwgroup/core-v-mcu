/*
 * spi.c
 *
 *  Created on: May 18, 2021
 *      Author: gregmartin
 */


/*
 * Copyright 2021 QuickLogic
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
 */

#include <string.h>
#include <stdint.h>
#include <stdbool.h>


#include "core-v-mcu-config.h"


#include "udma_ctrl_reg_defs.h"
#include "udma_qspi_reg_defs.h"
#include "flash.h"
#include "udma_qspi_driver.h"




static uint8_t aucclkdiv;

uint16_t udma_qspim_open (uint8_t qspim_id, uint32_t clk_freq) {
	volatile UdmaCtrl_t*		pudma_ctrl = (UdmaCtrl_t*)UDMA_CH_ADDR_CTRL;
	UdmaQspi_t*					pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM + qspim_id * UDMA_CH_SIZE);
	uint32_t					clk_divisor;

	/* Enable reset and enable the spi clock */
	pudma_ctrl->reg_rst |= (UDMA_CTRL_QSPIM0_CLKEN << qspim_id);
	pudma_ctrl->reg_rst &= ~(UDMA_CTRL_QSPIM0_CLKEN << qspim_id);
	pudma_ctrl->reg_cg |= (UDMA_CTRL_QSPIM0_CLKEN << qspim_id);


	aucclkdiv = 5000000/clk_freq;

	return 0;
}



static uint32_t auccmd[16];
void udma_flash_readid(uint32_t l2addr) {
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM);
	uint32_t*	pcmd = auccmd;



		pqspim_regs->rx_cfg_b.en = 0;
		pqspim_regs->tx_cfg_b.en = 0;
		pqspim_regs->cmd_cfg_b.en = 0;

		*pcmd++ = kSPIm_Cfg | aucclkdiv;
		*pcmd++ = kSPIm_SOT;
		*pcmd++ = kSPIm_SendCmd | (0x7009f); // readid command
	//	*pcmd++ = kSPIm_SendCmd | (0xf0000) | ((flash_addr >> 8) & 0xffff);
	//	*pcmd++ = kSPIm_SendCmd | (0x70000) | (flash_addr && 0xff);
		*pcmd++ = kSPIm_RxData | (0x00470000 | (4-1)) ; // 4 words recieved
		*pcmd++ = kSPIm_EOT  | 1; // generate event

		pqspim_regs->rx_saddr = l2addr;
		pqspim_regs->rx_size = 4;
		pqspim_regs->rx_cfg_b.en = 1;

		pqspim_regs->cmd_saddr = (uint32_t)auccmd;
		pqspim_regs->cmd_size = (uint32_t)(pcmd - auccmd)*4;
		pqspim_regs->cmd_cfg_b.en = 1;

		while (pqspim_regs->rx_size != 0) {}
}
uint32_t udma_flash_reset_enable(uint8_t qspim_id, uint8_t cs)
{
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM + qspim_id * UDMA_CH_SIZE);
	uint32_t*	pcmd = auccmd;
	uint32_t result = 0;


	pqspim_regs->cmd_cfg_b.en = 0;

	pqspim_regs->cmd_cfg_b.clr = 1;

	*pcmd++ = kSPIm_Cfg | aucclkdiv;
	*pcmd++ = kSPIm_SOT | cs;
	*pcmd++ = kSPIm_SendCmd | (0x70066); // reset enable command
	*pcmd++ = kSPIm_EOT  | 1; // generate event

	pqspim_regs->cmd_saddr = (uint32_t)auccmd;
	pqspim_regs->cmd_size = (uint32_t)(pcmd - auccmd)*4;
	pqspim_regs->cmd_cfg_b.en = 1;

	return result;
}

uint32_t udma_flash_reset_memory(uint8_t qspim_id, uint8_t cs)
{
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM + qspim_id * UDMA_CH_SIZE);
	uint32_t*	pcmd = auccmd;
	uint32_t result = 0;


	pqspim_regs->cmd_cfg_b.en = 0;

	pqspim_regs->cmd_cfg_b.clr = 1;

	*pcmd++ = kSPIm_Cfg | aucclkdiv;
	*pcmd++ = kSPIm_SOT | cs;
	*pcmd++ = kSPIm_SendCmd | (0x70099); // reset memory command

	*pcmd++ = kSPIm_EOT  | 1; // generate event

	pqspim_regs->cmd_saddr = (uint32_t)auccmd;
	pqspim_regs->cmd_size = (uint32_t)(pcmd - auccmd)*4;
	pqspim_regs->cmd_cfg_b.en = 1;

	return result;
}
void udma_flash_read(uint32_t flash_addr,uint32_t l2addr,uint16_t read_len ) {
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM);
	uint32_t*	pcmd = auccmd;



		pqspim_regs->rx_cfg_b.en = 0;
		pqspim_regs->tx_cfg_b.en = 0;
		pqspim_regs->cmd_cfg_b.en = 0;

		*pcmd++ = kSPIm_Cfg | aucclkdiv;
		*pcmd++ = kSPIm_SOT;
		*pcmd++ = kSPIm_SendCmd | (0x70003);  // read command
		*pcmd++ = kSPIm_SendCmd | (0xf0000) | ((flash_addr >> 8) & 0xffff);
		*pcmd++ = kSPIm_SendCmd | (0x70000) | (flash_addr & 0xff);
		*pcmd++ = kSPIm_RxData | (0x00470000 | (read_len-1)) ; // 4 words recieved
		*pcmd++ = kSPIm_EOT  | 1; // generate event

		pqspim_regs->rx_saddr = l2addr;
		pqspim_regs->rx_size = read_len;
		pqspim_regs->rx_cfg_b.en = 1;

		pqspim_regs->cmd_saddr = (uint32_t)auccmd;
		pqspim_regs->cmd_size = (uint32_t)(pcmd - auccmd)*4;
		pqspim_regs->cmd_cfg_b.en = 1;

		while (pqspim_regs->rx_size != 0) {}
}
void udma_flash_write(uint32_t flash_addr, uint32_t l2addr,uint16_t write_len ) {
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM);
	uint32_t*	pcmd = auccmd;



		pqspim_regs->rx_cfg_b.en = 0;
		pqspim_regs->tx_cfg_b.en = 0;
		pqspim_regs->cmd_cfg_b.en = 0;

		*pcmd++ = kSPIm_Cfg | aucclkdiv;
		*pcmd++ = kSPIm_SOT;
		*pcmd++ = kSPIm_SendCmd | (0x70006);  // read command
		*pcmd++ = kSPIm_SendCmd | (0xf0000) | ((flash_addr >> 8) & 0xffff);
		*pcmd++ = kSPIm_SendCmd | (0x70000) | (flash_addr & 0xff);
		*pcmd++ = kSPIm_TxData | (0x00470000 | (write_len-1)) ; // 4 words recieved
		*pcmd++ = kSPIm_EOT  | 1; // generate event


		pqspim_regs->tx_saddr = l2addr;
		pqspim_regs->tx_size = write_len-1;
		pqspim_regs->tx_cfg_b.datasize = 2;
		pqspim_regs->tx_cfg_b.en = 1;

		pqspim_regs->cmd_saddr = (uint32_t)auccmd;
		pqspim_regs->cmd_size = (uint32_t)(pcmd - auccmd)*4;
		pqspim_regs->cmd_cfg_b.en = 1;

		while (pqspim_regs->rx_size != 0) {}
}


void udma_qspim_write (uint8_t qspim_id, uint8_t cs, uint16_t write_len, uint8_t *write_data) {
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM + qspim_id * UDMA_CH_SIZE);
	uint32_t*	pcmd = auccmd;
	uint32_t tmp_size;

		pqspim_regs->rx_cfg_b.clr = 1;
		pqspim_regs->tx_cfg_b.clr = 1;
		pqspim_regs->cmd_cfg_b.clr = 1;

		*pcmd++ = kSPIm_Cfg | aucclkdiv;
		*pcmd++ = kSPIm_SOT | cs;
		*pcmd++ = kSPIm_TxData | 0x0470000 | write_len -1;
		*pcmd++ = kSPIm_EOT | 1; // generate event


		pqspim_regs->tx_saddr = (uint32_t)write_data;
		pqspim_regs->tx_size = write_len-1;
		pqspim_regs->tx_cfg_b.datasize = 2;
		pqspim_regs->tx_cfg_b.en = 1;

		pqspim_regs->cmd_saddr = (uint32_t)auccmd;
		pqspim_regs->cmd_size = (uint32_t)(pcmd - auccmd)*4;
		pqspim_regs->cmd_cfg_b.en = 1;

}

