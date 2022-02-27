/**********************  DRIVER FOR SPI CONTROLLER ON ORION**********************

   Filename:     Serialize.h
   Description:  Header file of Serialize.c
   Version:      0.1
   Date:         Decemb. 2011
   Authors:      Micron S.r.l. Arzano (Napoli)


   THE FOLLOWING DRIVER HAS BEEN TESTED ON ORION WITH FPGA RELEASE 1.4 NON_DDR.

********************************************************************************

   Version History.
   Ver.   Date      Comments

   0.2   Dec 2011  Alpha version

*******************************************************************************/

#ifndef _SERIALIZE_H_
#define _SERIALIZE_H_

//#include "rodan_mmrb.h"

typedef unsigned char	uint8;
typedef signed char		sint8;
typedef unsigned int	uint16;
typedef int				sint16;
typedef unsigned long	uint32;
typedef long			sint32;

#define NULL_PTR 0x0   // a null pointer
#define DSPI 0x20000



#define True  1
#define False 0

#define REG_(x)			(*(volatile uint32*)(x))
#define RD_R(REG_)		(REG_)
#define WR_R(REG_, D)	(REG_ = D)

/* RODAN REGISTER */
#define RODAN_FPGA_REV  REG_(0x08800044)

/* SPI RODAN registers */
#define SPIBASEADDR		0x16000000
#define SPIRDFIFO		REG_(SPIBASEADDR + 0x0)		/* SPI read FIFO register */
#define SPIWRFIFO		REG_(SPIBASEADDR + 0x4)		/* SPI write FIFO register */
#define SPICR			REG_(SPIBASEADDR + 0x8)		/* SPI control register */
#define SPISR			REG_(SPIBASEADDR + 0xC)		/* SPI status register */

#define ZERO_MASK       0x00000000
#define DUMMY_BYTE      0x00



/* SPICR bits definition */
#define SPICR_EN		(1 << 0)					/* Port enable */
#define SPICR_WP		(1 << 1)					/* Write protect mode */
#define SPICR_HOLD		(1 << 2)					/* Hold mode */
#define SPICR_WRCLR		(1 << 3)					/* Flush write FIFO contents */
#define SPICR_RDCLR		(1 << 4)					/* Flush read FIFO contents */
#define SPICR_CS	    (1 << 5)					/* Continuously hold CS low */
#define SPICR_RWOT		(1 << 6)					/* Enable free running clock mode and continuous receive data */
#define SPICR_RWOTM     (1 << 7)					/* Free running clock mode */
#define SPICR_CPHA		(1 << 8)					/* Change phase of device clock */
#define SPICR_CPOL		(1 << 9)					/* Set initial polarity of device clock */
#define SPICR_EMODE     (1 << 16)                    /* Set Extended Mode */
#define SPICR_DMODE     (1 << 17)					/* Set Dual Mode */
#define SPICR_QMODE     (1 << 18)					/* Set Quad Mode */
#define SPICR_4B        (1 << 24)					/* Set four byte addressing */
#define SPICR_TRB(x)	(x << 10)					/* Number of valid data bytes transmitted to device per cycle */
/* (0b00 - 4 bytes, 0b01 - 1 byte, 0b10 - 2 bytes, 0b11 - 3 bytes) */
#define SPI_NAND_EN     (1 << 25)                   /* Spi Nand Enable bit */
#define SPICR_CLK(x)	(x << 12)					/* Clock freq (0b0000 - 50 MHz, 0b0001 - 25 MHz, 0b0010 - 12.5 MHz)*/
#define SPICR_DUMMY(x)  (x << 20)                   /* Set Dummy Cycles for fast read instructions during Extended, Dual or Quad mode */

#define SPICR_TRBYTES	(0x00000C00)				/* Transfer bytes mask */


/* SPISR bits definition */
#define SPISR_WRNE		(1 << 2)					/* Indicates presence of valid data in write FIFO buffer */
#define SPISR_RDNE		(1 << 3)					/* Indicates availability of valid data in read FIFO buffer */
#define SPISR_SPIBSY	(1 << 4)					/* Device end of SPI controller is busy with previous operation */
#define SPISR_WRFULL	(1 << 5)					/* Indicates complete filling of write FIFO buffer with valid data */
#define SPISR_RDFULL	(1 << 6)					/* Indicates complete filling of read FIFO buffer with valid data */
#define SPISR_DEVBSY	(1 << 7)					/* This bit is tied to device output line to poll ready busy status */

/* Status register masks */
#define SPI_SR1_WIP				(1 << 0)
#define SPI_SR1_WEL				(1 << 1)
#define SPI_SR1_BP0				(1 << 2)
#define SPI_SR1_BP1				(1 << 3)
#define SPI_SR1_BP2				(1 << 4)
#define SPI_SR1_E_FAIL			(1 << 5)
#define SPI_SR1_P_FAIL			(1 << 6)
#define SPI_SR1_SRWD			(1 << 7)

#define SPI_SR1_FAIL_FLAGS		(SPI_SR1_E_FAIL | SPI_SR1_P_FAIL)

#define SDELAY_(x) \
   {int i = 0x0; while(i < x) {i++;}}

#define FLUSHRWFIFO \
   WR_R(SPICR, RD_R(SPICR) | SPICR_WRCLR | SPICR_RDCLR); \
   while (RD_R(SPISR) & (SPISR_RDNE | SPISR_WRNE)); \
   WR_R(SPICR, (RD_R(SPICR) & ~SPICR_WRCLR) & ~SPICR_RDCLR); \
   CHECK_BSY;

#define CHECK_BSY \
   while (RD_R(SPISR) & SPISR_SPIBSY);

#define SET_TXRXSIZE(x) \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_EN); \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_TRBYTES); \
   WR_R(SPICR, RD_R(SPICR) | SPICR_EN | (x == 8 ? SPICR_TRB(0x1) \
   :(x == 16 ? SPICR_TRB(0x2) :(x == 24 ? SPICR_TRB(0x3) : \
   SPICR_TRB(0x0)))));

#define CHECK_RX_FIFO \
    (RD_R(SPISR) & SPISR_RDNE)

#define CHECK_TX_FIFO \
   while((RD_R(SPISR) & SPISR_WRFULL));

#define SET_CS \
   WR_R(SPICR, RD_R(SPICR) | SPICR_CS);

#define CLEAR_CS \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_CS);

#define ENABLE_RWOT \
   WR_R(SPICR, RD_R(SPICR) | SPICR_RWOT);

#define DISABLE_RWOT \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_RWOT);

#define EXT_ENABLE \
   WR_R(SPICR, RD_R(SPICR) | SPICR_EMODE);

#define DUAL_ENABLE \
   WR_R(SPICR, RD_R(SPICR) | SPICR_DMODE);

#define QUAD_ENABLE \
   WR_R(SPICR, RD_R(SPICR) | SPICR_QMODE);

#define EXT_DISABLE \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_EMODE);

#define DUAL_DISABLE \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_DMODE);

#define QUAD_DISABLE \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_QMODE);

#define FOUR_BYTE_ENABLE \
   WR_R(SPICR, RD_R(SPICR) | SPICR_4B);

#define FOUR_BYTE_DISABLE \
   WR_R(SPICR, RD_R(SPICR) & ~SPICR_4B);

#define SPI_MODE_MASK (0xFFF0FFFF) // disable all


#define FPGA_CONFIG   0x00010004
#define WRONG_FPGA   (RODAN_FPGA_REV < FPGA_CONFIG)

/*Return Type*/

typedef enum
{
	RetSpiError,
	RetSpiSuccess
} SPI_STATUS;

typedef unsigned char Bool;

// Acceptable values for SPI master side configuration
typedef enum _SpiConfigOptions
{
	OpsNull,  			// do nothing
	OpsWakeUp,			// enable transfer
	OpsInitTransfer,
	OpsEndTransfer,

} SpiConfigOptions;


// char stream definition for
typedef struct _structCharStream
{
	uint8* pChar;                                // buffer address that holds the streams
	uint32 length;                               // length of the stream in bytes
} CharStream;

SPI_STATUS Serialize_SPI(const CharStream* char_stream_send,
                         CharStream* char_stream_recv,
                         SpiConfigOptions optBefore, SpiConfigOptions optAfter) ;

SPI_STATUS SpiRodanPortInit(void);
void ConfigureSpi(SpiConfigOptions opt);
void four_byte_addr_ctl(int enable) ;


#endif //end of file


