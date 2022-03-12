#ifndef __I2C_PROTOCOL_H__
#define __I2C_PROTOCOL_H__

typedef struct {
	uint16_t SOF;
	uint32_t A2RamAddress;
	uint8_t CmdType;
	uint8_t DataLen;
	uint8_t Data[2];		//Indicate start of data.
}__attribute__((packed))I2CProtocolFrame_t;



#define I2C_PROTOCOL_MAX_PAYLOAD_SIZE            240

#define I2C_PROTOCOL_FRAME_HEADER_SIZE			(sizeof(I2CProtocolFrame_t) - 2)
#define I2C_PROTOCOL_FRAME_CRC_SIZE				2
#define A2_TO_HOST_FRAME_HEADER			0x5A70
#define HOST_TO_A2_FRAME_HEADER			0xA507

#define A2_I2C_BL_WITHOUT_CRC_IS_READY_CHECK_CMD 	0x19
#define A2_I2C_BL_WITH_CRC_IS_READY_CHECK_CMD 		0x20
#define A2_I2C_BL_IS_READY_CHECK_RSP_YES			0x21
#define A2_I2C_BL_IS_READY_CHECK_RSP_NO				0x22
#define I2C_NEW_FRAME_READY_BYTE 					0x23
#define A2_LOAD_MEMORY_CMD							0x24
#define A2_READ_MEMORY_CMD							0x25
#define A2_JUMP_TO_ADDRESS_CMD						0x26
#define A2_RESET_REASON_POR							0x27
#define A2_RESET_REASON_WDT							0x28
#define A2_RESET_REASON_BUTTON_PRESS				0x29
#define A2_CORRUPTED_FRAME_RCVD 					0x30
#define A2_GOOD_FRAME_RCVD							0x31

uint8_t formI2CProtocolFrame(uint8_t *aBuf, uint8_t aBufSize, uint8_t aCmdType, uint8_t *aData, uint8_t aDataLen, uint8_t aCRCOnOff);
void processI2CProtocolFrames(void);
uint8_t sendI2CProtocolFrame(uint8_t *aI2CProtocolFrameBuf, uint8_t aFrameSize);
void parseI2CProtocolFrame(uint8_t *aBuf, uint16_t aLen);



#endif
