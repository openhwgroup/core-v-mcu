#ifndef __CAMERA_H__
#define __CAMERA_H__

#include <FreeRTOS.h>
#include <queue.h>
#include "../../app/include/himax.h"


typedef struct {
	volatile uint32_t *rx_saddr; // 0x00
	volatile uint32_t rx_size; 	 // 0x04
	volatile uint32_t rx_cfg;    // 0x08
	volatile uint32_t rx_initcfg;// 0x0C
	volatile uint32_t *tx_saddr; // 0x10
	volatile uint32_t tx_size;   // 0x14
	volatile uint32_t tx_cfg;    // 0x18
	volatile uint32_t tx_initcfg;// 0x1C
	volatile uint32_t cfg_glob;  // 0x20
	volatile uint32_t cfg_ll;    // 0x24
	volatile uint32_t cfg_ur;    // 0x28
	volatile uint32_t cfg_size;  // 0x2C
	volatile uint32_t cfg_filter;// 0x30
	volatile uint32_t vsync_pol; // 0x34

} camera_struct_t;

typedef struct {
	uint16_t addr;
	uint8_t data;
}reg_cfg_t;


reg_cfg_t himaxRegInit[] = {
    {BLC_TGT, 0x08},            //  BLC target :8  at 8 bit mode
    {BLC2_TGT, 0x08},           //  BLI target :8  at 8 bit mode
    {0x3044, 0x0A},             //  Increase CDS time for settling
    {0x3045, 0x00},             //  Make symetric for cds_tg and rst_tg
    {0x3047, 0x0A},             //  Increase CDS time for settling
    {0x3050, 0xC0},             //  Make negative offset up to 4x
    {0x3051, 0x42},
    {0x3052, 0x50},
    {0x3053, 0x00},
    {0x3054, 0x03},             //  tuning sf sig clamping as lowest
    {0x3055, 0xF7},             //  tuning dsun
    {0x3056, 0xF8},             //  increase adc nonoverlap clk
    {0x3057, 0x29},             //  increase adc pwr for missing code
    {0x3058, 0x1F},             //  turn on dsun
    {0x3059, 0x1E},
    {0x3064, 0x00},
    {0x3065, 0x04},             //  pad pull 0

    {BLC_CFG, 0x43},            //  BLC_on, IIR

    {0x1001, 0x43},             //  BLC dithering en
    {0x1002, 0x43},             //  blc_darkpixel_thd
    {0x0350, 0x00},             //  Dgain Control
    {BLI_EN, 0x01},             //  BLI enable
    {0x1003, 0x00},             //  BLI Target [Def: 0x20]

    {DPC_CTRL, 0x01},           //  DPC option 0: DPC off   1 : mono   3 : bayer1   5 : bayer2
    {0x1009, 0xA0},             //  cluster hot pixel th
    {0x100A, 0x60},             //  cluster cold pixel th
    {SINGLE_THR_HOT, 0x90},     //  single hot pixel th
    {SINGLE_THR_COLD, 0x40},    //  single cold pixel th
    {0x1012, 0x00},             //  Sync. shift disable
    {0x2000, 0x07},
    {0x2003, 0x00},
    {0x2004, 0x1C},
    {0x2007, 0x00},
    {0x2008, 0x58},
    {0x200B, 0x00},
    {0x200C, 0x7A},
    {0x200F, 0x00},
    {0x2010, 0xB8},
    {0x2013, 0x00},
    {0x2014, 0x58},
    {0x2017, 0x00},
    {0x2018, 0x9B},

    {AE_CTRL,        0x01},      //Automatic Exposure Gain Control
    {AE_TARGET_MEAN, 0x3C},      //AE target mean [Def: 0x3C]
    {AE_MIN_MEAN,    0x0A},      //AE min target mean [Def: 0x0A]

    {INTEGRATION_H,  0x00},      //Integration H [Def: 0x01]
    {INTEGRATION_L,  0x60},      //Integration L [Def: 0x08]
    {ANALOG_GAIN,    0x00},      //Analog Global Gain
    {DAMPING_FACTOR, 0x20},      //Damping Factor [Def: 0x20]
    {DIGITAL_GAIN_H, 0x01},      //Digital Gain High [Def: 0x01]
    {DIGITAL_GAIN_L, 0x00},      //Digital Gain Low [Def: 0x00]

    {0x2103, 0x03},

    {0x2104, 0x05},
    {0x2105, 0x01},

    {0x2106, 0x54},

    {0x2108, 0x03},
    {0x2109, 0x04},

    {0x210B, 0xC0},
    {0x210E, 0x00}, //Flicker Control
    {0x210F, 0x00},
    {0x2110, 0x3C},
    {0x2111, 0x00},
    {0x2112, 0x32},

    {0x2150, 0x30},
    {0x0340, 0x02},
    {0x0341, 0x16},
    {0x0342, 0x01},
    {0x0343, 0x78},
    {0x3010, 0x01},
    {0x0383, 0x01},
    {0x0387, 0x01},
    {0x0390, 0x00},
    {0x3011, 0x70},
    {0x3059, 0x02},
    {0x3060, 0x01},
//    {0x3060, 0x25}, //Clock gating and clock divisors
    {0x3068, 0x20}, //PCLK0 polarity
    {IMG_ORIENTATION, 0x01}, // change the orientation
    {0x0104, 0x01},
    {0x0100, 0x01},
	//{0x0601, 0x11}	//Test pattern walking ones
	//{0x0601, 0x01}	//Test pattern colour bar
};

#endif
