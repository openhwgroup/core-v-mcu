/*==========================================================
 * Copyright 2021 QuickLogic Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *==========================================================*/



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "FreeRTOS.h"
#include "semphr.h"	// Required for configASSERT

#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"
#include "hal/include/hal_apb_soc_ctrl_regs.h"
#include "hal/include/hal_pinmux.h"
#include "hal/include/hal_gpio.h"
#include "hal/include/hal_fc_event.h"
#include "include/gpio_tests.h"
#include "gpio_map.h"

extern uint8_t gDebugEnabledFlg;

// IO functions
static void io_setmux(const struct cli_cmd_entry *pEntry);
static void io_getmux(const struct cli_cmd_entry *pEntry);
static void io_pullup(const struct cli_cmd_entry *pEntry);

// GPIO functions
static void gpio_set(const struct cli_cmd_entry *pEntry);
static void gpio_clr(const struct cli_cmd_entry *pEntry);
static void gpio_toggle(const struct cli_cmd_entry *pEntry);
static void gpio_read_status(const struct cli_cmd_entry *pEntry);
static void gpio_set_mode(const struct cli_cmd_entry *pEntry);
static void gpio_event_test(const struct cli_cmd_entry *pEntry);
static void apb_gpio_tests(const struct cli_cmd_entry *pEntry);
static void apb_gpio_event_tests(const struct cli_cmd_entry *pEntry);
#if 0
typedef struct {
	short pm[4];
} gpio_struct_t;
extern gpio_struct_t gpio_map[];

gpio_struct_t gpio_map[48] = { {-1,-1,-1,-1}, //io00
		{-1,-1,-1,-1}, //io01
		{-1,-1,-1,-1}, //io02
		{-1,-1,-1,-1}, //io03
		{-1,-1,-1,-1}, //io04
		{-1,-1,-1,-1}, //io05
		{-1,-1,-1,-1}, //io06
		{-1,-1,0,0x100}, //io07
		{-1,-1,1,0x101}, //io00
		{-1,-1,2,0x102}, //io09
		{-1,-1,3,0x103}, //io10
		{32,47,4,0x104}, //io11
		{-1,-1,5,0x105}, //io12
		{-1,-1,6,0x106}, //io13
		{-1,-1,7,0x107}, //io14
		{-1,-1,8,0x108}, //io15
		{-1,-1,9,0x109}, //io16
		{-1,-1,10,0x10a}, //io17
		{-1,-1,11,0x10b}, //io18
		{-1,-1,12,0x10c}, //io19
		{-1,-1,13,0x10d}, //io20
		{-1,36,14,0x10e}, //io21
		{-1,39,15,0x10f}, //io22
		{-1,-1,16,0x110}, //io23
		{-1,-1,17,0x111}, //io24
		{-1,33,18,0x112}, //io25
		{32,-1,19,0x113}, //io26
		{48,-1,20,0x114}, //io27
		{49,-1,21,0x115}, //io28
		{-1,34,22,0x116}, //io29
		{-1,35,23,0x117}, //io30
		{-1,36,24,0x118}, //io31
		{-1,37,25,0x119}, //io32
		{-1,38,26,0x11a}, //io33
		{-1,39,27,0x11b}, //io34
		{-1,40,28,0x11c}, //io35
		{-1,41,29,0x11d}, //io36
		{-1,42,30,0x11e}, //io37
		{-1,43,31,0x11f}, //io38
		{-1,-1,32,0x120}, //io39
		{-1,-1,43,0x121}, //io40
		{-1,-1,44,0x122}, //io41
		{-1,-1,45,0x123}, //io42
		{-1,-1,46,0x124}, //io43
		{-1,-1,47,0x125}, //io44
		{-1,-1,-1,0x126}, //io45
		{-1,-1,-1,0x127}, //io46
		{-1,-1,-1,0x128}, //io47
		{-1,-1,-1,-1} };

#endif


// IO menu
const struct cli_cmd_entry io_functions[] =
{
		CLI_CMD_SIMPLE( "setmux", io_setmux,         	"ionum mux_sel 	-- set mux_sel for ionum " ),
		CLI_CMD_SIMPLE( "getmux", io_getmux,         	"ionum  		-- get mux_sel for ionum" ),
		CLI_CMD_SIMPLE( "pullup", io_pullup,            "ionum	on      -- 1 = pullup, 0 = no pullup" ),
		CLI_CMD_TERMINATE()
};

// GPIO menu
const struct cli_cmd_entry gpio_functions[] =
{
		CLI_CMD_SIMPLE( "set", 	gpio_set,         		"gpio_num	-- set to one" ),
		CLI_CMD_SIMPLE( "clr", 	gpio_clr,         		"gpio_num	-- clear to zero" ),
		CLI_CMD_SIMPLE( "toggle",	gpio_toggle,        "gpio_num	-- toggle state of gpio" ),
		CLI_CMD_SIMPLE( "status",	gpio_read_status,   "gpio_num	-- read status of gpio: in, out, interrupt type and mode" ),
		CLI_CMD_SIMPLE( "mode",	gpio_set_mode,       	"gpio_num gpio_mode	-- set mode of gpio" ),
		CLI_CMD_SIMPLE( "event",	gpio_event_test,    "io_num, mux_sel, gpio_num, gpio_int_type	-- set interrupt of gpio" ),
		CLI_CMD_SIMPLE( "evnt",	apb_gpio_event_tests,        "None	-- All events of gpio" ),
		CLI_CMD_SIMPLE( "all",	apb_gpio_tests,         "None	-- All gpio tests " ),
		CLI_CMD_TERMINATE()
};



// IO functions
static void io_pullup(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	on;
	uint32_t	ionum;

	CLI_uint32_required( "ionum", &ionum );
	CLI_uint32_required( "on", &on);
	hal_setpullup(ionum, on);
	dbg_str("<<DONE>>");
}

static void io_setmux(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	mux_sel;
	uint32_t	lGetmux_sel;
	uint32_t	ionum;

	CLI_uint32_required( "ionum", &ionum );
	CLI_uint32_required( "mux_sel", &mux_sel);
	hal_setpinmux(ionum, mux_sel);
	lGetmux_sel = hal_getpinmux(ionum);
	if( lGetmux_sel == mux_sel )
		CLI_printf("io_setmux %d <<PASSED>>\n", ionum);
	else
		CLI_printf("io_setmux %d <<FAILED>>\n", ionum);
}

static void io_getmux(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	ionum;
	uint32_t	mux_sel;

	CLI_uint32_required( "ionum", &ionum );
	mux_sel = hal_getpinmux(ionum);
	CLI_printf("mux_sel 0x%08x\n", mux_sel);
	dbg_str("<<DONE>>");
}

// GPIO functions
static void gpio_set(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	gpio_num;

	CLI_uint32_required( "gpio_num", &gpio_num );
	hal_set_gpio((uint8_t)gpio_num);
	dbg_str("<<DONE>>");
}

static void gpio_clr(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	gpio_num;

	CLI_uint32_required( "gpio_num", &gpio_num );
	hal_clr_gpio((uint8_t)gpio_num);
	dbg_str("<<DONE>>");
}

static void gpio_toggle(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	gpio_num;

	CLI_uint32_required( "gpio_num", &gpio_num );
	hal_toggle_gpio((uint8_t)gpio_num);
	dbg_str("<<DONE>>");
}

static void gpio_read_status(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	gpio_num;
	uint32_t value;

	CLI_uint32_required( "gpio_num", &gpio_num );

	hal_read_gpio_status_raw(gpio_num, &value);

	CLI_printf("input 0x%02x\n", (uint8_t)((value >> 12) & 0x1));
	CLI_printf("output 0x%02x\n", (uint8_t)((value >> 8) & 0x1));
	CLI_printf("interrupt_type 0x%02x\n", (uint8_t)((value >> 17) & 0x7));
	CLI_printf("interrupt_enable 0x%02x\n", (uint8_t)((value >> 16) & 0x1));
	CLI_printf("gpio_mode 0x%02x\n", (uint8_t)((value >> 24) & 0x3));


	CLI_printf("rdstatus 0x%08x\n", value);
	dbg_str("<<DONE>>");
}

static void gpio_set_mode(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint32_t	gpio_num;
	uint32_t	gpio_mode;

	CLI_uint32_required( "gpio_num", &gpio_num );
	CLI_uint32_required( "gpio_mode", &gpio_mode );
	hal_set_gpio_mode((uint8_t)gpio_num, (uint8_t)gpio_mode);
	dbg_str("<<DONE>>");
}

volatile unsigned int event_flag = 0;
volatile short	int_gpio_num;
void isr_gpio_handler(void) {
	//dbg_str("gpio event occured \r\n");
	event_flag++;

	//	hal_set_gpio_interrupt(4,2,0);
}

static void gpio_event_test(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	// Add functionality here
	uint8_t	io_num;
	uint8_t	mux_sel, save_mux;
	short	gpio_num;
	char *message;
	message = pvPortMalloc(80);
	uint32_t errors = 0;

	gDebugEnabledFlg = 0;

	for (gpio_num = 4; gpio_num < N_GPIO; gpio_num++) {
		for (io_num = 0; io_num < N_IO; io_num++) {
			for (mux_sel = 0; mux_sel < 4; mux_sel++) {
				if (gpio_map[io_num].pm[mux_sel] == gpio_num) {
					// Found a gpio to test
					int_gpio_num = gpio_num;
					CLI_printf("GPIO 0x%02x\n",(uint8_t)gpio_num);
					save_mux = hal_getpinmux((uint8_t)io_num);
					hal_clr_gpio((uint8_t)gpio_num); // TODO save gpio state
					hal_set_gpio_mode ((uint8_t)gpio_num,1);  // output
					hal_setpinmux(io_num,(uint8_t)mux_sel);
					pi_fc_event_handler_set(128 + (uint8_t)gpio_num, isr_gpio_handler, NULL);
					hal_soc_eu_set_fc_mask(128 + (uint8_t)gpio_num);

					event_flag = 0;
					vTaskDelay(1); // wait to make sure no interrupt fires
					hal_set_gpio_interrupt((uint8_t)gpio_num, 0, 1); //int active low enabled
					hal_set_gpio_interrupt((uint8_t)gpio_num, 0, 0); //int active low disabled
					//if (event_flag == 0)
					CLI_printf("event_flag(!0) 0x%08x\n", (uint32_t)event_flag);
					hal_gpio_int_ack ((uint8_t)int_gpio_num);
					event_flag = 0;
					hal_set_gpio_interrupt((uint8_t)gpio_num, 4, 1); //int active high enabled
					hal_set_gpio((uint8_t)gpio_num);
					hal_clr_gpio((uint8_t)gpio_num);
					hal_set_gpio_interrupt((uint8_t)gpio_num, 0, 0); //int active high disabled
					//if (event_flag == 0)
					CLI_printf("event_flag(!0) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag == 0 )
					{
						errors++;
					}
					hal_gpio_int_ack ((uint8_t)int_gpio_num);
					event_flag = 0;
					hal_set_gpio_interrupt((uint8_t)gpio_num, 1, 1); //int falling edge enabled
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					CLI_printf("event_flag(0) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 0 )
					{
						errors++;
					}
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					CLI_printf("event_flag(1) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 1 )
					{
						errors++;
					}
					hal_set_gpio_interrupt((uint8_t)gpio_num, 2, 1); //int rising edge enabled
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					CLI_printf("event_flag(2) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 2 )
					{
						errors++;
					}
					hal_set_gpio_interrupt((uint8_t)gpio_num, 3, 1); //int both edges enabled
					hal_toggle_gpio((uint8_t)gpio_num);
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					CLI_printf("event_flag(4) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 4 )
					{
						errors++;
					}
					hal_toggle_gpio((uint8_t)gpio_num);
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					CLI_printf("event_flag(6) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 6 )
					{
						errors++;
					}
					hal_soc_eu_clear_fc_mask(128 + (uint8_t)gpio_num);
					pi_fc_event_handler_clear(128 + (uint8_t)gpio_num);
					hal_setpinmux(io_num,save_mux);

				}
			}
		}
	}
	vPortFree(message);
	gDebugEnabledFlg = 1;
	if( errors == 0 )
	{
		CLI_printf("<<PASSED>>\r\n");
	}
	else
	{
		CLI_printf("<<FAILED>>\r\n");
	}
}

uint32_t gpio_event_test_forevent31(void)
{
	// Add functionality here
	uint8_t	io_num;
	uint8_t	mux_sel, save_mux;
	short	gpio_num;
	uint32_t errors = 0;
	uint16_t i = 0;

	for (i = 0; i < 5; i++) {
		gpio_num = 5;
		for (io_num = 0; io_num < N_IO; io_num++) {
			for (mux_sel = 0; mux_sel < 4; mux_sel++) {
				if (gpio_map[io_num].pm[mux_sel] == gpio_num) {
					// Found a gpio to test
					int_gpio_num = gpio_num;
					//CLI_printf("GPIO 0x%02x\n",(uint8_t)gpio_num);
					save_mux = hal_getpinmux((uint8_t)io_num);
					hal_clr_gpio((uint8_t)gpio_num); // TODO save gpio state
					hal_set_gpio_mode ((uint8_t)gpio_num,1);  // output
					hal_setpinmux(io_num,(uint8_t)mux_sel);
					pi_fc_event_handler_set(128 + (uint8_t)gpio_num, isr_gpio_handler, NULL);
					hal_soc_eu_set_fc_mask(128 + (uint8_t)gpio_num);

					event_flag = 0;
					vTaskDelay(1); // wait to make sure no interrupt fires
					hal_set_gpio_interrupt((uint8_t)gpio_num, 0, 1); //int active low enabled
					hal_set_gpio_interrupt((uint8_t)gpio_num, 0, 0); //int active low disabled
					//if (event_flag == 0)
					//CLI_printf("event_flag(!0) 0x%08x\n", (uint32_t)event_flag);
					hal_gpio_int_ack ((uint8_t)int_gpio_num);
					event_flag = 0;
					hal_set_gpio_interrupt((uint8_t)gpio_num, 4, 1); //int active high enabled
					hal_set_gpio((uint8_t)gpio_num);
					hal_clr_gpio((uint8_t)gpio_num);
					hal_set_gpio_interrupt((uint8_t)gpio_num, 0, 0); //int active high disabled
					//if (event_flag == 0)
					//CLI_printf("event_flag(!0) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag == 0 )
					{
						errors++;
					}
					hal_gpio_int_ack ((uint8_t)int_gpio_num);
					event_flag = 0;
					hal_set_gpio_interrupt((uint8_t)gpio_num, 1, 1); //int falling edge enabled
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					//CLI_printf("event_flag(0) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 0 )
					{
						errors++;
					}
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					//CLI_printf("event_flag(1) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 1 )
					{
						errors++;
					}
					hal_set_gpio_interrupt((uint8_t)gpio_num, 2, 1); //int rising edge enabled
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					//CLI_printf("event_flag(2) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 2 )
					{
						errors++;
					}
					hal_set_gpio_interrupt((uint8_t)gpio_num, 3, 1); //int both edges enabled
					hal_toggle_gpio((uint8_t)gpio_num);
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					//CLI_printf("event_flag(4) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 4 )
					{
						errors++;
					}
					hal_toggle_gpio((uint8_t)gpio_num);
					hal_toggle_gpio((uint8_t)gpio_num);
					vTaskDelay(1);
					//CLI_printf("event_flag(6) 0x%08x\n", (uint32_t)event_flag);
					if( event_flag != 6 )
					{
						errors++;
					}
					hal_soc_eu_clear_fc_mask(128 + (uint8_t)gpio_num);
					pi_fc_event_handler_clear(128 + (uint8_t)gpio_num);
					hal_setpinmux(io_num,save_mux);

				}
			}
		}
	}
	return errors;
}

static unsigned int gpio_set_clr_toggle_mode_test(gpio_struct_typedef *gpio) {

	gpio_struct_typedef lgpio;
	gpio_hal_typedef hgpio;
	uint32_t error = 0;
	char *message;
	message = pvPortMalloc(80);

	hal_setpinmux(gpio->io_num, gpio->mux_sel);
	hal_clr_gpio((uint8_t)gpio->number);

	hgpio.number = gpio->number;
	hal_read_gpio_status(&hgpio);
	gpio->number = hgpio.number;
	gpio->in_val = hgpio.in_val;
	gpio->out_val = hgpio.out_val;

#if GPIO_TEST
	sprintf(message,"Gpio No:0x%x,Io No:0x%x, Mux No: 0x%x,Out Val:0x%x, In Val:0x%x, Mode :0x%x  \r\n",
			gpio->number,gpio->io_num,gpio->mux_sel,gpio->out_val, gpio->in_val,hgpio.mode);
	dbg_str(message);
#endif

	hal_set_gpio_mode((uint8_t)(gpio->number), (uint8_t)(gpio->mode));
	switch(gpio->type) {
	case GPIO_SET:
		hal_set_gpio((uint8_t)gpio->number);
		break;
	case GPIO_CLR:
		hal_set_gpio((uint8_t)gpio->number);
		hal_clr_gpio((uint8_t)gpio->number);
		break;
	case GPIO_TOGGLE_H:
		hal_set_gpio((uint8_t)gpio->number);
		hal_toggle_gpio((uint8_t)gpio->number);
		break;
	case GPIO_TOGGLE_L:
		hal_clr_gpio((uint8_t)gpio->number);
		hal_toggle_gpio((uint8_t)gpio->number);
		break;
	default:
		break;
	}
	hal_read_gpio_status(&hgpio);
	lgpio.mux_sel = hal_getpinmux(gpio->io_num);
	lgpio.io_num = gpio->io_num;
	lgpio.number = hgpio.number;
	lgpio.out_val = hgpio.out_val;
	lgpio.in_val = hgpio.in_val;
	lgpio.mode = hgpio.mode;

#if GPIO_TEST
	sprintf(message, "Gpio No:0x%x,Io No:0x%x, Mux No: 0x%x, Out Value:0x%0x, In Val: 0x%x, Mode: 0x%x \r\n",
			lgpio.number,lgpio.io_num,lgpio.mux_sel,lgpio.out_val,lgpio.in_val,lgpio.mode );
	dbg_str(message);
#endif

	if( (lgpio.mux_sel == gpio->mux_sel) &&
		(lgpio.out_val == gpio->result) &&
		(lgpio.in_val == gpio->result)		//To confirm the value on the pin, read the input value
	) {
		error = 0;
	}else {
		error = 1;
	}
	vPortFree(message);
	return error;
}


static void apb_gpio_tests(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	gpio_struct_typedef gpio;
	unsigned int err = 0;
	unsigned int t_type;
	gpio.io_num = 11;
	gpio.mux_sel = 2;
	gpio.mode = 1;  //Output = 1, Input = 0.
	for(t_type = 0; t_type <= GPIO_TOGGLE_L; t_type ++) {
		switch(t_type) {
		case GPIO_SET:
			dbg_str("GPIO Set Test :");
			gpio.result = 1;
			gpio.type = GPIO_SET;
			break;
		case GPIO_CLR:
			dbg_str("GPIO Clear Test :");
			gpio.result = 0;
			gpio.type = GPIO_CLR;
			break;
		case GPIO_TOGGLE_H:
			dbg_str("GPIO Toggle High Test :");
			gpio.result = 0;
			gpio.type = GPIO_TOGGLE_H;
			break;
		case GPIO_TOGGLE_L:
			dbg_str("GPIO Toggle Low Test :");
			gpio.result = 1;
			gpio.type = GPIO_TOGGLE_L;
			break;
		default:
			break;
		}
		for(gpio.number = 4; gpio.number <= 31; gpio.number++ ) {
			err += gpio_set_clr_toggle_mode_test(&gpio);
			hal_setpinmux(gpio.io_num, 0);
			gpio.io_num++;
		}
		gpio.io_num = 11;
		gpio.number = 4;
		if (!err) {
			dbg_str("apb_gpio_tests <<PASSED>>\r\n");
		}
		else {
			dbg_str("apb_gpio_tests <<FAILED>>\r\n");
		}
	}
}



void event_gpio_handler(void) {
	event_flag = 1;
}

static unsigned int gpio_even_tests(gpio_struct_typedef *gpio)
{

	gpio_struct_typedef lgpio;
	gpio_hal_typedef hgpio;
	uint32_t error = 0;
	uint32_t lLoopCounter = 0;
	uint8_t	save_mux = 0;

	save_mux = hal_getpinmux((uint8_t)gpio->io_num);
	hal_setpinmux((uint8_t)gpio->io_num, gpio->mux_sel);
	hal_clr_gpio((uint8_t)gpio->number);

	hgpio.number = gpio->number;
	hal_read_gpio_status(&hgpio);
	gpio->number = hgpio.number;
	gpio->in_val = hgpio.in_val;
	gpio->out_val = hgpio.out_val;

#if GPIO_TEST
	sprintf(message,"Io No:0x%x, Mux No: 0x%x, Gpio No:0x%x, Out Val:0x%x, In Val:0x%x, Mode :0x%x,Int Type:0x%x, Int En:0x%x \r\n",
			gpio->io_num,gpio->mux_sel,gpio->number,gpio->out_val, gpio->in_val,hgpio.mode,hgpio.int_type,hgpio.int_en);
	dbg_str(message);
#endif

	hal_set_gpio_mode((uint8_t)(gpio->number), (uint8_t)(gpio->mode));
	hal_set_gpio_interrupt((uint8_t)(gpio->number), (uint8_t)gpio->int_type,(uint8_t)gpio->int_en);
	hal_read_gpio_status(&hgpio);
	lgpio.mux_sel = hal_getpinmux((uint8_t)gpio->io_num);
	lgpio.number = hgpio.number;
	lgpio.io_num = gpio->io_num;
	lgpio.out_val = hgpio.out_val;
	lgpio.in_val = hgpio.in_val;
	lgpio.mode = hgpio.mode;
	lgpio.int_type = hgpio.int_type;
	lgpio.int_en = hgpio.int_en;

#if GPIO_TEST
	sprintf(message, "Io No:0x%x, Mux No: 0x%x,Gpio No:0x%x, Out Value:0x%0x, In Val: 0x%x, Mode: 0x%x, Int Type:0x%x, Int En:0x%x \r\n",
			lgpio.io_num,lgpio.mux_sel,lgpio.number,lgpio.out_val,lgpio.in_val,lgpio.mode, lgpio.int_type,lgpio.int_en );
	dbg_str(message);
#endif

	pi_fc_event_handler_set(128 + (uint8_t)gpio->number, event_gpio_handler, NULL);
	hal_soc_eu_set_fc_mask(128 + (uint8_t)gpio->number);

	switch(gpio->event) {
	case FALLING_EDGE:
		hal_toggle_gpio((uint8_t)gpio->number);
		hal_toggle_gpio((uint8_t)gpio->number);
		break;
	case RISING_EDGE:
		hal_toggle_gpio((uint8_t)gpio->number);
		break;
	case ANY_EDGE:
		hal_toggle_gpio((uint8_t)gpio->number);
		break;
	case ACTIVE_HIGH:
		//hal_toggle_gpio((uint8_t)gpio->number);
		hal_clr_gpio((uint8_t)gpio->number);
		hal_set_gpio((uint8_t)gpio->number);

		break;
	case ACTIVE_LOW:
		hal_set_gpio((uint8_t)gpio->number);
		hal_clr_gpio((uint8_t)gpio->number);

		break;

	default:
		break;
	}
	//TODO: Break this loop with a counter and print the GPIO number.
	lLoopCounter = 0;
	while(event_flag == 0){
		if(++lLoopCounter >= 0x00010000 )
		{
			error = 1;
			CLI_printf("[NO GPIO Int] IONUM = %d Mux = %d GPIO = %d\n", gpio->io_num, gpio->mux_sel , gpio->number);
			break;
		}
	}
	if(event_flag == 0x1) {
		hal_soc_eu_clear_fc_mask(128 + (uint8_t)gpio->number);
		hal_set_gpio_interrupt((uint8_t)(gpio->number), 0x0, 0x0); //(uint8_t)gpio->int_en);
		error = 0;
		event_flag = 0;
	}
	else {
		error = 1;
	}

	hal_setpinmux((uint8_t)gpio->io_num, save_mux);

	return error;
}

static void apb_gpio_event_tests(const struct cli_cmd_entry *pEntry)
{
	(void)pEntry;
	gpio_struct_typedef gpio;
	unsigned int err = 0;
	unsigned int int_type;
	gpio.io_num = 11;
	gpio.mux_sel = 2;
	gpio.mode = 1;
	gpio.int_en = 1;
	gpio.number = 4;

	int_type = RISING_EDGE;
	for(int_type = FALLING_EDGE; int_type <= ACTIVE_HIGH; int_type ++) {
		switch(int_type) {
		case FALLING_EDGE:
			dbg_str("Gpio Int Falling Edge Test  :");
			gpio.int_type = FALLING_EDGE;
			gpio.event = FALLING_EDGE;
			break;
		case RISING_EDGE:
			dbg_str("Gpio Int Rising Edge Test :");
			gpio.int_type = RISING_EDGE;
			gpio.event = RISING_EDGE;
			break;
		case ANY_EDGE:
			dbg_str("Gpio Int Any Edge Test :");
			gpio.int_type = ANY_EDGE;
			gpio.event = ANY_EDGE;
			break;

		case ACTIVE_LOW:
			dbg_str("Gpio Int Active Low Test :");
			gpio.int_type = ACTIVE_LOW;
			gpio.event = ACTIVE_LOW;
			break;

		case ACTIVE_HIGH:
			dbg_str("Gpio Int Active High Test :");
			gpio.int_type = ACTIVE_HIGH;
			gpio.event = ACTIVE_HIGH;
			break;

		default:
			break;
		}
		if(int_type != 4) {
			for(gpio.number = 4; gpio.number <= 31; gpio.number++ ) {
				err =+ gpio_even_tests(&gpio);
				gpio.io_num++;
			}

			gpio.io_num = 11;
			gpio.number = 4;
			if (!err) {
				dbg_str("<<PASSED>>\r\n");
			}
			else {
				dbg_str("<<FAILED>>\r\n");
			}
		}
	}
}


