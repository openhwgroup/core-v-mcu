/*
 * uartProtocol.c
 *
 *  Created on: 21-Jan-2022
 *      Author: somesh
 */


#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "hal_apb_i2cs.h"
#include "bootloader.h"
#include "uartProtocol.h"
#include "crc.h"
#include "dbg.h"

extern uint8_t gStopUartMsgFlg;
extern uint8_t gStopI2CBootLoaderFlg;

//All the global variables are initialized to 0 by the assembly code in crto.s.
//So not initializing it here.

uint8_t gStopUartBootLoaderFlg;

static uint8_t gsUartProtocolConvToHexBuf[UART_PROTOCOL_CONV_BUF_LEN];
static uint8_t gsMemoryWriteBuf[UART_PROTOCOL_MEMORY_WRITE_BUF_LEN];


static uint16_t gsUart0FillIndex;
static uint8_t gsUart0ProtocolState;
static uint8_t gsSRecordType;
static uint32_t gsDestinationAddress;
static uint16_t gsDestinationAddressSizeInBytes;
static uint16_t gsTotalCountInBytes;
static uint16_t gsDataCountInBytes;
static uint16_t gsMemoryWriteBufIndex;
static uint16_t gsDataRxdCounterInCharacters;
static uint8_t gsCRCVal;
static uint16_t gsCalculatedChkSum;

uint32_t atoh(uint8_t *aBuf, uint16_t aSize);
uint16_t udma_uart_writeraw(uint8_t uart_id, uint16_t write_len, uint8_t* write_buffer);
uint8_t udma_uart_readraw(uint8_t uart_id, uint16_t read_len, uint8_t* read_buffer);


void processUartProtocolFrames(void)
{
	uint8_t i = 0;
	uint8_t *lDestinationPtr = (uint8_t *)NULL;
	uint8_t lChar = 0;
	//State machine to process incoming uart frames.
	switch( gsUart0ProtocolState )
	{
		case UART0_PROTOCOL_STATE_IDLE:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				if( lChar == 'S')
				{
					gsUart0ProtocolState = UART0_PROTOCOL_GET_RECORD_TYPE;
					if( gStopUartMsgFlg == 0 )
						gStopUartMsgFlg = 1;
					if( gStopI2CBootLoaderFlg == 0 )
						gStopI2CBootLoaderFlg = 1;
				}
			}
			break;
		case UART0_PROTOCOL_GET_RECORD_TYPE:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				gsSRecordType = lChar;
				if( gsSRecordType == '0')
				{
					gsDestinationAddressSizeInBytes = 2;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '1')
				{
					gsDestinationAddressSizeInBytes = 2;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '2' )
				{
					gsDestinationAddressSizeInBytes = 3;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '3')
				{
					gsDestinationAddressSizeInBytes = 4;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '5' )
				{
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '7' )
				{
					gsDestinationAddressSizeInBytes = 4;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '8')
				{
					gsDestinationAddressSizeInBytes = 3;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else if( gsSRecordType == '9' )
				{
					gsDestinationAddressSizeInBytes = 2;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_COUNT;
					gsUart0FillIndex = 0;
					gsCalculatedChkSum = 0;
				}
				else
				{
					//Unknown record type received, handle it
				}
			}
			break;
		case UART0_PROTOCOL_GET_COUNT:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				gsUartProtocolConvToHexBuf[gsUart0FillIndex] = lChar;
				gsUart0FillIndex++;
				if( gsUart0FillIndex >= 2 )
				{
					gsUartProtocolConvToHexBuf[gsUart0FillIndex++] = 0;
					gsTotalCountInBytes = atoh(gsUartProtocolConvToHexBuf, gsUart0FillIndex);
					gsDataCountInBytes = gsTotalCountInBytes - gsDestinationAddressSizeInBytes - 1; // 1 for CRC
					gsUart0FillIndex = 0;
					gsCalculatedChkSum += gsTotalCountInBytes;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_DESTINATION_ADDRESS;
				}
			}
			break;
		case UART0_PROTOCOL_GET_DESTINATION_ADDRESS:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				gsUartProtocolConvToHexBuf[gsUart0FillIndex] = lChar;
				gsUart0FillIndex++;
				if( gsUart0FillIndex >= (2 * gsDestinationAddressSizeInBytes) )
				{
					gsUartProtocolConvToHexBuf[gsUart0FillIndex++] = 0;
					gsDestinationAddress = atoh(gsUartProtocolConvToHexBuf, gsUart0FillIndex);
					gsCalculatedChkSum += (gsDestinationAddress & 0xFF);
					gsCalculatedChkSum += ( (gsDestinationAddress & 0xFF00) >> 8 );
					gsCalculatedChkSum += ( (gsDestinationAddress & 0xFF0000) >> 16 );
					gsCalculatedChkSum += ( (gsDestinationAddress & 0xFF000000) >> 24 );
					gsUart0FillIndex = 0;
					gsDataRxdCounterInCharacters = 0;
					gsMemoryWriteBufIndex = 0;

					if( ( gsSRecordType == '0') || ( gsSRecordType == '1') || ( gsSRecordType == '2') || (gsSRecordType == '3' ) )
						gsUart0ProtocolState = UART0_PROTOCOL_GET_DATA;
					else if( ( gsSRecordType == '7') || ( gsSRecordType == '8') || (gsSRecordType == '9' ) )
						gsUart0ProtocolState = UART0_PROTOCOL_GET_CRC;
				}
			}
			break;
		case UART0_PROTOCOL_GET_DATA:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				gsUartProtocolConvToHexBuf[gsUart0FillIndex] = lChar;
				gsUart0FillIndex++;
				if( gsUart0FillIndex == 2 )
				{
					gsUartProtocolConvToHexBuf[gsUart0FillIndex++] = 0;
					gsMemoryWriteBuf[gsMemoryWriteBufIndex++] = atoh(gsUartProtocolConvToHexBuf, gsUart0FillIndex);
					gsUart0FillIndex = 0;
				}
				gsDataRxdCounterInCharacters++;
				if( gsDataRxdCounterInCharacters >= (2 * gsDataCountInBytes) )
				{
					for( i=0; i<gsMemoryWriteBufIndex; i++)
						gsCalculatedChkSum += gsMemoryWriteBuf[i];	//Add: Add each byte

					gsUart0FillIndex = 0;
					gsDataRxdCounterInCharacters = 0;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_CRC;
				}
			}
			break;
		case UART0_PROTOCOL_GET_CRC:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				gsUartProtocolConvToHexBuf[gsUart0FillIndex] = lChar;
				gsUart0FillIndex++;
				if( gsUart0FillIndex >= 2 )
				{
					gsUartProtocolConvToHexBuf[gsUart0FillIndex++] = 0;
					gsCRCVal = atoh(gsUartProtocolConvToHexBuf, gsUart0FillIndex);

					gsCalculatedChkSum &= 0xFF;	//Mask: Discard the most significant byte
					gsCalculatedChkSum ^= 0xFF; //Complement: Compute the ones' complement of the LSB

					if( gsCalculatedChkSum == gsCRCVal )
					{
						if( gsDestinationAddress != 0 )
						{
							if( ( gsSRecordType == '1') || ( gsSRecordType == '2') || (gsSRecordType == '3' ) )
							{
								memcpy( (void *)(long)gsDestinationAddress, (void *)(long)gsMemoryWriteBuf, gsMemoryWriteBufIndex);
							}
							else if( ( gsSRecordType == '7') || ( gsSRecordType == '8') || (gsSRecordType == '9' ) )
							{
								dbg_str("\nUART BL JMP ");
								dbg_hex32(gsDestinationAddress);
								dbg_str(" ");
								jump_to_address(gsDestinationAddress);
							}
						}
						else
						{
							//It could be a S0 frame, do nothing.
						}
						sendUartOKorNotOKFrame(1);
					}
					else
					{
						dbg_str("\nCHKSUM ERR ");
						dbg_hex8(gsCalculatedChkSum);
						dbg_hex8(gsCRCVal);
						sendUartOKorNotOKFrame(0);
					}
					gsUart0FillIndex = 0;
					gsMemoryWriteBufIndex = 0;
					gsUart0ProtocolState = UART0_PROTOCOL_GET_TERMINATION_CHARACTER;
				}
			}
			break;
		case UART0_PROTOCOL_GET_TERMINATION_CHARACTER:
			if( udma_uart_readraw(0,1,&lChar) == 1 )
			{
				if( (lChar == 0x0D ) || ( lChar ==  0x0A ) )
				{
					//?
				}
				//Reset all variables and jump to idle state
				gsSRecordType = 0;
				gsDestinationAddress = 0;
				gsDataRxdCounterInCharacters = 0;
				gsDestinationAddressSizeInBytes = 0;
				gsCalculatedChkSum = 0;
				gsCRCVal = 0;
				gsUart0FillIndex = 0;
				gsMemoryWriteBufIndex = 0;
				gsTotalCountInBytes = 0;
				gsUart0ProtocolState = UART0_PROTOCOL_STATE_IDLE;

			}
			break;

		default :
			break;
	}
}

uint8_t sendUartProtocolFrame(uint8_t *aUartProtocolFrameBuf, uint8_t aFrameSize)
{
	uint8_t lChar = 0;
	uint8_t i = 0;

	if( aUartProtocolFrameBuf )
	{
		for(i=0; i<aFrameSize; i++)
		{
			lChar = aUartProtocolFrameBuf[i];
			udma_uart_writeraw(0,1,&lChar);
		}
	}
	return i;

}

void parseUartProtocolFrame(uint8_t *aBuf, uint16_t aLen)
{
	if( gStopUartMsgFlg == 0 )
		gStopUartMsgFlg = 1;
	if( gStopI2CBootLoaderFlg == 0 )
		gStopI2CBootLoaderFlg = 1;
	dbg_str(aBuf);
	sendUartOKorNotOKFrame(1);
}

uint8_t sendUartBootMeFrame(void)
{
    uint8_t lFrameLen = 0;

    lFrameLen = sendUartProtocolFrame("A2 BOOTME\r\n", 11);
	return lFrameLen;
}

uint8_t sendUartOKorNotOKFrame(uint8_t aSts)
{
    uint8_t lFrameLen = 0;

    if( aSts == 1 )
    	lFrameLen = sendUartProtocolFrame("OK\r\n", 4);
    else if( aSts == 0 )
    	lFrameLen = sendUartProtocolFrame("NOT OK\r\n", 8);
	return lFrameLen;
}
