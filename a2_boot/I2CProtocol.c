#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "hal_apb_i2cs.h"
#include "I2CProtocol.h"
#include "crc.h"
#include "dbg.h"

uint8_t gStopUartMsgFlg = 0;
uint8_t gsI2CProtocolFrameRxBuf[256] = {0};


static uint8_t gsI2CProtocolFrameTxBuf[16] = {0};
static uint16_t gsI2CProtocolFrameCounter = 0;

uint16_t I2CProtocolFrameCalChksum(uint8_t *cbuf, uint16_t pkt_size)
{
	uint16_t lCRC = 0;
    lCRC = (uint16_t)crcFast(cbuf, pkt_size);
    return lCRC;
}

uint8_t formI2CProtocolFrame(uint8_t *aBuf, uint8_t aBufSize, uint8_t aCmdType, uint8_t *aData, uint8_t aDataLen)
{
	uint8_t i = 0;
	uint16_t ui16Crc = 0;
	I2CProtocolFrame_t *lFillPtr = (I2CProtocolFrame_t *)aBuf;
	if( aDataLen <= I2C_PROTOCOL_MAX_PAYLOAD_SIZE )
	{
		lFillPtr->SOF = A2_TO_HOST_FRAME_HEADER;
		lFillPtr->CmdType = aCmdType;
		lFillPtr->DataLen = aDataLen;
		for( i=0; i<aDataLen; i++)
		{
			if( aData )
			{
				lFillPtr->Data[i] = aData[i];
			}
		}

		ui16Crc = I2CProtocolFrameCalChksum(aBuf, i+I2C_PROTOCOL_FRAME_HEADER_SIZE);
		lFillPtr->Data[i++] = (uint8_t)(ui16Crc >> 8 );
		lFillPtr->Data[i++] = (uint8_t)ui16Crc;
		return i + I2C_PROTOCOL_FRAME_HEADER_SIZE;
	}
	return 0;
}

uint8_t sendI2CProtocolFrame(uint8_t *aI2CProtocolFrameBuf, uint8_t aFrameSize)
{
	uint8_t i = 0;
	uint8_t lFrameSize = 0;
	uint8_t *lI2CProtocolFramePtr = (uint8_t *)NULL;
	static uint8_t lastSentFrameSize = 0;

	//if NULL and 0 are passed as parameters, last sent frame will be sent again.
	if( ( aI2CProtocolFrameBuf == NULL ) && ( aFrameSize == 0 ) )
	{
		lI2CProtocolFramePtr = gsI2CProtocolFrameTxBuf;
		lFrameSize = lastSentFrameSize;
	}
	else
	{

		lI2CProtocolFramePtr = aI2CProtocolFrameBuf;
		lFrameSize = aFrameSize;
		lastSentFrameSize = aFrameSize;
	}

	hal_i2cs_fifo_apb_i2c_FIFO_flush();
	for(i=0; i<lFrameSize; i++)
	{
		hal_set_i2cs_fifo_apb_i2c_write_data_port(lI2CProtocolFramePtr[i]);
	}
	hal_set_i2cs_msg_apb_i2c(I2C_NEW_FRAME_READY_BYTE);
	gsI2CProtocolFrameCounter++;		//Will roll over.
	return i;
}

void parseI2CProtocolFrame(uint8_t *aBuf, uint16_t aLen)
{
	I2CProtocolFrame_t *lParseFramePtr = (I2CProtocolFrame_t *)aBuf;
	uint16_t ui16Crc = 0;
	split_2Byte_t lRxdCrc;
	lRxdCrc.hw = 0;
	ui16Crc = I2CProtocolFrameCalChksum(aBuf, aLen-2);
	lRxdCrc.b[0] = aBuf[aLen - 2];
	lRxdCrc.b[0] = aBuf[aLen - 1];
	if( lRxdCrc.hw == ui16Crc)
	{

	}
	else
	{
		//TODO: Failed CRC, retry last frame?
	}
	if(lParseFramePtr->SOF == HOST_TO_A2_FRAME_HEADER )
	{
		if( lParseFramePtr->CmdType == A2_LOAD_MEMORY_CMD)
		{
			memcpy((void *)(long)lParseFramePtr->A2RamAddress, (void *)(long)lParseFramePtr->Data, lParseFramePtr->DataLen);
		}
		else if ( lParseFramePtr->CmdType == A2_JUMP_TO_ADDRESS_CMD )
		{
			dbg_str("\nI2C BL JMP ");
			dbg_hex32(lParseFramePtr->A2RamAddress);
			dbg_str(" ");
			jump_to_address(lParseFramePtr->A2RamAddress);
		}
	}
}

void processI2CProtocolFrames(void)
{
	uint16_t i = 0;
	if( hal_get_i2cs_msg_i2c_apb_status() != 0 )
	{
		gStopUartMsgFlg = 1;
		if( hal_get_i2cs_msg_i2c_apb() == A2_I2C_BL_IS_READY_CHECK_CMD )
		{
			hal_set_i2cs_msg_apb_i2c(A2_I2C_BL_IS_READY_CHECK_RSP_YES);
		}
		else if( hal_get_i2cs_msg_i2c_apb() == I2C_NEW_FRAME_READY_BYTE )
		{
			//APB reads out the written data.
			//If the read FIFO is not empty
			i = 0;
			while( hal_get_i2cs_fifo_i2c_apb_read_flags() != 0 )
			{
				gsI2CProtocolFrameRxBuf[i] = hal_get_i2cs_fifo_i2c_apb_read_data_port();
				i++;
			}
			parseI2CProtocolFrame(gsI2CProtocolFrameRxBuf, i);
		}
	}
}



