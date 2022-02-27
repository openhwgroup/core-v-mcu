/*
 *
 *  STFL-I based Serial Flash Memory Driver
 *
 *
 *  Filename:		N25Q.c
 *  Description:	Library routines for the N25Q Serial Flash Memories series
 *
 *
 *  Version:		2.1
 *  Date:		    Aug 2015
 *  Authors:		Micron China
 *
 *  THE PRESENT SOFTWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS WITH
 *  CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME. AS A
 *  RESULT, MICRON SHALL NOT BE HELD LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL
 *  DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE CONTENT OF SUCH SOFTWARE
 *  AND/OR THE USE MADE BY CUSTOMERS OF THE CODING INFORMATION CONTAINED HEREIN IN
 *  CONNECTION WITH THEIR PRODUCTS.
 *
 *  Version History
 *
 *  Ver.		Date				Comments
 *
 *  1.0			April 2010			Initial relase
 *  1.1			October 2011		Added 4-byte address mode support for N25Q256
 *  1.2         January 2012    	Minor bug fixing
 *  1.3			February 2012		Added support for N25Q 512M stacked (256M+256M)
 *  1.4			October 2012		Added support for N25Q 8M and 16M
 *  1.5			December 2012		Added support for Step B
 *  1.6			January 2013		Added OTP Program and Read functions
 *  1.7			August 2014	        Fixed single die size bit bug and dieErase timeout bug
 *  1.8			October 2014        add read flag status register for N25Q512Mb/N25Q1Gb device in the IsFlashBusy()
 *	1.9			January 2015		Fixed inconsistent function declaration
 *	2.0			February 2015		Fixed some compilation warnings
 *									Fixed the issue of IsflashBusy() cann't detect correct status
 *									Fixed one potential bug of  FlashWriteNVConfigurationRegister doesn't send the correct value.
 *	2.1			August 2015			added write/read lock register function
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "N25Q.h" 			/* Header file with global prototypes */
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"

extern uint8_t gQuadModeSupportedFlg;

/* Serialize.h
 *
 * Serialize.h contains the signature for Serialize_SPI function.
 * This function is platform depended and allows the driver to communicate with flash
 * device. Serialize_SPI has the following signature:
 *
 * SPI_STATUS Serialize_SPI(const CharStream* char_stream_send,
 *              CharStream* char_stream_recv,
 *             SpiConfigOptions optBefore,
 *             SpiConfigOptions optAfter
 *             )
 *
 * where:
 *
 * -	char_stream_send: the char stream to be sent from the SPI master
 * 		to the Flash memory. Usually contains instruction, address, and data
 * 		to be programmed;
 * -	char_stream_recv: the char stream to be received by the SPI master,
 *      sent from the Flash memory. Usually contains data to be read from the
 *      memory;
 * -	optBefore: configurations of the SPI master before any transfer/receive;
 * -	optAfter: configurations of the SPI after any transfer/receive;
 * -	SPI_STATUS can be assume success or failed error value.
 *
 * and in particular optBefore and optAfter can assume the following values:
 *
 * -	OpsWakeUp: set the CS;
 * -	OpsInitTransfer: keep the CS unchanged;
 * -	OpsEndTransfer: clear the CS.
 *
 * This driver assume to use a SPI Flash specific controller who take care about the right
 * signals management for Dual, Quad, Extended mode and dummy bytes insertion. If you
 * use a generic SPI controller, some changes may be necessary.
 *
 */
#include "Serialize.h"

#ifdef TIME_H_EXISTS
#include <time.h>
#endif

/* global flash device object */
FLASH_DEVICE_OBJECT *fdo;

/* local function, not api */
void fill_addr_vect(uAddrType udAddr, NMX_uint8* pIns_Addr, NMX_uint8 num_address_byte);
ReturnType WAIT_TILL_Instruction_EXECUTION_COMPLETE(NMX_sint16 second);

/*******************************************************************************
Function:     uAddrType BlockOffset ( uSectorType uscSectorNr);
Arguments:    Sector Number

Description:  This function is used to obtain the sector's start address
Pseudo Code:
   Step 1: Return the sector start address
*******************************************************************************/
uAddrType BlockOffset(uSectorType uscSectorNr)
{
	return (uscSectorNr << fdo->Desc.FlashSectorSize_bit);
}

/*******************************************************************************
Function:     ReturnType Driver_Init(void);
Arguments:

Description:  This function is used to initialize the driver. The function perform
			  device detection and sets driver to use the right functions. If the
			  device is a N25Q256 or higher, the function enables the 4-byte address mode.
Pseudo Code:
   Step 1: Detect the device type
   Step 2: Set device parameters (shape and operation)
   Step 3: If N25Q256 device or higher, call FlashEnter4ByteAddressMode and verify that
		   device accept 4-byte address mode.
*******************************************************************************/
ReturnType Driver_Init(FLASH_DEVICE_OBJECT *flash_device_object)
{
	NMX_uint8 flag = 0;
	NMX_uint32 Device = 0;
	ReturnType ret;
	uint8_t i = 0;
	fdo = flash_device_object;

	for(i=0; i<8; i++ )
	{
		//set pin muxes
		hal_setpinmux(13+i, 0);
	}

	ret = FlashReadDeviceIdentification(&Device);
	if(ret == Flash_Success)
	{
		fdo->Desc.FlashId = Device;
	}

	/* N25Q8 */
	if (Device == MEM_TYPE_N25Q8)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q8\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x100000;
		fdo->Desc.FlashSectorCount = 0x10;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x100;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x1000;
		fdo->Desc.FlashPageSize = 0x0100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* this device support only 3 byte address mode */
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = NULL_PTR;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister  = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = NULL_PTR;
		fdo->GenOp.Exit4ByteAddressMode = NULL_PTR;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

		return Flash_Success;
	}

	/* N25Q16 */
	if (Device == MEM_TYPE_N25Q16)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q16\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x200000;
		fdo->Desc.FlashSectorCount = 0x20;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x200;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x2000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* this device support only 3 byte address mode */
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = NULL_PTR;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister  = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = NULL_PTR;
		fdo->GenOp.Exit4ByteAddressMode = NULL_PTR;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

		return Flash_Success;
	}


	/* N25Q32 */
	if (Device == MEM_TYPE_N25Q32)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q32\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x400000;
		fdo->Desc.FlashSectorCount = 0x40;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x400;
		fdo->Desc.FlashSubSectorSize =  0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x4000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* this device support only 3 byte address mode */
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = NULL_PTR;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister  = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = NULL_PTR;
		fdo->GenOp.Exit4ByteAddressMode = NULL_PTR;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

		return Flash_Success;
	}

	/* N25Q64 */
	if (Device == MEM_TYPE_N25Q64)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q64\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x800000;
		fdo->Desc.FlashSectorCount = 0x80;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x800;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x8000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* this device support only 3 byte address mode */
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = NULL_PTR;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister  = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = NULL_PTR;
		fdo->GenOp.Exit4ByteAddressMode = NULL_PTR;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

		return Flash_Success;
	}

	/* N25Q128 */
	if (Device == MEM_TYPE_N25Q128)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q128\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x1000000;
		fdo->Desc.FlashSectorCount = 0x100;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x1000;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x10000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* this device support only 3 byte address mode */
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = NULL_PTR;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister  = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = NULL_PTR;
		fdo->GenOp.Exit4ByteAddressMode = NULL_PTR;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

		return Flash_Success;
	}

	/* N25Q256 */
	if (Device == MEM_TYPE_N25Q256)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q256\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x2000000;
		fdo->Desc.FlashSectorCount = 0x200;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x2000;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x20000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* 3-addr-byte is default startup address mode, except if you use
		 * NVConfig addr mode setting (please see datasheet for more details)
		 */
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = NULL_PTR;
#ifdef SUPPORT_N25Q_STEP_B
		fdo->GenOp.BulkErase = FlashBulkErase;
#endif
#ifndef SUPPORT_N25Q_STEP_B
		fdo->GenOp.BulkErase = NULL_PTR;
#endif
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = FlashEnter4ByteAddressMode;
		fdo->GenOp.Exit4ByteAddressMode = FlashExit4ByteAddressMode;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

#ifdef ADDR_MODE_AUTO_DETECT
		/* assume you want to use the whole device size  */
		fdo->GenOp.Enter4ByteAddressMode();
		/* verify current addr mode */
		fdo->GenOp.ReadFlagStatusRegister(&flag);
		if (flag & 1)   /* test addressing bit of flag status reg (bit 0) */
		{
			fdo->Desc.NumAddrByte = FLASH_4_BYTE_ADDR_MODE;
			gQuadModeSupportedFlg = 1;
		}
#endif

		return Flash_Success;
	}

	/* N25Q512 */
	if ((Device == MEM_TYPE_N25Q512_V3) || (Device == MEM_TYPE_N25Q512_V18))
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q512\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x4000000;
		fdo->Desc.FlashSectorCount = 0x400;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 10000;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x40000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashDieCount = 2;
		fdo->Desc.FlashDieSize = 0x2000000;
		fdo->Desc.FlashDieSize_bit = 25;
		fdo->Desc.FlashAddressMask = 0x00FF;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = FlashDieErase;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = FlashEnter4ByteAddressMode;
		fdo->GenOp.Exit4ByteAddressMode = FlashExit4ByteAddressMode;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

#ifdef ADDR_MODE_AUTO_DETECT
		/* assume you want to use the whole device size  */
		fdo->GenOp.Enter4ByteAddressMode();
		/* verify current addr mode */
		fdo->GenOp.ReadFlagStatusRegister(&flag);
		if (flag & 1)   /* test addressing bit of flag status reg (bit 0) */
			fdo->Desc.NumAddrByte = FLASH_4_BYTE_ADDR_MODE;
#endif

		return Flash_Success;
	}

	/* N25Q1G (512M+512m stacked) */
	if (Device == MEM_TYPE_N25Q1G)
	{
#ifdef N25Q_DEBUG
		CLI_printf("Detected N25Q1G\n");
#endif

		/* device shape */
		fdo->Desc.FlashSize = 0x8000000;
		fdo->Desc.FlashSectorCount = 0x800;
		fdo->Desc.FlashSectorSize = 0x10000;
		fdo->Desc.FlashSectorSize_bit = 16;
		fdo->Desc.FlashSubSectorCount = 0x8000;
		fdo->Desc.FlashSubSectorSize = 0x1000;
		fdo->Desc.FlashSubSectorSize_bit = 12;
		fdo->Desc.FlashPageCount = 0x80000;
		fdo->Desc.FlashPageSize = 0x100;
		fdo->Desc.FlashOTPSize = 0x40;
		fdo->Desc.FlashAddressMask = 0x00FF;
		fdo->Desc.FlashDieCount = 4;
		fdo->Desc.FlashDieSize = 0x2000000;
		fdo->Desc.FlashDieSize_bit = 25;
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

		/* device operation */
		fdo->GenOp.DeviceId = FlashReadDeviceIdentification;
		fdo->GenOp.ReadStatusRegister = FlashReadStatusRegister;
		fdo->GenOp.DataProgram = DataProgram;
		fdo->GenOp.DataRead = DataRead;
		fdo->GenOp.SectorErase = FlashSectorErase;
		fdo->GenOp.SubSectorErase = FlashSubSectorErase;
		fdo->GenOp.DieErase = FlashDieErase;
		fdo->GenOp.BulkErase = NULL_PTR;
		fdo->GenOp.BlockOffset = BlockOffset;
		fdo->GenOp.WriteEnable = FlashWriteEnable;
		fdo->GenOp.WriteDisable = FlashWriteDisable;
		fdo->GenOp.ProgramEraseSuspend = NULL_PTR;
		fdo->GenOp.ProgramEraseResume = NULL_PTR;
		fdo->GenOp.ClearFlagStatusRegister = FlashClearFlagStatusRegister;
		fdo->GenOp.ReadNVConfigurationRegister = FlashReadNVConfigurationRegister;
		fdo->GenOp.ReadVolatileConfigurationRegister = FlashReadVolatileConfigurationRegister;
		fdo->GenOp.ReadVolatileEnhancedConfigurationRegister = FlashReadVolatileEnhancedConfigurationRegister;
		fdo->GenOp.ReadFlagStatusRegister = FlashReadFlagStatusRegister;
		fdo->GenOp.WriteNVConfigurationRegister = FlashWriteNVConfigurationRegister;
		fdo->GenOp.WriteVolatileConfigurationRegister = FlashWriteVolatileConfigurationRegister;
		fdo->GenOp.WriteVolatileEnhancedConfigurationRegister = FlashWriteVolatileEnhancedConfigurationRegister;
		fdo->GenOp.Enter4ByteAddressMode = FlashEnter4ByteAddressMode;
		fdo->GenOp.Exit4ByteAddressMode = FlashExit4ByteAddressMode;
		fdo->GenOp.LockSector = FlashLockSector;
		fdo->GenOp.UnlockAllSector = FlashUnlockAllSector;
		fdo->GenOp.OTPProgram = FlashOTPProgram;
		fdo->GenOp.OTPRead = FlashOTPRead;

#ifdef ADDR_MODE_AUTO_DETECT
		/* assume you want to use the whole device size  */
		fdo->GenOp.Enter4ByteAddressMode();
		/* verify current addr mode */
		fdo->GenOp.ReadFlagStatusRegister(&flag);
		if (flag & 1)   /* test addressing bit of flag status reg (bit 0) */
			fdo->Desc.NumAddrByte = FLASH_4_BYTE_ADDR_MODE;
#endif

		return Flash_Success;
	}

#ifdef N25Q_DEBUG
	CLI_printf("No device detected %x\n",Device);
#endif

	return Flash_WrongType;
}

/*******************************************************************************
Function:     ReturnType Program(InstructionType insInstruction, ParameterType *fp )
Arguments:    insInstruction is an enum which contains all the available Instructions
    of the SW driver.
              fp is a (union) parameter struct for all Flash Instruction parameters
Return Value: The function returns the following conditions:

   Flash_AddressInvalid,
   Flash_MemoryOverflow,
   Flash_PageEraseFailed,
   Flash_PageNrInvalid,
   Flash_SectorNrInvalid,
   Flash_FunctionNotSupported,
   Flash_NoInformationAvailable,
   Flash_OperationOngoing,
   Flash_OperationTimeOut,
   Flash_ProgramFailed,
   Flash_SpecificError,
   Flash_SectorProtected,
   Flash_SectorUnprotected,
   Flash_SectorProtectFailed,
   Flash_SectorUnprotectFailed,
   Flash_SectorLocked,
   Flash_SectorUnlocked,
   Flash_SectorLockDownFailed,
   Flash_Success,
   Flash_WrongType

Description:  This function is used to access all functions provided with the
   current Flash device.

Pseudo Code:
   Step 1: Select the right action using the insInstruction parameter
   Step 2: Execute the Flash memory Function
   Step 3: Return the Error Code
*******************************************************************************/
ReturnType DataProgram(InstructionType insInstruction, ParameterType *fp)
{
	ReturnType rRetVal;
	NMX_uint8 insCode;

	switch (insInstruction)
	{

	/* PAGE PROGRAM */
	case PageProgram:
#ifndef SUPPORT_N25Q_STEP_B
		insCode = SPI_FLASH_INS_PP;
#endif
#ifdef SUPPORT_N25Q_STEP_B
		insCode = SPI_FLASH_INS_PP4B;
#endif
		break;

	/* DUAL INPUT FAST PROGRAM */
	case DualInputProgram:
		insCode = SPI_FLASH_INS_DIPP;
		break;

	/* EXTENDED DUAL INPUT FAST PROGRAM */
	case DualInputExtendedFastProgram:
		insCode = SPI_FLASH_INS_DIEPP;
		break;

	/* QUAD INPUT FAST PROGRAM */
	case QuadInputProgram:
#ifndef SUPPORT_N25Q_STEP_B
		insCode = SPI_FLASH_INS_QIPP;
#endif
#ifdef SUPPORT_N25Q_STEP_B
		insCode = SPI_FLASH_INS_QIPP4B;
#endif
		break;

	/* EXTENDED QUAD INPUT FAST PROGRAM */
	case QuadInputExtendedFastProgram:
		insCode = SPI_FLASH_INS_QIEPP;
		break;

	default:
		return Flash_FunctionNotSupported;
		break;

	} /* EndSwitch */

	rRetVal = FlashDataProgram( (*fp).PageProgram.udAddr,
	                            (*fp).PageProgram.pArray,
	                            (*fp).PageProgram.udNrOfElementsInArray,
	                            insCode
	                          );

	return rRetVal;
} /* EndFunction Flash */


/*******************************************************************************
Function:     ReturnType DataRead(InstructionType insInstruction, ParameterType *fp)
Arguments:    insInstruction is an enum which contains all the available Instructions
    of the SW driver.
              fp is a (union) parameter struct for all Flash Instruction parameters
Return Value: The function returns the following conditions:

   Flash_AddressInvalid,
   Flash_MemoryOverflow,
   Flash_PageEraseFailed,
   Flash_PageNrInvalid,
   Flash_SectorNrInvalid,
   Flash_FunctionNotSupported,
   Flash_NoInformationAvailable,
   Flash_OperationOngoing,
   Flash_OperationTimeOut,
   Flash_ProgramFailed,
   Flash_SpecificError,
   Flash_SectorProtected,
   Flash_SectorUnprotected,
   Flash_SectorProtectFailed,
   Flash_SectorUnprotectFailed,
   Flash_SectorLocked,
   Flash_SectorUnlocked,
   Flash_SectorLockDownFailed,
   Flash_Success,
   Flash_WrongType

Description:  This function is used to access all functions provided with the
   current Flash device.

Pseudo Code:
   Step 1: Select the right action using the insInstruction parameter
   Step 2: Execute the Flash memory Function
   Step 3: Return the Error Code
*******************************************************************************/
ReturnType DataRead(InstructionType insInstruction, ParameterType *fp)
{
	NMX_uint8 insCode;
	ReturnType rRetVal;

	switch (insInstruction)
	{
	case Read:
		insCode = SPI_FLASH_INS_READ;
		break;

	case FastRead:
		insCode = SPI_FLASH_INS_FAST_READ;
		break;

	case DualOutputFastRead:
		insCode = SPI_FLASH_INS_DOFR;
		break;

	case QuadOutputFastRead:
		insCode = SPI_FLASH_INS_QOFR;
		break;

	case DualInputOutputFastRead:
		insCode = SPI_FLASH_INS_DIOFR;
		break;

	case QuadInputOutputFastRead:
		insCode = SPI_FLASH_INS_QIOFR;
		break;
	case ReadFlashDiscovery:
		insCode = SPI_FLASH_INS_DISCOVER_PARAMETER;
		break;

	default:
		return Flash_FunctionNotSupported;
		break;

	} /* EndSwitch */
	rRetVal = FlashDataRead(fp->Read.udAddr, fp->Read.pArray, fp->Read.udNrOfElementsToRead, insCode);
	return rRetVal;
}


/*******************************************************************************
Function:     FlashWriteEnable( void )
Arguments:    void

Return Value:
   Flash_Success

Description:  This function sets the Write Enable Latch(WEL)
              by sending a WREN Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially
*******************************************************************************/
ReturnType FlashWriteEnable( void )
{
	CharStream char_stream_send;
	NMX_uint8 cWREN = SPI_FLASH_INS_WREN;
	NMX_uint8 ucSR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length = 1;
	char_stream_send.pChar  = &cWREN;

	// Step 2: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 3: Read the Status Register.
	do
	{
		FlashReadStatusRegister(&ucSR);
	}
	while(~ucSR & SPI_SR1_WEL);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashWriteDisable( void )
Arguments:    void

Return Value:
   Flash_Success

Description:  This function resets the Write Enable Latch(WEL)
              by sending a WRDI Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially
*******************************************************************************/
ReturnType  FlashWriteDisable( void )
{
	CharStream char_stream_send;
	NMX_uint8 cWRDI = SPI_FLASH_INS_WRDI;
	NMX_uint8 ucSR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length = 1;
	char_stream_send.pChar  = &cWRDI;

	// Step 2: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 3: Read the Status Register.
	do
	{
		FlashReadStatusRegister(&ucSR);
	}
	while(ucSR & SPI_SR1_WEL);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashReadDeviceIdentification( NMX_uint32 *uwpDeviceIdentification)
Arguments:    uwpDeviceIdentificaiton, 32-bit buffer to hold the DeviceIdentification
			  read from the memory, with this parts:

NMX_unit32

 | 0x00 | MANUFACTURER_ID | MEM_TYPE | MEM_CAPACITY |
MSB                                                LSB

Return Value:
   Flash_Success

Description:  This function returns the Device Identification
			  (manufacurer id + memory type + memory capacity)
              by sending an SPI_FLASH_INS_RDID Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially
   Step 3: Device Identification is returned
*******************************************************************************/
ReturnType FlashReadDeviceIdentification(NMX_uint32 *uwpDeviceIdentification)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  cRDID = SPI_FLASH_INS_RDID;
	NMX_uint8  pIdentification[3];
	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cRDID;

	char_stream_recv.length  = 3;
	char_stream_recv.pChar   = &pIdentification[0];

	// Step 2: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

#ifdef N25Q_DEBUG
	CLI_printf("DeviceId[0] = 0x%x\n", char_stream_recv.pChar[0]);
	CLI_printf("DeviceId[1] = 0x%x\n", char_stream_recv.pChar[1]);
	CLI_printf("DeviceId[2] = 0x%x\n", char_stream_recv.pChar[2]);
#endif

	// Step 3: Device Identification is returned ( manufaturer id + memory type + memory capacity )
	*uwpDeviceIdentification = char_stream_recv.pChar[0];
	*uwpDeviceIdentification <<= 8;
	*uwpDeviceIdentification |= char_stream_recv.pChar[1];
	*uwpDeviceIdentification <<= 8;
	*uwpDeviceIdentification |= char_stream_recv.pChar[2];

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashReadStatusRegister( NMX_uint8 *ucpStatusRegister)    ----ok
Arguments:    ucpStatusRegister, 8-bit buffer to hold the Status Register value read
              from the memory

Return Value:
   Flash_Success

Description:  This function reads the Status Register by sending an
               SPI_FLASH_INS_RDSR Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially, get the Status Register content

*******************************************************************************/
ReturnType FlashReadStatusRegister(NMX_uint8 *ucpStatusRegister)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  cRDSR = SPI_FLASH_INS_RDSR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cRDSR;
	char_stream_recv.length  = 1;
	char_stream_recv.pChar   = ucpStatusRegister;

	// Step 2: Send the packet serially, get the Status Register content
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}


/*******************************************************************************
Function:     FlashWriteStatusRegister( NMX_uint8 ucStatusRegister)
Arguments:    ucStatusRegister, an 8-bit new value to be written to the Status Register

Return Value:
   Flash_Success

Description:  This function modifies the Status Register by sending an
              SPI_FLASH_INS_WRSR Instruction.
              The Write Status Register (WRSR) Instruction has no effect
              on b6, b5, b1(WEL) and b0(WIP) of the Status Register.b6 and b5 are
              always read as 0.

Pseudo Code:
   Step 1: Disable Write protection
   Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
   Step 3: Send the packet serially
   Step 4: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType  FlashWriteStatusRegister(NMX_uint8 ucStatusRegister)
{
	CharStream char_stream_send;
	NMX_uint8  pIns_Val[2];

	// Step 1: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
	char_stream_send.length = 2;
	char_stream_send.pChar  = pIns_Val;
	pIns_Val[0] = SPI_FLASH_INS_WRSR;
	pIns_Val[1] = ucStatusRegister;

	// Step 3: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 4: Wait until the operation completes or a timeout occurs.
	return WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);
}


/*******************************************************************************
Function:     FlashRead( NMX_uint32 udAddr, NMX_uint8 *ucpElements, NMX_uint32 udNrOfElementsToRead)
Arguments:    udAddr, start address to read from
              ucpElements, buffer to hold the elements to be returned
              udNrOfElementsToRead, number of elements to be returned, counted in bytes.

Return Value:
   Flash_AddressInvalid
   Flash_Success

Description:  This function reads the Flash memory by sending an
              SPI_FLASH_INS_READ Instruction.
              by design, the whole Flash memory space can be read with one READ Instruction
              by incrementing the start address and rolling to 0x0 automatically,
              that is, this function is across pages and sectors.

Pseudo Code:
   Step 1: Validate address input
   Step 2: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 3: Send the packet serially, and fill the buffer with the data being returned
*******************************************************************************/
ReturnType FlashDataRead( uAddrType udAddr, NMX_uint8 *ucpElements, NMX_uint32 udNrOfElementsToRead, NMX_uint8 insInstruction)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  pIns_Addr[5];

	// Step 1: Validate address input
	if(!(udAddr < fdo->Desc.FlashSize))
		return Flash_AddressInvalid;

	// Step 2: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;
	char_stream_send.pChar    = pIns_Addr;
	pIns_Addr[0]              = insInstruction;

	fill_addr_vect(udAddr, pIns_Addr, fdo->Desc.NumAddrByte);

	char_stream_recv.length   = udNrOfElementsToRead;
	char_stream_recv.pChar    = ucpElements;

	// Step 3: Send the packet serially, and fill the buffer with the data being returned
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashPageProgram( NMX_uint32 udAddr, NMX_uint8 *pArray, NMX_uint32 udNrOfElementsInArray)
Arguments:    udAddr, start address to write to
              pArray, buffer to hold the elements to be programmed
              udNrOfElementsInArray, number of elements to be programmed, counted in bytes

Return Value:
   Flash_AddressInvalid
   Flash_OperationOngoing
   Flash_OperationTimeOut
   Flash_Success

Description:  This function writes a maximum of 64 bytes of data into the memory by sending an
              SPI_FLASH_INS_PP Instruction.
              by design, the PP Instruction is effective WITHIN ONE page,i.e. 0xXX00 - 0xXXff.
              when 0xXXff is reached, the address rolls over to 0xXX00 automatically.
Note:
              This function does not check whether the target memory area is in a Software
              Protection Mode(SPM) or Hardware Protection Mode(HPM), in which case the PP
              Instruction will be ignored.
              The function assumes that the target memory area has previously been unprotected at both
              the hardware and software levels.
              To unprotect the memory, please call FlashWriteStatusRegister(NMX_uint8 ucStatusRegister),
              and refer to the datasheet for the setup of a proper ucStatusRegister value.
Pseudo Code:
   Step 1: Validate address input
   Step 2: Check whether any previous Write, Program or Erase cycle is on going
   Step 3: Disable Write protection (the Flash memory will automatically enable it again after
           the execution of the Instruction)
   Step 4: Initialize the data (Instruction & address only) packet to be sent serially
   Step 5: Send the packet (Instruction & address only) serially
   Step 6: Initialize the data (data to be programmed) packet to be sent serially
   Step 7: Send the packet (data to be programmed) serially
   Step 8: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType FlashGenProgram(uAddrType udAddr, NMX_uint8 *pArray , NMX_uint32 udNrOfElementsInArray, NMX_uint8 ubSpiInstruction)
{
	CharStream char_stream_send;
	NMX_uint8 pIns_Addr[5];
	NMX_uint8 fsr_value;
	ReturnType ret;

	// Step 1: Validate address input
	if(!(udAddr < fdo->Desc.FlashSize))
		return Flash_AddressInvalid;

	// Step 2: Check whether any previous Write, Program or Erase cycle is on-going
	if(IsFlashBusy()) return Flash_OperationOngoing;

	// Step 3: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 4: Initialize the data (Instruction & address only) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;
	char_stream_send.pChar    = pIns_Addr;

	pIns_Addr[0]              = ubSpiInstruction;

	fill_addr_vect(udAddr, pIns_Addr, fdo->Desc.NumAddrByte);

	// Step 5: Send the packet (Instruction & address only) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsInitTransfer);

	// Step 6: Initialize the data (data to be programmed) packet to be sent serially
	char_stream_send.length   = udNrOfElementsInArray;
	char_stream_send.pChar    = pArray;

	// Step 7: Send the packet (data to be programmed) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 8: Wait until the operation completes or a timeout occurs.
	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);


	FlashReadFlagStatusRegister(&fsr_value);
	FlashClearFlagStatusRegister();

	if((fsr_value & SPI_FSR_PROT) && (fsr_value & SPI_FSR_PROGRAM))
		return Flash_SectorProtected;

	return ret;

}


/*******************************************************************************
Function:     ReturnType FlashSectorErase( uSectorType uscSectorNr )
Arguments:    uSectorType is the number of the Sector to be erased.

Return Values:
   Flash_SectorNrInvalid
   Flash_OperationOngoing
   Flash_OperationTimeOut
   Flash_Success

Description:  This function erases the Sector specified in uscSectorNr by sending an
              SPI_FLASH_INS_SE Instruction.
              The function checks that the sector number is within the valid range
              before issuing the erase Instruction. Once erase has completed the status
              Flash_Success is returned.
Note:
              This function does not check whether the target memory area is in a Software
              Protection Mode(SPM) or Hardware Protection Mode(HPM), in which case the PP
              Instruction will be ignored.
              The function assumes that the target memory area has previously been unprotected at both
              the hardware and software levels.
              To unprotect the memory, please call FlashWriteStatusRegister(NMX_uint8 ucStatusRegister),
              and refer to the datasheet to set a proper ucStatusRegister value.

Pseudo Code:
   Step 1: Validate the sector number input
   Step 2: Check whether any previous Write, Program or Erase cycle is on going
   Step 3: Disable Write protection (the Flash memory will automatically enable it
           again after the execution of the Instruction)
   Step 4: Initialize the data (Instruction & address) packet to be sent serially
   Step 5: Send the packet (Instruction & address) serially
   Step 6: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType  FlashSectorErase( uSectorType uscSectorNr )
{
	CharStream char_stream_send;
	//NMX_uint8  pIns_Addr[4];
	NMX_uint8  pIns_Addr[5];
	uAddrType SectorAddr;
	NMX_uint8 fsr_value;
	ReturnType ret;

	// Step 1: Validate the sector number input
	if(!(uscSectorNr < fdo->Desc.FlashSectorCount)) return Flash_SectorNrInvalid;

	SectorAddr = fdo->GenOp.BlockOffset(uscSectorNr);

	// Step 2: Check whether any previous Write, Program or Erase cycle is on going
	if(IsFlashBusy()) return Flash_OperationOngoing;

	// Step 3: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 4: Initialize the data (Instruction & address) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;
	char_stream_send.pChar    = &pIns_Addr[0];

#ifndef SUPPORT_N25Q_STEP_B
	pIns_Addr[0]              = SPI_FLASH_INS_SE;
#endif
#ifdef SUPPORT_N25Q_STEP_B
	pIns_Addr[0]              = SPI_FLASH_INS_SE4B;
#endif

	fill_addr_vect(SectorAddr, pIns_Addr, fdo->Desc.NumAddrByte);

	// Step 5: Send the packet (Instruction & address) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 6: Wait until the operation completes or a timeout occurs.
	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(SE_TIMEOUT);

	FlashReadFlagStatusRegister(&fsr_value);
	FlashClearFlagStatusRegister();

	if((fsr_value & SPI_FSR_PROT) && (fsr_value & SPI_FSR_ERASE))
		return Flash_SectorProtected;

	return Flash_Success;
}


/*******************************************************************************
Function:     ReturnType FlashSunSectorErase( uSectorType uscSectorNr )
Arguments:    uSectorType is the number of the subSector to be erased.

Return Values:
   Flash_SectorNrInvalid
   Flash_OperationOngoing
   Flash_OperationTimeOut
   Flash_Success

Description:  This function erases the SubSector (4k) specified in uscSectorNr by sending an
              SPI_FLASH_INS_SSE Instruction.
              The function checks that the sub sector number is within the valid range
              before issuing the erase Instruction. Once erase has completed the status
              Flash_Success is returned.
Note:
              This function does not check whether the target memory area is in a Software
              Protection Mode(SPM) or Hardware Protection Mode(HPM), in which case the PP
              Instruction will be ignored.
              The function assumes that the target memory area has previously been unprotected at both
              the hardware and software levels.
              To unprotect the memory, please call FlashWriteStatusRegister(NMX_uint8 ucStatusRegister),
              and refer to the datasheet to set a proper ucStatusRegister value.

Pseudo Code:
   Step 1: Validate the sub sector number input
   Step 2: Check whether any previous Write, Program or Erase cycle is on going
   Step 3: Disable Write protection (the Flash memory will automatically enable it
           again after the execution of the Instruction)
   Step 4: Initialize the data (Instruction & address) packet to be sent serially
   Step 5: Send the packet (Instruction & address) serially
   Step 6: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType  FlashSubSectorErase( uSectorType uscSectorNr )
{
	CharStream char_stream_send;
	NMX_uint8  pIns_Addr[5];
	uAddrType SubSectorAddr;
	NMX_uint8 fsr_value;
	ReturnType ret;

	// Step 1: Validate the sector number input
	if(!(uscSectorNr < fdo->Desc.FlashSubSectorCount))
		return Flash_SectorNrInvalid;

	SubSectorAddr = uscSectorNr << fdo->Desc.FlashSubSectorSize_bit;

	// Step 2: Check whether any previous Write, Program or Erase cycle is on going
	if(IsFlashBusy()) return Flash_OperationOngoing;

	// Step 3: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 4: Initialize the data (Instruction & address) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;;
	char_stream_send.pChar    = &pIns_Addr[0];

#ifndef SUPPORT_N25Q_STEP_B
	pIns_Addr[0]              = SPI_FLASH_INS_SSE;
#endif
#ifdef SUPPORT_N25Q_STEP_B
	pIns_Addr[0]              = SPI_FLASH_INS_SSE4B;
#endif

	fill_addr_vect(SubSectorAddr, pIns_Addr, fdo->Desc.NumAddrByte);

	// Step 5: Send the packet (Instruction & address) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 6: Wait until the operation completes or a timeout occurs.
	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(SE_TIMEOUT);

	FlashReadFlagStatusRegister(&fsr_value);
	FlashClearFlagStatusRegister();

	if((fsr_value & SPI_FSR_PROT) && (fsr_value & SPI_FSR_ERASE))
		return Flash_SectorProtected;

	return Flash_Success;
}


/*******************************************************************************
Function: FlashDieErase

Arguments: uscDieNr

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType  FlashDieErase( uSectorType uscDieNr )
{
	CharStream char_stream_send;
	NMX_uint8  pIns_Addr[5];
	uAddrType DieAddr;
	NMX_uint8 fsr_value;
	ReturnType ret;

	// Step 1: Validate the sector number input
	if(!(uscDieNr < fdo->Desc.FlashDieCount))
		return Flash_SectorNrInvalid;

	DieAddr = uscDieNr << fdo->Desc.FlashDieSize_bit;

	// Step 2: Check whether any previous Write, Program or Erase cycle is on going
	if(IsFlashBusy()) return Flash_OperationOngoing;

	// Step 3: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 4: Initialize the data (Instruction & address) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;;
	char_stream_send.pChar    = &pIns_Addr[0];
	pIns_Addr[0]              = SPI_FLASH_INS_DE;
	fill_addr_vect(DieAddr, pIns_Addr, fdo->Desc.NumAddrByte);

	// Step 5: Send the packet (Instruction & address) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 6: Wait until the operation completes or a timeout occurs.
	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(DIE_TIMEOUT);

	FlashReadFlagStatusRegister(&fsr_value);
	FlashClearFlagStatusRegister();

	if((fsr_value & SPI_FSR_PROT) && (fsr_value & SPI_FSR_ERASE))
		return Flash_SectorProtected;

	return Flash_Success;
}

/*******************************************************************************
Function:     ReturnType FlashBulkErase( void )
Arguments:    none

Return Values:
   Flash_OperationOngoing
   Flash_OperationTimeOut
   Flash_Success

Description:  This function erases the whole Flash memory by sending an
              SPI_FLASH_INS_BE Instruction.
Note:
			  (Only for N25QxxxA8 devices)

              This function does not check whether the target memory area (or part of it)
			  is in a Software Protection Mode(SPM) or Hardware Protection Mode(HPM),
			  in which case the PP Instruction will be ignored.
              The function assumes that the target memory area has previously been unprotected at both
              the hardware and software levels.
              To unprotect the memory, please call FlashWriteStatusRegister(NMX_uint8 ucStatusRegister),
              and refer to the datasheet to set a proper ucStatusRegister value.

Pseudo Code:
   Step 1: Check whether any previous Write, Program or Erase cycle is on going
   Step 2: Disable the Write protection (the Flash memory will automatically enable it
           again after the execution of the Instruction)
   Step 3: Initialize the data (Instruction & address) packet to be sent serially
   Step 4: Send the packet (Instruction & address) serially
   Step 5: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
#ifdef SUPPORT_N25Q_STEP_B
ReturnType FlashBulkErase( void )
{
	CharStream char_stream_send;
	NMX_uint8  cBE = SPI_FLASH_INS_BE;
	NMX_uint8 fsr_value;
	ReturnType ret;

	// Step 1: Check whether any previous Write, Program or Erase cycle is on going
	if(IsFlashBusy()) return Flash_OperationOngoing;

	// Step 2: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 3: Initialize the data(Instruction & address) packet to be sent serially
	char_stream_send.length   = 1;
	char_stream_send.pChar    = &cBE;

	// Step 4: Send the packet(Instruction & address) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 5: Wait until the operation completes or a timeout occurs.
	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(BE_TIMEOUT);

	FlashReadFlagStatusRegister(&fsr_value);
	FlashClearFlagStatusRegister();

	if((fsr_value & SPI_FSR_PROT) && (fsr_value & SPI_FSR_ERASE))
		return Flash_SectorProtected;

	return ret;
}
#endif

/*******************************************************************************
Function:     IsFlashBusy(void)
Arguments:    none

Return Value:
   TRUE
   FALSE

Description:  This function checks the Write In Progress (WIP) bit to determine whether
              the Flash memory is busy with a Write, Program or Erase cycle.

Pseudo Code:
   Step 1: Read the Status Register/Flag Status Register.
   Step 2: Check if busy.
*******************************************************************************/
BOOL IsFlashBusy(void)
{

	NMX_uint8 ucSR;
	NMX_uint8 CheckBit;

	// Step 1: Read the Status Register.
	if((fdo->Desc.FlashId == MEM_TYPE_N25Q512_V3) || (fdo->Desc.FlashId == MEM_TYPE_N25Q1G) || (fdo->Desc.FlashId == MEM_TYPE_N25Q512_V18))
	{
		FlashReadFlagStatusRegister(&ucSR);
		CheckBit = SPI_FSR_PROG_ERASE_CTL;
		if( !(ucSR & CheckBit))//for this,please refer to N25Q256/N25Q00 datasheet.
			return TRUE;
	}
	else
	{
		FlashReadStatusRegister(&ucSR);
		CheckBit = SPI_FLASH_WIP;
		if(ucSR & CheckBit)
			return TRUE;
	}
	return FALSE;
}

/*******************************************************************************
Function:     IsFlashWELBusy( )
Arguments:    none

Return Value:
   TRUE
   FALSE

Description:  This function checks the Write Enable bit to determine whether
              the Flash memory is busy with a Write Enable or Write Disable Op.

Pseudo Code:
   Step 1: Read the Status Register.
   Step 2: Check the WEL bit.
*******************************************************************************/
BOOL IsFlashWELBusy(void)
{
	NMX_uint8 ucSR;

	// Step 1: Read the Status Register.
	FlashReadStatusRegister(&ucSR);

	// Step 2: Check the WEL bit.
	if(ucSR & SPI_FLASH_WEL)
		return TRUE;
	else
		return FALSE;
}

/*******************************************************************************
Function:     	FlashDataProgram( )
*******************************************************************************/
ReturnType FlashDataProgram(uAddrType udAddr, NMX_uint8 *pArray , NMX_uint16 udNrOfElementsInArray, NMX_uint8 ubSpiInstruction)
{
	ReturnType retValue = Flash_Success;
	NMX_uint16 dataOffset;

	// Enabling the Write
	fdo->GenOp.WriteEnable();

	if (retValue != Flash_Success)
		return retValue;

	// Computing the starting alignment, i.e. the distance from the 64 bytes boundary
	dataOffset = (fdo->Desc.FlashPageSize - (udAddr & fdo->Desc.FlashAddressMask) ) & fdo->Desc.FlashAddressMask;
	if (dataOffset > udNrOfElementsInArray)
		dataOffset = udNrOfElementsInArray;
	if (dataOffset > 0)
	{
		retValue = FlashGenProgram(udAddr, pArray, dataOffset, ubSpiInstruction);
		if (Flash_Success != retValue)
			return retValue;
	}

	for ( ; (dataOffset+fdo->Desc.FlashPageSize) < udNrOfElementsInArray; dataOffset += fdo->Desc.FlashPageSize)
	{
		retValue = FlashGenProgram(udAddr+dataOffset, pArray+dataOffset, fdo->Desc.FlashPageSize, ubSpiInstruction);
		if (Flash_Success != retValue)
			return retValue;
	}

	if (udNrOfElementsInArray > dataOffset)
		retValue = FlashGenProgram(udAddr+dataOffset, pArray+dataOffset, (udNrOfElementsInArray-dataOffset), ubSpiInstruction);

	return retValue;
}

/*******************************************************************************
Function:     ReturnType FlashProgramEraseResume( void )
Arguments:    none

Return Values:
   Flash_Success

Description:  This function resumes the program/erase operation suspended by sending an
              SPI_FLASH_INS_PER Instruction.
Note:

Pseudo Code:
   Step 1: Check whether any previous Write, Program or Erase cycle is suspended
   Step 2: Initialize the data (Instruction & address) packet to be sent serially
   Step 3: Send the packet (Instruction & address) serially
 ******************************************************************************/
ReturnType  FlashProgramEraseResume( void )
{
	/* not implemented */
	return Flash_FunctionNotSupported;
}

/*******************************************************************************
Function:     ReturnType FlashProgramEraseSuspend( void )
Arguments:    none

Return Values:
   Flash_Success

Description:  This function resumes the program/erase operation suspended by sending an
              SPI_FLASH_INS_PES Instruction.
Note:

Pseudo Code:
   Step 1: Initialize the data (Instruction) packet to be sent serially
   Step 2: Send the packet (Instruction) serially
 ******************************************************************************/
ReturnType  FlashProgramEraseSuspend( void )
{
	/* not implemented */
	return Flash_FunctionNotSupported;
}


/*******************************************************************************
Function:     FlashReadFlagStatusRegister( NMX_uint8 *ucpFlagStatusRegister)    ----ok
Arguments:    ucpFlagStatusRegister, 8-bit buffer to hold the Flag Status Register value read
              from the memory

Return Value:
   Flash_Success

Description:  This function reads the Status Register by sending an
               SPI_FLASH_INS_CLFSR Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially

*******************************************************************************/
ReturnType  FlashClearFlagStatusRegister( void )
{
	CharStream char_stream_send;
	NMX_uint8  cCLFSR = SPI_FLASH_INS_CLFSR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cCLFSR;

	// Step 2: Send the packet serially, get the Status Register content
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashReadNVConfigurationRegister( NMX_uint16 *ucpNVConfigurationRegister)
Arguments:    ucpStatusRegister, 16-bit buffer to hold the Non Volatile Configuration Register
		value read from the memory

Return Value:
   Flash_Success

Description:  This function reads the Non Volatile Configuration Register by sending an
               SPI_FLASH_INS_RDNVCR Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially, get the Configuration Register content

*******************************************************************************/
ReturnType  FlashReadNVConfigurationRegister(NMX_uint16 *ucpNVConfigurationRegister)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  cRDNVCR = SPI_FLASH_INS_RDNVCR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cRDNVCR;
	char_stream_recv.length  = 2;
	char_stream_recv.pChar   = (NMX_uint8 *)ucpNVConfigurationRegister;

	// Step 2: Send the packet serially, get the Status Register content
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashReadVolatileConfigurationRegister( NMX_uint8 *ucpVolatileConfigurationRegister)
Arguments:    ucpVolatileConfigurationRegister, 8-bit buffer to hold the Volatile Configuration Register
		value read from the memory

Return Value:
   Flash_Success

Description:  This function reads the Volatile Register by sending an
               SPI_FLASH_INS_RDVCR Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially, get the Configuration Register content

*******************************************************************************/
ReturnType  FlashReadVolatileConfigurationRegister( NMX_uint8 *ucpVolatileConfigurationRegister)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  cRDVCR = SPI_FLASH_INS_RDVCR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cRDVCR;
	char_stream_recv.length  = 1;
	char_stream_recv.pChar   = ucpVolatileConfigurationRegister;

	// Step 2: Send the packet serially, get the Volatile Configuration Register content
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashReadVolatileEnhancedConfigurationRegister( NMX_uint8 *ucpVolatileEnhancedConfigurationRegister)
Arguments:    ucpVolatileEnhancedRegister, 8-bit buffer to hold the Volatile Enhanced Configuration Register
		value read from the memory

Return Value:
   Flash_Success

Description:  This function reads the Volatile Enhanced Register by sending an
               SPI_FLASH_INS_RDVECR Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially, get the Configuration Register content

*******************************************************************************/
ReturnType  FlashReadVolatileEnhancedConfigurationRegister( NMX_uint8 *ucpVolatileEnhancedConfigurationRegister)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  cRDVECR = SPI_FLASH_INS_RDVECR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cRDVECR;
	char_stream_recv.length  = 1;
	char_stream_recv.pChar   = ucpVolatileEnhancedConfigurationRegister;

	// Step 2: Send the packet serially, get the Volatile Enhanced Configuration Register content
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashReadFlagStatusRegister( NMX_uint8 *ucp FlagStatusRegister)
Arguments:    ucpStatusRegister, 8-bit buffer to hold the Flag Status Register value read
              from the memory

Return Value:
   Flash_Success

Description:  This function reads the Status Register by sending an
               SPI_FLASH_INS_RFSR Instruction.

Pseudo Code:
   Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
   Step 2: Send the packet serially, get the Status Register content

*******************************************************************************/
ReturnType  FlashReadFlagStatusRegister( NMX_uint8 *ucpFlagStatusRegister)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  cRFSR = SPI_FLASH_INS_RFSR;

	// Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length  = 1;
	char_stream_send.pChar   = &cRFSR;
	char_stream_recv.length  = 1;
	char_stream_recv.pChar   = ucpFlagStatusRegister;

	// Step 2: Send the packet serially, get the Status Register content
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function:     FlashWriteVolatileConfigurationRegister( NMX_uint8 ucVolatileConfigurationRegister)
Arguments:    ucVolatileConfigurationRegister, an 8-bit new value to be written to the Volatile Configuration Register

Return Value:
   Flash_Success

Description:  This function modifies the Volatile Configuration Register by sending an
              SPI_FLASH_INS_WRVCR Instruction.
              The Write Volatile Configuration Register (WRVCR) Instruction has effect immediatly

Pseudo Code:
   Step 1: Disable Write protection
   Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
   Step 3: Send the packet serially
   Step 4: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType  FlashWriteVolatileConfigurationRegister( NMX_uint8 ucVolatileConfigurationRegister)
{
	CharStream char_stream_send;
	NMX_uint8  pIns_Val[2];

	// Step 1: Disable Write protection
	FlashWriteEnable();

	// Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
	char_stream_send.length = 2;
	char_stream_send.pChar  = pIns_Val;
	pIns_Val[0] = SPI_FLASH_INS_WRVCR;
	pIns_Val[1] = ucVolatileConfigurationRegister;

	// Step 3: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	//SPI_setXiPMode(ucVolatileConfigurationRegister);

	// Step 4: Wait until the operation completes or a timeout occurs.
	return WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);
}


/*******************************************************************************
Function:     FlashWriteVolatileEnhancedConfigurationRegister( NMX_uint8 ucVolatileEnhancedConfigurationRegister)
Arguments:    ucVolatileConfigurationRegister, an 8-bit new value to be written to the Volatile Enhanced Configuration Register

Return Value:
   Flash_Success

Description:  This function modifies the Volatile Enhanced Configuration Register by sending an
              SPI_FLASH_INS_WRVECR Instruction.
              The Write Volatile Enhanced Configuration Register (WRVECR) Instruction has effect immediatly

Pseudo Code:
   Step 1: Disable Write protection
   Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
   Step 3: Send the packet serially
   Step 5: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType  FlashWriteVolatileEnhancedConfigurationRegister( NMX_uint8 ucVolatileEnhancedConfigurationRegister)
{
	CharStream char_stream_send;
	NMX_uint8  pIns_Val[2];

	// Step 1: Disable Write protection
	FlashWriteEnable();

	// Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
	char_stream_send.length = 2;
	char_stream_send.pChar  = pIns_Val;
	pIns_Val[0] = SPI_FLASH_INS_WRVECR;
	pIns_Val[1] = ucVolatileEnhancedConfigurationRegister;

	// Step 3: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 5: Wait until the operation completes or a timeout occurs.
	return WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);
}

/*******************************************************************************
Function:     FlashWriteNVConfigurationRegister( NMX_uint16 ucNVConfigurationRegister)
Arguments:    ucVolatileConfigurationRegister, an 8-bit new value to be written to the Non Volatile Configuration Register

Return Value:
   Flash_Success

Description:  This function modifies the Non Volatile Configuration Register by sending an
              SPI_FLASH_INS_WRNVCR Instruction.
              The Write Non Volatile Configuration Register (WRVECR) Instruction has effect at the next power-on

Pseudo Code:
   Step 1: Disable Write protection
   Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
   Step 3: Send the packet serially
   Step 4: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType  FlashWriteNVConfigurationRegister( NMX_uint16 ucNVConfigurationRegister)
{
	CharStream char_stream_send;
	NMX_uint8  pIns_Val[3];

	// Step 1: Disable Write protection
	FlashWriteEnable();

	// Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
	char_stream_send.length = 3;
	char_stream_send.pChar  = pIns_Val;
	pIns_Val[0] = SPI_FLASH_INS_WRNVCR;
	pIns_Val[1] = (ucNVConfigurationRegister >> 8)& 0xFF;
	pIns_Val[2] = ucNVConfigurationRegister & 0xFF;

	// Step 3: Send the packet serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 4: Wait until the operation completes or a timeout occurs.
	return WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);
}


#ifdef VERBOSE
/*******************************************************************************
Function:     FlashErrorStr( ReturnType rErrNum );
Arguments:    rErrNum is the error number returned from other Flash memory Routines

Return Value: A pointer to a string with the error message

Description:  This function is used to generate a text string describing the
   error from the Flash memory. Call with the return value from other Flash memory routines.

Pseudo Code:
   Step 1: Return the correct string.
*******************************************************************************/
NMX_sint8 *FlashErrorStr( ReturnType rErrNum )
{
	switch(rErrNum)
	{
	case Flash_AddressInvalid:
		return "Flash - Address is out of Range";
	case Flash_MemoryOverflow:
		return "Flash - Memory Overflows";
	case Flash_PageEraseFailed:
		return "Flash - Page Erase failed";
	case Flash_PageNrInvalid:
		return "Flash - Page Number is out of Range";
	case Flash_SectorNrInvalid:
		return "Flash - Sector Number is out of Range";
	case Flash_FunctionNotSupported:
		return "Flash - Function not supported";
	case Flash_NoInformationAvailable:
		return "Flash - No Additional Information Available";
	case Flash_OperationOngoing:
		return "Flash - Operation ongoing";
	case Flash_OperationTimeOut:
		return "Flash - Operation TimeOut";
	case Flash_ProgramFailed:
		return "Flash - Program failed";
	case Flash_Success:
		return "Flash - Success";
	case Flash_WrongType:
		return "Flash - Wrong Type";
	default:
		return "Flash - Undefined Error Value";
	} /* EndSwitch */
} /* EndFunction FlashErrorString */
#endif /* VERBOSE Definition */


/*******************************************************************************
Function:     FlashTimeOut(NMX_uint32 udSeconds)
Arguments:    udSeconds holds the number of seconds before TimeOut occurs

Return Value:
   Flash_OperationTimeOut
   Flash_OperationOngoing

Example:   FlashTimeOut(0)  // Initializes the Timer

           While(1) {
              ...
              If (FlashTimeOut(5) == Flash_OperationTimeOut) break;
              // The loop is executed for 5 Seconds before the operation is aborted
           } EndWhile

*******************************************************************************/
#ifdef TIME_H_EXISTS
/*-----------------------------------------------------------------------------
Description:   This function provides a timeout for Flash polling actions or
   other operations which would otherwise never return.
   The Routine uses the function clock() inside ANSI C library "time.h".
-----------------------------------------------------------------------------*/
ReturnType FlashTimeOut(NMX_uint32 udSeconds)
{
	static clock_t clkReset,clkCount;

	if (udSeconds == 0)   /* Set Timeout to 0 */
	{
		clkReset=clock();
	} /* EndIf */

	clkCount = clock() - clkReset;

	if (clkCount<(CLOCKS_PER_SEC*(clock_t)udSeconds))
		return Flash_OperationOngoing;
	else
		return Flash_OperationTimeOut;
}/* EndFunction FlashTimeOut */

#else

/*-----------------------------------------------------------------------------
Description:   This function provides a timeout for Flash polling actions or
   other operations which would otherwise never return.
   The Routine uses COUNT_FOR_A_SECOND which is considered to be a loop that
   counts for one second. It needs to be adapted to the target Hardware.
-----------------------------------------------------------------------------*/
ReturnType FlashTimeOut(NMX_uint32 udSeconds)
{

	static NMX_uint32 udCounter = 0;
	if (udSeconds == 0)   /* Set Timeout to 0 */
	{
		udCounter = 0;
	} /* EndIf */

	if (udCounter >= (udSeconds * COUNT_FOR_A_SECOND))
	{
		udCounter = 0;
		return Flash_OperationTimeOut;
	}
	else
	{
		udCounter++;
		return Flash_OperationOngoing;
	} /* Endif */

} /* EndFunction FlashTimeOut */

#endif

/*-----------------------------------------------------------------------------
Description:   This function fill the vector in according with address mode
-----------------------------------------------------------------------------*/
void fill_addr_vect(uAddrType udAddr, NMX_uint8* pIns_Addr, NMX_uint8 num_address_byte)
{

	/* 3-addr byte mode */
	if(FLASH_3_BYTE_ADDR_MODE == num_address_byte)
	{
		pIns_Addr[1]              = udAddr>>16;
		pIns_Addr[2]              = udAddr>>8;
		pIns_Addr[3]              = udAddr;
	}

	/* 4-addr byte mode */
	if(FLASH_4_BYTE_ADDR_MODE == num_address_byte)
	{
		pIns_Addr[1]              = udAddr>>24;
		pIns_Addr[2]              = udAddr>>16;
		pIns_Addr[3]              = udAddr>>8;
		pIns_Addr[4]              = udAddr;
	}
	return;
}

/*-----------------------------------------------------------------------------
Description:   This function wait till instruction execution is complete
-----------------------------------------------------------------------------*/
ReturnType WAIT_TILL_Instruction_EXECUTION_COMPLETE(NMX_sint16 second)
{
	FlashTimeOut(0);
	while(IsFlashBusy())
	{
		if(Flash_OperationTimeOut == FlashTimeOut(second))
			return  Flash_OperationTimeOut;
	}
	return Flash_Success;
}


/*******************************************************************************
Function:     ReturnType FlashEnter4ByteAddressMode(void)
Arguments:

Return Value:
   Flash_Success

Description:  This function set the 4-byte-address mode

Pseudo Code:
   Step 1: Write enable
   Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
   Step 3: Send the packet serially
   Step 4: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType FlashEnter4ByteAddressMode(void)
{
	CharStream char_stream_send;
	NMX_uint8 cPER = SPI_FLASH_4B_MODE_ENTER;
	ReturnType ret;
	NMX_uint8 flag;

#ifndef SUPPORT_N25Q_STEP_B
	FlashWriteEnable();
#endif

	char_stream_send.length   = 1;
	char_stream_send.pChar    = &cPER;

	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

#ifdef N25Q_DEBUG
	CLI_printf("ENTER 4-byte-addr mode\n");
#endif

	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);

	/* verify current addr mode */
	fdo->GenOp.ReadFlagStatusRegister(&flag);
	if (flag & 1)
		fdo->Desc.NumAddrByte = FLASH_4_BYTE_ADDR_MODE;
	else
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

	return ret;
}

/*******************************************************************************
Function:     ReturnType FlashExit4ByteAddressMode(void)
Arguments:

Return Value:
   Flash_Success

Description:  This function unset 4-byte-address mode

Pseudo Code:
   Step 1: Write enable
   Step 2: Initialize the data (i.e. Instruction & value) packet to be sent serially
   Step 3: Send the packet serially
   Step 4: Wait until the operation completes or a timeout occurs.
*******************************************************************************/
ReturnType FlashExit4ByteAddressMode(void)
{
	CharStream char_stream_send;
	NMX_uint8 cPER = SPI_FLASH_4B_MODE_EXIT;
	ReturnType ret;
	NMX_uint8 flag;

#ifndef SUPPORT_N25Q_STEP_B
	FlashWriteEnable();
#endif

	char_stream_send.length   = 1;
	char_stream_send.pChar    = &cPER;

	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

#ifdef N25Q_DEBUG
	CLI_printf("EXIT 4-byte-addr mode\n");
#endif

	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);

	/* verify current addr mode */
	fdo->GenOp.ReadFlagStatusRegister(&flag);
	if (flag & 1)
		fdo->Desc.NumAddrByte = FLASH_4_BYTE_ADDR_MODE;
	else
		fdo->Desc.NumAddrByte = FLASH_3_BYTE_ADDR_MODE;

	return ret;
}

/*******************************************************************************
Function: FlashLockSector

Arguments: address, len

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashLockSector(uAddrType address,  NMX_uint32 len)
{
	NMX_uint8 TB, BP, SR;
	int i, protected_area, start_sector;
	int sector_size, num_of_sectors;

	sector_size = fdo->Desc.FlashSectorSize;
	num_of_sectors = fdo->Desc.FlashSectorCount;

	FlashWriteEnable();

	start_sector = address / sector_size;
	protected_area = len / sector_size;

	if (protected_area == 0 || protected_area > num_of_sectors)
		return Flash_AddressInvalid;

	//(pa & (pa - 1) == 0) verifica che pa sia una potenza di 2
	if ((start_sector != 0 && (start_sector + protected_area) != num_of_sectors) || (protected_area & (protected_area - 1)) != 0)
		return Flash_AddressInvalid;


	if (address/sector_size < num_of_sectors/2)
	{
		TB = 1;
	}
	else
	{
		TB = 0;
	}

	BP = 1;
	for (i = 1; i <= num_of_sectors; i = i*2)
	{
		if (protected_area == i)
		{
			break;
		}
		BP++;
	}

	SR = (((BP & 8) >> 3) << 6) | (TB << 5) | ((BP & 7) << 2);

	FlashWriteStatusRegister(SR);
	return Flash_Success;

}

/*******************************************************************************
Function: FlashUnlockAllSector

Arguments: (none)

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashUnlockAllSector(void)
{
	NMX_uint8 SR = 0;

	/* Set BP2, BP1, BP0 to 0 (all flash sectors unlocked) */
	FlashWriteStatusRegister(SR);

	return Flash_Success;
}
/* End of file */

/*******************************************************************************
Function: FlashOTPProgram

Arguments: *pArray, udNrOfElementsInArray

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashOTPProgram(NMX_uint8 *pArray , NMX_uint32 udNrOfElementsInArray)
{
	CharStream char_stream_send;
	NMX_uint8 i;
	NMX_uint8 pIns_Addr[5];
	NMX_uint8 sentBuffer[fdo->Desc.FlashOTPSize+1];
	NMX_uint32 udAddr;
	ReturnType ret;

	// Step 1: Validate address input
	if(udNrOfElementsInArray > fdo->Desc.FlashOTPSize)
		return Flash_AddressInvalid;

	/* Address is always 0x000000 */
	udAddr = 0x000000;

	/* Output buffer (with user data within) is fixed to 65 elements */
	for(i=0; i<udNrOfElementsInArray; i++)
		sentBuffer[i] = pArray[i];

	/* Fill the others bytes with 00 */
	for(i=udNrOfElementsInArray; i<fdo->Desc.FlashOTPSize; i++)
		sentBuffer[i] = 0x00;

	/* This is the byte 64, OTP Control byte (if bit 0 = 0 -> OTP Locked) */
	sentBuffer[fdo->Desc.FlashOTPSize] = 0;

	// Step 2: Check whether any previous Write, Program or Erase cycle is on-going
	if(IsFlashBusy())
		return Flash_OperationOngoing;

	// Step 3: Disable Write protection
	fdo->GenOp.WriteEnable();

	// Step 4: Initialize the data (Instruction & address only) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;
	char_stream_send.pChar    = pIns_Addr;

	pIns_Addr[0]              = SPI_FLASH_INS_PROTP;

	/* Always use 3 bytes address and address is 0x000000 */
	fill_addr_vect(udAddr, pIns_Addr, 3);

	// Step 5: Send the packet (Instruction & address only) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsInitTransfer);

	// Step 6: Initialize the data (data to be programmed) packet to be sent serially
	char_stream_send.length   = udNrOfElementsInArray;
	char_stream_send.pChar    = pArray;

	// Step 7: Send the packet (data to be programmed) serially
	Serialize_SPI(&char_stream_send,
	              NULL_PTR,
	              OpsWakeUp,
	              OpsEndTransfer);

	// Step 8: Wait until the operation completes or a timeout occurs.
	ret = WAIT_TILL_Instruction_EXECUTION_COMPLETE(1);

	return ret;
}

/*******************************************************************************
Function: FlashOTPRead

Arguments: *ucpElements, udNrOfElementsToRead

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashOTPRead(NMX_uint8 *ucpElements, NMX_uint32 udNrOfElementsToRead)
{
	CharStream char_stream_send;
	CharStream char_stream_recv;
	NMX_uint8  pIns_Addr[5];
	NMX_uint32 udAddr;

	/* Address is always 0x000000 */
	udAddr = 0x000000;

	// Step 2: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;
	char_stream_send.pChar    = pIns_Addr;
	pIns_Addr[0]              = SPI_FLASH_INS_RDOTP;

	fill_addr_vect(udAddr, pIns_Addr, 3);

	char_stream_recv.length   = udNrOfElementsToRead;
	char_stream_recv.pChar    = ucpElements;

	// Step 3: Send the packet serially, and fill the buffer with the data being returned
	Serialize_SPI(&char_stream_send,
	              &char_stream_recv,
	              OpsWakeUp,
	              OpsEndTransfer);

	return Flash_Success;
}

/*******************************************************************************
Function: FlashReadLockRegister

Arguments: uAddrType address,  NMX_uint8 * val

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashReadLockRegister(uAddrType address,  NMX_uint8 * val) 
{

	CharStream char_stream_send;
    CharStream char_stream_recv;
	NMX_uint8  pIns_Addr[5];

    // Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 1;
    char_stream_send.pChar    = pIns_Addr;
    pIns_Addr[0]              = SPI_FLASH_INS_RDLR;

	fill_addr_vect(address, pIns_Addr, fdo->Desc.NumAddrByte);

    char_stream_recv.length   = 1 ;
    char_stream_recv.pChar    = val;

    // Step 2: Send the packet serially, and fill the buffer with the data being returned
    Serialize_SPI(&char_stream_send,
              &char_stream_recv,
              OpsWakeUp,
              OpsEndTransfer);

    return Flash_Success;
}

/*******************************************************************************
Function: FlashWriteLockRegister

Arguments: uAddrType address,  NMX_uint8 * val

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashWriteLockRegister(uAddrType address,  NMX_uint8 * val) 
{

	CharStream char_stream_send;
	NMX_uint8  pIns_Addr[6];

	FlashWriteEnable();

    // Step 1: Initialize the data (i.e. Instruction) packet to be sent serially
	char_stream_send.length   = fdo->Desc.NumAddrByte + 2;
    char_stream_send.pChar    = pIns_Addr;
    pIns_Addr[0]              = SPI_FLASH_INS_CMD_WRLR;

	fill_addr_vect(address, pIns_Addr, fdo->Desc.NumAddrByte);
	pIns_Addr[fdo->Desc.NumAddrByte + 1] = *val;

	
    // Step 2: Send the packet serially, and fill the buffer with the data being returned
    Serialize_SPI(&char_stream_send,
					NULL_PTR,
					OpsWakeUp,
					OpsEndTransfer);


    return Flash_Success;
}

/*******************************************************************************
Function: FlashLockOneSector

Arguments: address

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashLockOneSector(uAddrType address) 
{

	NMX_uint8 LR;
	int sector_size;

	sector_size = fdo->Desc.FlashSectorSize;
    // Validate address input
    if(!(address < fdo->Desc.FlashSize))
		return Flash_AddressInvalid;
	//Read LR
	FlashReadLockRegister((address & (~(sector_size-1))),&LR);
	//Check sector write lock bit
	if(LR & 0x01)
		return Flash_Success;
	//Check write lock down bit
	if(LR & 0x02)
		return Flash_SectorLockDownFailed;
	
	LR = 0x01;
	FlashWriteLockRegister((address & (~(sector_size-1))),&LR);

	return Flash_Success;

}

/*******************************************************************************
Function: FlashUnlockOneSector

Arguments: address

Return Values: ReturnType

Description:

Note:

Pseudo Code:

*******************************************************************************/
ReturnType FlashUnlockOneSector(uAddrType address)
{
	NMX_uint8 LR;
	int sector_size;

	sector_size = fdo->Desc.FlashSectorSize;
    // Validate address input
    if(!(address < fdo->Desc.FlashSize))
		return Flash_AddressInvalid;
	//Read LR
	FlashReadLockRegister((address & (~(sector_size-1))),&LR);
	//Check sector write lock bit
	if(!(LR & 0x01))
		return Flash_Success;
	//Check write down lock bit
	if(LR & 0x02)
		return Flash_SectorLockDownFailed;
	
	LR = 0x00;
	FlashWriteLockRegister((address & (~(sector_size-1))),&LR);

	return Flash_Success;

}
