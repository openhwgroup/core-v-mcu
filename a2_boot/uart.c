/*
 * uart.c
 *
 *  Created on: Apr 21, 2021
 *      Author: gregmartin
 */

#include "core-v-mcu-config.h"
#include "udma_ctrl_reg_defs.h"
#include "udma_uart_reg_defs.h"

#define UART_LOOP_COUNTER_BREAK_VAL 	(0x800)
#define UART_STATUS_TIMEOUT				(3)

uint16_t udma_uart_open (uint8_t uart_id, uint32_t xbaudrate) {
	UdmaUart_t*				puart;
	volatile UdmaCtrl_t*		pudma_ctrl = (UdmaCtrl_t*)UDMA_CH_ADDR_CTRL;

	/* Enable reset and enable uart clock */
	pudma_ctrl->reg_rst |= (UDMA_CTRL_UART0_CLKEN << uart_id);
	pudma_ctrl->reg_rst &= ~(UDMA_CTRL_UART0_CLKEN << uart_id);
	pudma_ctrl->reg_cg |= (UDMA_CTRL_UART0_CLKEN << uart_id);


	/* configure */
	puart = (UdmaUart_t*)(UDMA_CH_ADDR_UART + uart_id * UDMA_CH_SIZE);
	puart->uart_setup_b.div = (uint16_t)(5000000/xbaudrate);
	puart->uart_setup_b.bits = 3; // 8-bits
	puart->uart_setup_b.rx_polling_en = 1;
	puart->uart_setup_b.en_tx = 1;
	puart->uart_setup_b.en_rx = 1;

	return 0;
}

uint16_t udma_uart_writeraw(uint8_t uart_id, uint16_t write_len, uint8_t* write_buffer)
{
	UdmaUart_t*				puart = (UdmaUart_t*)(UDMA_CH_ADDR_UART + uart_id * UDMA_CH_SIZE);
	int i = 0;
	while (puart->tx_size != 0) {
		i++;
	}

	puart->tx_saddr = (uint32_t)write_buffer;
	puart->tx_size = write_len;
	puart->tx_cfg_b.en = 1; //enable the transfer
	while (puart->tx_size != 0) {
		i++;
	}

	return i;
}

uint8_t udma_uart_readraw(uint8_t uart_id, uint16_t read_len, uint8_t* read_buffer)
{
	uint8_t lSts = 0;
	UdmaUart_t *puart = (UdmaUart_t*)(UDMA_CH_ADDR_UART + uart_id * UDMA_CH_SIZE);

	if( puart->valid_b.rx_data_valid == 1 )
	{
		*read_buffer = puart->data_b.rx_data;
		lSts = 1;
	}
	return lSts;
}
