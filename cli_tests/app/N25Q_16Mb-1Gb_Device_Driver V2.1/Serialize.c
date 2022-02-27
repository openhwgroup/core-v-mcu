/**********************  DRIVER FOR SPI CONTROLLER ON ORION**********************

   Filename:    Serialize.c
   Description:  Support to . This files is aimed at giving a basic example of
   SPI Controller to simulate the SPI serial interface.

   Version:    0.2
   Date:       Decemb. 2011
   Authors:    Micron S.r.l. Arzano (Napoli)


   THE FOLLOWING DRIVER HAS BEEN TESTED ON ORION WITH FPGA RELEASE 1.4 NON_DDR.

   Since there is no dedicated QUAD SPI controller on PXA processor, the peripheral is
   synthesized on FPGA and it is interfaced with CPU through memory controller. It is
   implemented on chip select-5 region of PXA processor and communicates with device using
   32bits WRFIFO and RDFIFO. This controller is aligned with  Micron SPI Flash Memory.
   That's mean that in extended, dual and quad mode works only with command of these memory.

   These are list of address for different SPI controller registers:

   			Chip Base  is mapped at 0x16000000

   Register         |     Address          |    Read/Write
                    |                      |
   RXFIFO           | (Chip Base + 0x0)    |      Read
   WRFIFO           | (Chip Base + 0x4)    |      Write
   Control Register | (Chip Base + 0x8)    |      R/W
   Status Register  | (Chip Base + 0xC)    |      Read



********************************************************************************

*******************************************************************************/
#include <stdint.h>
#include <stdbool.h>
#include "Serialize.h"
#include "N25Q.h"
#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "hal/include/hal_fc_event.h"
#include "hal/include/hal_udma_ctrl_reg_defs.h"
#include "hal/include/hal_udma_qspi_reg_defs.h"
#include <drivers/include/udma_qspi_driver.h>
//#define ENABLE_PRINT_DEBUG

#define EXT_MOD
static uint32 cmdBuf[32] = {0};
static uint8 gsUdmaQSPI_TxBuf[32] = {0};
static uint8 gsUdmaQSPI_RxBuf[32] = {0};
static uint8 gsTxBuf[32] = {0};
static uint16 gsTxFillBufIndex = 0;

extern uint8_t aucclkdiv;

/*******************************************************************************
     SPI Rodan controller init
Function:     SpiRodanPortInit()
Arguments:    There is no argument for this function
Return Values:Return RetSpiError if the FPGA configuration is not correct.
Description:  This function has to be called at the beginnning to configure the
			  port.

/******************************************************************************/
SPI_STATUS SpiRodanPortInit(void)
{

	/*Check the FPGA Configuration Release*/
	if (WRONG_FPGA)
		return RetSpiError;

	/*Clean the Controller Register */
	WR_R(SPICR, RD_R(SPICR) & ZERO_MASK);

	/* Set clock frequency to 25 MHz, set 8 DUMMY cycles, disable WP and HOLD modes and enable SPI controller */
	WR_R(SPICR, RD_R(SPICR) | SPICR_CLK(0x1) | SPICR_DUMMY(8) | SPICR_WP | SPICR_HOLD);

#ifdef SPI_NAND
	/* Set SPI_NAND_ENABLE bit in the SPI Controller Register */
	WR_R(SPICR, RD_R(SPICR) | SPI_NAND_EN);
#endif

#ifdef EXT_MOD
	/* enable extended mode */
	EXT_ENABLE;
#endif

	/*Set byte size transfer*/
	SET_TXRXSIZE(8);

	return RetSpiSuccess;

}

/*******************************************************************************
Function:     ConfigureSpi(SpiConfigOptions opt)
Arguments:    opt configuration options, all acceptable values are enumerated in
              SpiMasterConfigOptions, which is a typedefed enum.
Return Values:There is no return value for this function.
Description:  This function can be used to properly configure the SPI master
              before and after the transfer/receive operation
Pseudo Code:
   Step 1  : perform or skip select/deselect slave
   Step 2  : perform or skip enable/disable transfer
   Step 3  : perform or skip enable/disable receive
*******************************************************************************/

void ConfigureSpi(SpiConfigOptions opt)
{
	switch (opt)
	{
	case OpsWakeUp:
		//CHECK_BSY;
		//SET_CS;
		break;
	case OpsInitTransfer:
		//FLUSHRWFIFO;
		break;
	case OpsEndTransfer:
		//CLEAR_CS;
		//FLUSHRWFIFO;
		break;
	default:
		break;
	}
}



SPI_STATUS Serialize_SPI_A2_UDMAQSPI(uint8 *aSendBuf,uint16 aSendLen, uint8 *aRecvBuf,uint16 aRecvLen)
{
	uint8_t qspim_id = 0;
	uint8_t cs = 0;
	uint16_t i = 0;
	uint32_t*	pcmd = cmdBuf;
	uint8 *char_send = (uint8 *)NULL;
	uint8 *char_recv = (uint8 *)NULL;
	uint16 rx_len = 0;
	uint16 tx_len = 0;
	uint16 lRxLen = 0;
	uint16 lRemainder = 0;
	uint16 lTxExtraBytes = 0;


	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(UDMA_CH_ADDR_QSPIM + qspim_id * UDMA_CH_SIZE);

#ifdef ENABLE_PRINT_DEBUG
	int i;
	CLI_printf("\nSEND: ");
	for(i=0; i<char_stream_send->length; i++)
		CLI_printf(" 0x%x ", char_stream_send->pChar[i]);
	CLI_printf("\n");
#endif

	tx_len = aSendLen;
	char_send = aSendBuf;

	rx_len = aRecvLen;
	char_recv = aRecvBuf;

	lTxExtraBytes = tx_len % 4;

	lRemainder = rx_len % 4;
	if( lRemainder )
		lRxLen = rx_len + (4 - lRemainder);
	else
		lRxLen = rx_len;


	//ConfigureSpi(optBefore);
	udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);

	pqspim_regs->rx_cfg_b.en = 0;
	pqspim_regs->tx_cfg_b.en = 0;
	pqspim_regs->cmd_cfg_b.en = 0;

	pqspim_regs->rx_cfg_b.clr = 1;
	pqspim_regs->tx_cfg_b.clr = 1;
	pqspim_regs->cmd_cfg_b.clr = 1;


	*pcmd++ = kSPIm_Cfg | aucclkdiv;
	*pcmd++ = kSPIm_SOT | cs;
	if( char_send[0] == SPI_FLASH_INS_QIPP )
	{
		lTxExtraBytes = 5;	//1 byte cmd and 4 byte address will be transmitted as
	}

	for(i=0; i < lTxExtraBytes; i++ )
	{
		*pcmd++ = kSPIm_SendCmd | (0x70000 | char_send[i]);
		//Using the kSPIm_SendCmd register to perform one byte transfers. This is useful when the length not a multiple of 4 is passed.
	}
	if( tx_len >= 4 )
	{
		if( char_send[0] == SPI_FLASH_INS_QIPP )
			*pcmd++ = kSPIm_TxData | (0x08470000 | ((tx_len - lTxExtraBytes)-1)) ;		//the program data will be programmed in quad mode.
		else
			*pcmd++ = kSPIm_TxData | (0x00470000 | ((tx_len - lTxExtraBytes)-1)) ;
	}
	if( ( rx_len != 0 ) && ( char_recv != NULL ) )
	{
		if( char_send[0] == SPI_FLASH_INS_QOFR )
		{	//Quad output fast read, switch Rx to quad mode by enabling the quad bit.
			*pcmd++ = kSPIm_Dummy | 0x00070000;
			*pcmd++ = kSPIm_RxData | (0x08470000 | (lRxLen-1)) ; // 4 words per transfer
		}
		else
		{
			*pcmd++ = kSPIm_RxData | (0x00470000 | (lRxLen-1)) ; // 4 words per transfer
		}
	}
	*pcmd++ = kSPIm_EOT  | 1; // generate event


	pqspim_regs->cmd_saddr = (uint32_t)cmdBuf;
	pqspim_regs->cmd_size = (uint32_t)(pcmd - cmdBuf)*4;
	pqspim_regs->cmd_cfg_b.en = 1;

	if( tx_len >= 4 )
	{
		for( i=0; i< (tx_len - lTxExtraBytes); i++ )
			gsUdmaQSPI_TxBuf[i] = char_send[lTxExtraBytes + i];
		pqspim_regs->tx_saddr = (uint32_t)gsUdmaQSPI_TxBuf;
		pqspim_regs->tx_size = tx_len - lTxExtraBytes;
		pqspim_regs->tx_cfg_b.en = 1;
	}

	if( ( rx_len != 0 ) && ( char_recv != NULL ) )
	{
		pqspim_regs->rx_saddr = (uint32_t)gsUdmaQSPI_RxBuf;
		pqspim_regs->rx_size = lRxLen;
		pqspim_regs->rx_cfg_b.en = 1;
		while (pqspim_regs->rx_size != 0) {}
		for( i=0; i< rx_len; i++ )
			char_recv[i] = gsUdmaQSPI_RxBuf[i];
	}


#ifdef ENABLE_PRINT_DEBUG
	CLI_printf("\nRECV: ");
	for(i=0; i<char_stream_recv->length; i++)
		CLI_printf(" 0x%x ", char_stream_recv->pChar[i]);
	CLI_printf("\n");
#endif

	//ConfigureSpi(optAfter);


	return RetSpiSuccess;
}

/*******************************************************************************
Function:     Serialize(const CharStream* char_stream_send,
					CharStream* char_stream_recv,
					SpiMasterConfigOptions optBefore,
					SpiMasterConfigOptions optAfter
				)
Arguments:    char_stream_send, the char stream to be sent from the SPI master to
              the Flash memory, usually contains instruction, address, and data to be
              programmed.
              char_stream_recv, the char stream to be received from the Flash memory
              to the SPI master, usually contains data to be read from the memory.
              optBefore, configurations of the SPI master before any transfer/receive
              optAfter, configurations of the SPI after any transfer/receive
Return Values:TRUE
Description:  This function can be used to encapsulate a complete transfer/receive
              operation
Pseudo Code:
   Step 1  : perform pre-transfer configuration
   Step 2  : perform transfer/ receive
   Step 3  : perform post-transfer configuration
*******************************************************************************/
SPI_STATUS Serialize_SPI(const CharStream* char_stream_send,
                         CharStream* char_stream_recv,
                         SpiConfigOptions optBefore,
                         SpiConfigOptions optAfter
                        )
{
	//This function handles the fragmented calls from N25Q driver, where it passes commands once and then the data.
	uint16 i = 0;
	uint8 * lRecvPtr = (uint8 *)NULL;
	uint16 lRecvLen = 0;

	SPI_STATUS lStatus = RetSpiError;

	if ( char_stream_send != NULL )
	{
		for( i=0; i<char_stream_send->length; i++ )
			gsTxBuf[gsTxFillBufIndex + i] = char_stream_send->pChar[i];
		gsTxFillBufIndex += i;
	}
	if( char_stream_recv != NULL )
	{
		lRecvPtr = char_stream_recv->pChar;
		lRecvLen = char_stream_recv->length;
	}

	if( optAfter == OpsEndTransfer )
	{
		lStatus = Serialize_SPI_A2_UDMAQSPI(gsTxBuf, gsTxFillBufIndex, lRecvPtr, lRecvLen);
		//Reset index
		gsTxFillBufIndex = 0;
	}
	else if( optAfter == OpsInitTransfer )
	{
		//Do not send out, the caller will call back with endTransfer option.
	}

	return lStatus;
}

/*
void four_byte_addr_ctl(int enable)
{
	if(enable)
		FOUR_BYTE_ENABLE;

	if(!enable)
		FOUR_BYTE_DISABLE;
}
*/
