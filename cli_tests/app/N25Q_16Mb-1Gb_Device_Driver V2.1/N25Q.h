/*
 *
 *  Header File for STFL-I based Serial Flash Memory Driver
 *
 *
 *  Filename:		N25Q.c
 *  Description:	Header file for N25Q driver.
 *		        	Also consult the C file for more details.
 *
 *  Version:		2.1
 *  Date:			Aug 2015
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
 *  1.8			October 2014        Added read flag status register for N25Q512Mb/N25Q1Gb device in the IsFlashBusy()
 *	1.9			January 2015		Fixed inconsistent function declaration
 *	2.0			February 2015		Fixed some compilation warnings
 *									Fixed the issue of IsflashBusy() cann't detect correct status
 *									Fixed one potential bug of  FlashWriteNVConfigurationRegister doesn't send the correct value.
 *	2.1			August 2015			added write/read lock register function
 */

/*************** User Change Area *******************************************

   The purpose of this section is to show how the SW Drivers can be customized
   according to the requirements of the hardware and Flash memory configurations.
   It is possible to choose the Flash memory start address, the CPU Bit depth, the number of Flash
   chips, the hardware configuration and performance data (TimeOut Info).

   The options are listed and explained below:

   ********* Data Types *********
   The source code defines hardware independent datatypes assuming that the
   compiler implements the numerical types as

   unsigned char    8 bits (defined as NMX_uint8)
   char             8 bits (defined as NMX_sint8)
   unsigned int     16 bits (defined as NMX_uint16)
   int              16 bits (defined as NMX_sint16)
   unsigned long    32 bits (defined as NMX_uint32)
   long             32 bits (defined as NMX_sint32)

   In case the compiler does not support the currently used numerical types,
   they can be easily changed just once here in the user area of the headerfile.
   The data types are consequently referenced in the source code as (u)NMX_sint8,
   (u)NMX_sint16 and (u)NMX_sint32. No other data types like 'CHAR','SHORT','INT','LONG'
   are directly used in the code.


   ********* Flash Type *********
   This driver supports the following Serial Flash memory Types:

	- N25Q 8M
	- N25Q 16M
	- N25Q 32M
	- N25Q 64M
	- N25Q 128M
	- N25Q 256M
	- N25Q 256M (N25Q256A8X)
	- N25Q 512M
	- N25Q 1G

   ********* Flash and Board Configuration *********
   The driver also supports different configurations of the Flash chips
   on the board. In each configuration a new data Type called
   'uCPUBusType' is defined to match the current CPU data bus width.
   This data type is then used for all accesses to the memory.

   Because SPI interface communications are controlled by the
   SPI master, which, in turn, is accessed by the CPU as an 8-bit data
   buffer, the configuration is fixed for all cases.

   ********* TimeOut *********
   There are timeouts implemented in the loops of the code, in order
   to enable a timeout detection for operations that would otherwise never terminate.
   There are two possibilities:

   1) The ANSI Library functions declared in 'time.h' exist

      If the current compiler supports 'time.h' the define statement
      TIME_H_EXISTS should be activated. This makes sure that
      the performance of the current evaluation HW does not change
      the timeout settings.

   2) or they are not available (COUNT_FOR_A_SECOND)

      If the current compiler does not support 'time.h', the define
      statement cannot be used. In this case the COUNT_FOR_A_SECOND
      value has to be defined so as to create a one-second delay.
      For example, if 100000 repetitions of a loop are
      needed to give a time delay of one second, then
      COUNT_FOR_A_SECOND should have the value 100000.

      Note: This delay is HW (Performance) dependent and therefore needs
      to be updated with every new HW.

      This driver has been tested with a certain configuration and other
      target platforms may have other performance data, therefore, the
      value may have to be changed.

      It is up to the user to implement this value to prevent the code
      from timing out too early and allow correct completion of the device
      operations.


   ********* Additional Routines *********
   The drivers also provide a subroutine which displays the full
   error message instead of just an error number.

   The define statement VERBOSE activates additional Routines.
   Currently it activates the FlashErrorStr() function

   No further changes should be necessary.

*****************************************************************************/


#ifndef __SERIAL__H__
#define __SERIAL__H__

#define DRIVER_VERSION_MAJOR 0
#define DRIVER_VERSION_MINOR 1

/* All HW dependent Basic Data Types */
typedef unsigned char	NMX_uint8;
typedef signed char		NMX_sint8;
typedef unsigned int	NMX_uint16;
typedef int				NMX_sint16;
typedef unsigned long	NMX_uint32;
typedef long			NMX_sint32;

#define N25Q_DEBUG 1
/* Enable device auto detect on init */
#define ADDR_MODE_AUTO_DETECT

/* This define enables N25QxxxA8xExxxxx devices 							*/
/* (with this define, driver use the alternative command set)				*/
//#define SUPPORT_N25Q_STEP_B

/*******************************************************************************
Flash address byte mode (see Datasheet)
*******************************************************************************/
typedef enum
{
	FLASH_3_BYTE_ADDR_MODE	= 0x03,			/* 3 byte address */
	FLASH_4_BYTE_ADDR_MODE	= 0x04			/* 4 byte address */

} AddressMode;

/*#define TIME_H_EXISTS*/  /* set this macro if C-library "time.h" is supported */
/* Possible Values: TIME_H_EXISTS
                    - no define - TIME_H_EXISTS */

#ifndef TIME_H_EXISTS
#define COUNT_FOR_A_SECOND 0xFFFFFF   				/* Timer Usage */
#endif

#define SE_TIMEOUT (3)                					/* Timeout in seconds suggested for Sector Erase Operation*/
#define BE_TIMEOUT  (480)           						/* Timeout in seconds suggested for Bulk Erase Operation*/
#define DIE_TIMEOUT (480)					/* Timeout in seconds suggested for Die Erase Operation*/
/* Activates additional Routines */
//#define VERBOSE
//#define DEBUG

/********************** End of User Change Area *****************************/

/*******************************************************************************
	Device Constants
*******************************************************************************/

/* manufacturer id + mem type + mem capacity  */
#define MEM_TYPE_N25Q8		0x20BB14	/* ID for N25Q   8M device */
#define MEM_TYPE_N25Q16		0x20BB15	/* ID for N25Q  16M device */
#define MEM_TYPE_N25Q32		0x20BA16	/* ID for N25Q  32M device */
#define MEM_TYPE_N25Q64		0x20BA17	/* ID for N25Q  64M device */
#define MEM_TYPE_N25Q128	0x20BA18	/* ID for N25Q 128M device */
#define MEM_TYPE_N25Q256	0x20BA19	/* ID for N25Q 256M device */
#define MEM_TYPE_N25Q512_V3	0x20BA20	/* ID for N25Q 512M device for operating voltage 3v  */
#define MEM_TYPE_N25Q512_V18 0x20BB20	/* ID for N25Q 512M device for operating voltage 1.8v */
#define MEM_TYPE_N25Q1G		0x20BA21	/* ID for N25Q   1G device */
#define MEM_TYPE_MICRON     0x20B000    /* first ID byte */
#define MEM_TYPE_MASK       0xFFF000


#define DISCOVERY_TABLE1                0x0C
#define DTABLE1_SECTOR_DESCRIPTOR       0x1C
#define DTABLE1_FLASH_SIZE              0x04
/*******************************************************************************
	DERIVED DATATYPES
*******************************************************************************/
/******** InstructionsCode ********/
enum
{
	/* Command definitions (please see datasheet for more details) */

	/* RESET Operations */
	SPI_FLASH_INS_REN		  			= 0x66,	/* reset enable */
	SPI_FLASH_INS_RMEM		  			= 0x99,	/* reset memory */

	/* IDENTIFICATION Operations */
	SPI_FLASH_INS_RDID        			= 0x9F,	/* read Identification */
	SPI_FLASH_INS_RDID_ALT    			= 0x9E,	/* read Identification */
	SPI_FLASH_INS_MULT_IO_RDID   		= 0xAF, /* read multiple i/o read id */
	SPI_FLASH_INS_DISCOVER_PARAMETER	= 0x5A, /* read serial flash discovery parameter */

	/* READ operations */
	SPI_FLASH_INS_READ        			= 0x03,	/* read data bytes */
	SPI_FLASH_INS_FAST_READ   			= 0x0B,	/* read data bytes at higher speed */
	SPI_FLASH_INS_DOFR       			= 0x3B,	/* dual output Fast Read */
	SPI_FLASH_INS_DIOFR					= 0x0B, /* dual input output Fast Read */
	SPI_FLASH_INS_DIOFR_ALT1			= 0x3B, /* dual input output Fast Read */
	SPI_FLASH_INS_DIOFR_ALT2   			= 0xBB,	/* dual input output Fast Read */
	SPI_FLASH_INS_QOFR        			= 0x6B,	/* quad output Fast Read */
	SPI_FLASH_INS_QIOFR					= 0x0B, /* quad output Fast Read */
	SPI_FLASH_INS_QIOFR_ALT1			= 0x6B, /* quad input/output Fast Read */
	SPI_FLASH_INS_QIOFR_ALT2   			= 0xEB,	/* quad input output Fast Read */

	/* WRITE operations */
	SPI_FLASH_INS_WREN        			= 0x06,	/* write enable */
	SPI_FLASH_INS_WRDI        			= 0x04,	/* write disable */

	/* REGISTER operations */
	SPI_FLASH_INS_RDSR      			= 0x05,	/* read status register */
	SPI_FLASH_INS_WRSR      			= 0x01,	/* write status register */
	SPI_FLASH_INS_RDLR                  = 0xE8, /* read lock register */
	SPI_FLASH_INS_CMD_WRLR              = 0xE5, /* write lock register */
	SPI_FLASH_INS_RFSR     			 	= 0x70,	/* read flag status register */
	SPI_FLASH_INS_CLFSR     			= 0x50,	/* clear flag status register */
	SPI_FLASH_INS_RDNVCR    			= 0xB5,	/* read non volatile configuration register */
	SPI_FLASH_INS_WRNVCR    			= 0xB1,	/* write non volatile configuration register */
	SPI_FLASH_INS_RDVCR     			= 0x85,	/* read volatile configuration register */
	SPI_FLASH_INS_WRVCR     			= 0x81,	/* write volatile configuration register */
	SPI_FLASH_INS_RDVECR    			= 0x65,	/* read volatile enhanced configuration register */
	SPI_FLASH_INS_WRVECR    			= 0x61,	/* write volatile enhanced configuration register */

	/* PROGRAM operations */
	SPI_FLASH_INS_PP          			= 0x02,	/* PAGE PROGRAM */
#ifdef SUPPORT_N25Q_STEP_B
	SPI_FLASH_INS_PP4B					= 0x12, /* 4-BYTE PAGE PROGRAM (N25QxxxA8 only) */
#endif
	SPI_FLASH_INS_DIPP        			= 0xA2,	/* DUAL INPUT FAST PROGRAM */
	SPI_FLASH_INS_DIEPP					= 0x02, /* EXTENDED DUAL INPUT FAST PROGRAM */
	SPI_FLASH_INS_DIEPP_ALT1			= 0xA2, /* EXTENDED DUAL INPUT FAST PROGRAM (alt 1) */
	SPI_FLASH_INS_DIEPP_ALT2   			= 0xD2,	/* EXTENDED DUAL INPUT FAST PROGRAM (alt 2) */
	SPI_FLASH_INS_QIPP        			= 0x32,	/* QUAD INPUT FAST PROGRAM */
#ifdef SUPPORT_N25Q_STEP_B
	SPI_FLASH_INS_QIPP4B				= 0x34, /* 4-BYTE QUAD INPUT FAST PROGRAM (N25QxxxA8 only) */
#endif
	SPI_FLASH_INS_QIEPP					= 0x02, /* EXTENDED QUAD INPUT FAST PROGRAM */
	SPI_FLASH_INS_QIEPP_ALT1			= 0x32, /* EXTENDED QUAD INPUT FAST PROGRAM (alt 1) */
	SPI_FLASH_INS_QIEPP_ALT2			= 0x38, /* EXTENDED QUAD INPUT FAST PROGRAM */
#ifndef SUPPORT_N25Q_STEP_B
	SPI_FLASH_INS_QIEPP_ALT3			= 0x12, /* EXTENDED QUAD INPUT FAST PROGRAM (do not use in N25QxxxA8) */
#endif

	/* ERASE operations */
	SPI_FLASH_INS_SSE         			= 0x20,	/* sub sector erase */
#ifdef SUPPORT_N25Q_STEP_B
	SPI_FLASH_INS_SSE4B					= 0x21, /* sub sector erase (N25QxxxA8 only) */
#endif
	SPI_FLASH_INS_SE          			= 0xD8,	/* sector erase */
#ifdef SUPPORT_N25Q_STEP_B
	SPI_FLASH_INS_SE4B					= 0xDC, /* sector erase (N25QxxxA8 only) */
#endif
	SPI_FLASH_INS_DE		  			= 0xC4,	/* die erase */
#ifdef SUPPORT_N25Q_STEP_B
	SPI_FLASH_INS_BE          			= 0xC7,	/* bulk erase (N25QxxxA8 only) */
#endif

	SPI_FLASH_INS_PER         			= 0x7A,	/* program Erase Resume */
	SPI_FLASH_INS_PES         			= 0x75,	/* program Erase Suspend */

	/* OTP operations */
	SPI_FLASH_INS_RDOTP					= 0x4B, /* read OTP array */
	SPI_FLASH_INS_PROTP					= 0x42, /* program OTP array */

	/* 4-BYTE ADDRESS operation  */
	SPI_FLASH_4B_MODE_ENTER   			= 0xB7,	/* enter 4-byte address mode */
	SPI_FLASH_4B_MODE_EXIT	  			= 0xE9,	/* exit 4-byte address mode */

	/* DEEP POWER-DOWN operation */
	SPI_FLASH_INS_ENTERDPD				= 0xB9, /* enter deep power-down */
	SPI_FLASH_INS_RELEASEDPD			= 0xA8  /* release deep power-down */
};

/******** InstructionsType ********/
typedef enum
{
	InstructionWriteEnable,
	InstructionWriteDisable,

	ReadDeviceIdentification,
	ReadManufacturerIdentification,

	ReadStatusRegister,
	WriteStatusRegister,

	Read,
	FastRead,
	DualOutputFastRead,
	DualInputOutputFastRead,
	QuadOutputFastRead,
	QuadInputOutputFastRead,
	ReadFlashDiscovery,

	PageProgram,
	DualInputProgram,
	DualInputExtendedFastProgram,
	QuadInputProgram,
	QuadInputExtendedFastProgram,

	SubSectorErase,
	SectorErase,
	DieErase,
	BulkErase,
} InstructionType;

/******** ReturnType ********/
typedef enum
{
	Flash_Success,
	Flash_AddressInvalid,
	Flash_MemoryOverflow,
	Flash_PageEraseFailed,
	Flash_PageNrInvalid,
	Flash_SubSectorNrInvalid,
	Flash_SectorNrInvalid,
	Flash_FunctionNotSupported,
	Flash_NoInformationAvailable,
	Flash_OperationOngoing,
	Flash_OperationTimeOut,
	Flash_ProgramFailed,
	Flash_SectorProtected,
	Flash_SectorUnprotected,
	Flash_SectorProtectFailed,
	Flash_SectorUnprotectFailed,
	Flash_SectorLocked,
	Flash_SectorUnlocked,
	Flash_SectorLockDownFailed,
	Flash_WrongType
} ReturnType;

/******** SectorType ********/
typedef NMX_uint16 uSectorType; // since N25Q256

/******** SubSectorType ********/
typedef NMX_uint16 uSubSectorType;

/******** PageType ********/
typedef NMX_uint16 uPageType;

/******** AddrType ********/
typedef NMX_uint32 uAddrType;

/******** ParameterType ********/
typedef union
{
	/**** WriteEnable has no parameters ****/

	/**** WriteDisable has no parameters ****/

	/**** ReadDeviceIdentification Parameters ****/
	struct
	{
		NMX_uint32 ucDeviceIdentification;
	} ReadDeviceIdentification;

	/**** ReadManufacturerIdentification Parameters ****/
	struct
	{
		NMX_uint8 ucManufacturerIdentification;
	} ReadManufacturerIdentification;

	/**** ReadStatusRegister Parameters ****/
	struct
	{
		NMX_uint8 ucStatusRegister;
	} ReadStatusRegister;

	/**** WriteStatusRegister Parameters ****/
	struct
	{
		NMX_uint8 ucStatusRegister;
	} WriteStatusRegister;

	/**** Read Parameters ****/
	struct
	{
		uAddrType udAddr;
		NMX_uint32 udNrOfElementsToRead;
		void *pArray;
	} Read;

	/**** PageProgram Parameters ****/
	struct
	{
		uAddrType udAddr;
		NMX_uint32 udNrOfElementsInArray;
		void *pArray;
	} PageProgram;

	/**** SectorErase Parameters ****/
	struct
	{
		uSectorType ustSectorNr;
	} SectorErase;

	/***** BulkErase has no parameters ****/

	/**** Clear  has no parameters ****/

} ParameterType;


typedef struct _FLASH_DESCRIPTION
{
	NMX_uint32		FlashId;
	NMX_uint8		FlashType;
	NMX_uint32 		StartingAddress;	/* Start Address of the Flash Device */
	NMX_uint32 		FlashAddressMask;
	NMX_uint32 		FlashSectorCount;
	NMX_uint32 		FlashSubSectorCount;
	NMX_uint32		FlashSubSectorSize_bit;
	NMX_uint32 		FlashPageSize;
	NMX_uint32		FlashPageCount;
	NMX_uint32		FlashSectorSize;
	NMX_uint32		FlashSectorSize_bit;
	NMX_uint32		FlashSubSectorSize;
	NMX_uint32 		FlashSize;
	NMX_uint32		FlashOTPSize;
	NMX_uint8		FlashDieCount;
	NMX_uint32		FlashDieSize;
	NMX_uint32		FlashDieSize_bit;
	NMX_uint32		Size;				/* The density of flash device in bytes */
	NMX_uint32		BufferSize;			/* In bytes */
	NMX_uint8		DataWidth;			/* In bytes */
	AddressMode		NumAddrByte;		/* Num of bytes used to address memory */

}  FLASH_DESCRIPTION, *PFLASH_DESCRIPTION;

/* FLASH_OPERATION
 *
 * This object set low-level flash device operations
 */

typedef struct _FLASH_OPERATION
{
	uAddrType  (*BlockOffset)(uSectorType);
	ReturnType (*DeviceId)(NMX_uint32 * );
	ReturnType (*ReadStatusRegister)(NMX_uint8 *);
	ReturnType (*DataProgram)(InstructionType, ParameterType *);
	ReturnType (*DataRead)(InstructionType, ParameterType *);
	ReturnType (*SectorErase)(uSectorType);
	ReturnType (*SubSectorErase)(uSectorType);
	ReturnType (*DieErase)(uSectorType);
	ReturnType (*BulkErase)(uSectorType);
	ReturnType (*WriteEnable)(void);
	ReturnType (*WriteDisable)(void);
	ReturnType (*ProgramEraseSuspend)(void);
	ReturnType (*ProgramEraseResume)(void);
	ReturnType (*ClearFlagStatusRegister)(void);
	ReturnType (*ReadNVConfigurationRegister)(NMX_uint16 *);
	ReturnType (*ReadVolatileConfigurationRegister)(NMX_uint8 *);
	ReturnType (*ReadVolatileEnhancedConfigurationRegister)(NMX_uint8 *);
	ReturnType (*ReadFlagStatusRegister)(NMX_uint8 *);
	ReturnType (*WriteNVConfigurationRegister)(NMX_uint16);
	ReturnType (*WriteVolatileConfigurationRegister)(NMX_uint8);
	ReturnType (*WriteVolatileEnhancedConfigurationRegister)(NMX_uint8);
	ReturnType (*Enter4ByteAddressMode) (void);
	ReturnType (*Exit4ByteAddressMode) (void);
	ReturnType (*LockSector)(uAddrType, NMX_uint32);
	ReturnType (*UnlockAllSector)(void);
	ReturnType (*OTPProgram)(NMX_uint8 *, NMX_uint32);
	ReturnType (*OTPRead)(NMX_uint8 *, NMX_uint32);

} FLASH_OPERATION;

typedef struct
{
	FLASH_DESCRIPTION 	Desc;
	FLASH_OPERATION   	GenOp;

} FLASH_DEVICE_OBJECT;

/******************************************************************************
    Standard functions
*******************************************************************************/


/******************************************************************************
    Standard functions
*******************************************************************************/
uAddrType BlockOffset(uSectorType uscSectorNr);
ReturnType FlashReadDeviceIdentification(NMX_uint32 *uwpDeviceIdentification);
ReturnType Driver_Init(FLASH_DEVICE_OBJECT *flash_device_object);
ReturnType FlashWriteEnable(void);
ReturnType FlashWriteDisable(void);
ReturnType FlashReadStatusRegister(NMX_uint8 *ucpStatusRegister);
ReturnType FlashWriteStatusRegister(NMX_uint8 ucStatusRegister);
ReturnType FlashGenProgram(uAddrType udAddr, NMX_uint8 *pArray , NMX_uint32 udNrOfElementsInArray, NMX_uint8 ubSpiInstruction);
ReturnType DataProgram(InstructionType insInstruction, ParameterType *fp);
ReturnType DataRead(InstructionType insInstruction, ParameterType *fp);
ReturnType FlashDataProgram(uAddrType udAddr, NMX_uint8 *pArray , NMX_uint16 udNrOfElementsInArray, NMX_uint8 ubSpiInstruction);
ReturnType FlashDataRead( uAddrType udAddr, NMX_uint8 *ucpElements, NMX_uint32 udNrOfElementsToRead, NMX_uint8 insInstruction);
ReturnType FlashSectorErase(uSectorType uscSectorNr);
ReturnType FlashSubSectorErase(uSectorType uscSectorNr);
ReturnType FlashDieErase(uSectorType uscDieNr);
ReturnType FlashBulkErase(void);
ReturnType FlashProgramEraseResume(void);
ReturnType FlashProgramEraseSuspend(void);
ReturnType FlashClearFlagStatusRegister(void);
ReturnType FlashReadNVConfigurationRegister(NMX_uint16 *ucpNVConfigurationRegister);
ReturnType FlashReadVolatileConfigurationRegister(NMX_uint8 *ucpVolatileConfigurationRegister);
ReturnType FlashReadVolatileEnhancedConfigurationRegister(NMX_uint8 *ucpVolatileEnhancedConfigurationRegister);
ReturnType FlashReadFlagStatusRegister(NMX_uint8 *ucpFlagStatusRegister);
ReturnType FlashWriteNVConfigurationRegister(NMX_uint16 ucpNVConfigurationRegister);
ReturnType FlashWriteVolatileConfigurationRegister(NMX_uint8 ucpVolatileConfigurationRegister);
ReturnType FlashWriteVolatileEnhancedConfigurationRegister(NMX_uint8 ucVolatileEnhancedConfigurationRegister);
ReturnType FlashEnter4ByteAddressMode(void);
ReturnType FlashExit4ByteAddressMode(void);
ReturnType FlashLockSector(uAddrType address, NMX_uint32 len);
ReturnType FlashUnlockAllSector(void);
ReturnType FlashOTPProgram(NMX_uint8 *pArray , NMX_uint32 udNrOfElementsInArray);
ReturnType FlashOTPRead(NMX_uint8 *ucpElements, NMX_uint32 udNrOfElementsToRead);
ReturnType FlashReadLockRegister(uAddrType address,  NMX_uint8 * val);
ReturnType FlashWriteLockRegister(uAddrType address,  NMX_uint8 * val);
ReturnType FlashLockOneSector(uAddrType address);
ReturnType FlashUnlockOneSector(uAddrType address);

/******************************************************************************
    Utility functions
*******************************************************************************/
#ifdef VERBOSE
NMX_sint8 *FlashErrorStr( ReturnType rErrNum );
#endif

ReturnType FlashTimeOut( NMX_uint32 udSeconds );

/*******************************************************************************
List of Errors and Return values, Explanations and Help.
********************************************************************************

Error Name:   Flash_AddressInvalid
Description:  The address given is out of the range of the Flash device.
Solution:     Check whether the address is in the valid range of the
              Flash device.
********************************************************************************

Error Name:   Flash_PageEraseFailed
Description:  The Page erase Instruction did not complete successfully.
Solution:     Try to erase the Page again. If this fails once more, the device
              may be faulty and need to be replaced.
********************************************************************************

Error Name:   Flash_PageNrInvalid
Note:         The Flash memory is not at fault.
Description:  A Page has been selected (Parameter), which is not
              within the valid range. Valid Page numbers are from 0 to
              FLASH_PAGE_COUNT - 1.
Solution:     Check that the Page number given is in the valid range.
********************************************************************************

Error Name:   Flash_SectorNrInvalid
Note:         The Flash memory is not at fault.
Description:  A Sector has been selected (Parameter), which is not
              within the valid range. Valid Page numbers are from 0 to
              FLASH_SECTOR_COUNT - 1.
Solution:     Check that the Sector number given is in the valid range.
********************************************************************************

Return Name:  Flash_FunctionNotSupported
Description:  The user has attempted to make use of a functionality not
              available on this Fash device (and thus not provided by the
              software drivers).
Solution:     This may happen after changing Flash SW Drivers in existing
              environments. For example an application tries to use a
              functionality which is no longer provided with the new device.
********************************************************************************

Return Name:  Flash_NoInformationAvailable
Description:  The system cannot give any additional information about the error.
Solution:     None
********************************************************************************

Error Name:   Flash_OperationOngoing
Description:  This message is one of two messages that are given by the TimeOut
              subroutine. It means that the ongoing Flash operation is still within
              the defined time frame.
********************************************************************************

Error Name:   Flash_OperationTimeOut
Description:  The Program/Erase Controller algorithm could not finish an
              operation successfully. It should have set bit 7 of the Status
              Register from 0 to 1, but that did not happen within a predetermined
              time. The program execution was therefore cancelled by a
              timeout. This may be because the device is damaged.
Solution:     Try the previous Instruction again. If it fails a second time then it
              is likely that the device will need to be replaced.
********************************************************************************

Error Name:   Flash_ProgramFailed
Description:  The value that should be programmed has not been written correctly
              to the Flash memory.
Solutions:    Make sure that the Page which is supposed to receive the value
              was erased successfully before programming. Try to erase the Page and
              to program the value again. If it fails again then the device may
              be faulty.
********************************************************************************

Error Name:   Flash_WrongType
Description:  This message appears if the Manufacture and Device Identifications read from
              the current Flash device do not match the expected identifier
              codes. This means that the source code is not explicitely written for
              the currently used Flash chip. It may work, but the operation cannot be
              guaranteed.
Solutions:    Use a different Flash chip with the target hardware or contact
              STMicroelectronics for a different source code library.
********************************************************************************

Return Name:  Flash_Success
Description:  This value indicates that the Flash memory Instruction was executed
              correctly.
********************************************************************************/

/******************************************************************************
    External variable declaration
*******************************************************************************/

/* none in this version of the release */

/*******************************************************************************
Status Register Definitions (see Datasheet)
*******************************************************************************/
enum
{
	SPI_FLASH_SRWD		= 0x80,				/* status Register Write Protect */
	SPI_FLASH_BP3		= 0x40,				/* block Protect Bit3 */
	SPI_FLASH_TB		= 0x20,				/* top/Bottom bit */
	SPI_FLASH_BP2		= 0x10,				/* block Protect Bit2 */
	SPI_FLASH_BP1		= 0x08,				/* block Protect Bit1 */
	SPI_FLASH_BP0		= 0x04,				/* block Protect Bit0 */
	SPI_FLASH_WEL		= 0x02,				/* write Enable Latch */
	SPI_FLASH_WIP		= 0x01				/* write/Program/Erase in progress bit */
};

/*******************************************************************************
flag Status Register Definitions (see Datasheet)
*******************************************************************************/
enum
{
	SPI_FSR_PROG_ERASE_CTL		= 0x80,
	SPI_FSR_ERASE_SUSP			= 0x40,
	SPI_FSR_ERASE				= 0x20,
	SPI_FSR_PROGRAM				= 0x10,
	SPI_FSR_VPP					= 0x08,
	SPI_FSR_PROG_SUSP			= 0x04,
	SPI_FSR_PROT				= 0x02,
	SPI_FSR_ADDR_MODE			= 0x01
};


/*******************************************************************************
Specific Function Prototypes
*******************************************************************************/
typedef unsigned char BOOL;

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL_PTR
#define NULL_PTR 0x0
#endif

BOOL IsFlashBusy(void);
BOOL IsFlashWELBusy(void);


/*******************************************************************************
List of Specific Errors and Return values, Explanations and Help.
*******************************************************************************

// none in this version of the release
********************************************************************************/

#endif /* __N25Q__H__  */
/* In order to avoid a repeated usage of the header file */

/*******************************************************************************
     End of file
********************************************************************************/
