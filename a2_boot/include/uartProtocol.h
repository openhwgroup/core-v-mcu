/*
 * uartProtocol.h
 *
 *  Created on: 21-Jan-2022
 *      Author: somesh
 */

#ifndef __UART_PROTOCOL_H__
#define __UART_PROTOCOL_H__

#define UART_PROTOCOL_CONV_BUF_LEN 			512
#define UART_PROTOCOL_MEMORY_WRITE_BUF_LEN	256

typedef enum {
	UART0_PROTOCOL_STATE_IDLE = 0,
	UART0_PROTOCOL_GET_RECORD_TYPE,
	UART0_PROTOCOL_GET_COUNT,
	UART0_PROTOCOL_GET_DESTINATION_ADDRESS,
	UART0_PROTOCOL_GET_DATA,
	UART0_PROTOCOL_GET_CRC,
	UART0_PROTOCOL_GET_TERMINATION_CHARACTER,
}uart0ProtocolState_t;

void processUartProtocolFrames(void);
uint8_t sendUartProtocolFrame(uint8_t *aUartProtocolFrameBuf, uint8_t aFrameSize);
void parseUartProtocolFrame(uint8_t *aBuf, uint16_t aLen);
uint8_t sendUartBootMeFrame(void);
uint8_t sendUartOKorNotOKFrame(uint8_t aSts);

#endif /* __UART_PROTOCOL_H__ */
