/*
 * cam_tests.c
 *
 *  Created on: Apr 12, 2021
 *      Author: gregmartin
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"
#include "drivers/include/udma_cam_driver.h"
#include "drivers/include/udma_uart_driver.h"
#include "hal/include/hal_pinmux.h"
#include "hal/include/hal_gpio.h"

//#include "include/estruct.h"
#include "hal/include/adv_timer_unit_reg_defs.h"
#include "hal/include/hal_fc_event.h"

static int open(const struct cli_cmd_entry *pEntry);
static int getframe(const struct cli_cmd_entry *pEntry);
static int set_clock(const struct cli_cmd_entry *pEntry);

static void ov2640Init(const struct cli_cmd_entry *pEntry);

// cam menu
const struct cli_cmd_entry cam_tests[] =
{
  CLI_CMD_SIMPLE( "open", open, "Initialize Himax Sensor" ),
  CLI_CMD_WITH_ARG( "get", getframe, 0, "get image frames " ),
  CLI_CMD_WITH_ARG( "setclock", set_clock, 0, "set external clock for camera" ),
  CLI_CMD_SIMPLE( "ovinit", ov2640Init, "Initialize ov2640 Sensor" ),
  CLI_CMD_TERMINATE()
};
static uint8_t picture[244*324];
static char message[100] = {0};

static int getframe(const struct cli_cmd_entry *pEntry) {
	volatile int i = 0, j = 0, k = 0;

	for (i = 0; i < 244; i++)
		for (j = 0; j< 324; j++)
			picture[i*324+j] = 0xAA;

	udma_cam_control(kCamFrame, picture);
	/*
	for (i = 0; i < 244; i++){
		sprintf(message,"\nrow[%3d]:",i);
		dbg_str(message);
			for (j = 0; j< 324; j++) {
				sprintf(message," %02x",picture[i*324+j]);
				dbg_str(message);
			}
	}
*/
	i = 0; j = 0;
	for (i = 0; i<240; i++) {
		for (j = 0; j < 320; j += 16) {
		  sprintf(message,"ImAgE %d %d",i,j);
		  k = 0;
		  while( message[k] != '\0' )
		  {
			  udma_uart_writeraw(1, 1, &message[k]);
			  k++;
		  }

		  sprintf(message," %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\r\n",
				  ( picture[i*324+j+0] & 0xf ),(picture[i*324+j+1] & 0xf ),( picture[i*324+j+2] & 0xf ),( picture[i*324+j+3] & 0xf ),( picture[i*324+j+4] & 0xf ),
				  ( picture[i*324+j+5] & 0xf ),( picture[i*324+j+6] & 0xf ),( picture[i*324+j+7] & 0xf ),( picture[i*324+j+8] & 0xf ),( picture[i*324+j+9] & 0xf ),
				  ( picture[i*324+j+10] & 0xf ),( picture[i*324+j+11]  & 0xf ), ( picture[i*324+j+12]  & 0xf ),( picture[i*324+j+13]  & 0xf ),( picture[i*324+j+14] & 0xf ),
				  ( picture[i*324+j+15]  & 0xf ) );

		  k = 0;
		  while( message[k] != '\0' )
		  {
			  udma_uart_writeraw(1, 1, &message[k]);
			  k++;
		  }

		}
	}
}

static int set_clock(const struct cli_cmd_entry *pEntry) {
	AdvTimerUnit_t *adv_timer;
	unsigned int retval;
	adv_timer = (AdvTimerUnit_t*) ADV_TIMER_START_ADDR;
	adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_RESET_COMMAND_LSB; // reset
	adv_timer->timer_0_config_register = 0; // FLL, up/done no prescaler
	adv_timer->timer_0_threshold_register = 0x20000;
	adv_timer->timer_0_threshold_channel_0_reg = 0x30001;
	adv_timer->adv_timer_cfg_register = 0x1; // enable clock for timer0
	adv_timer->timer_0_cmd_register = 1 << REG_TIMER_0_CMD_REGISTER_START_COMMAND_LSB; //start


	return retval;
}

static void gpioISR() {

}
static int open(const struct cli_cmd_entry *pEntry)
{

	int errors = 0;
	int i, k, length;

	#if 0
	hal_setpinmux(9,2);
	hal_set_gpio_mode(2,1);
	hal_set_gpio_interrupt(2,1,1);
	pi_fc_event_handler_set(130, gpioISR, NULL);
	/* Enable SOC events propagation to FC. */
	hal_soc_eu_set_fc_mask(130);
	hal_toggle_gpio(2);
	hal_toggle_gpio(2);
	#endif

	cam_open(0);
	sprintf(message,"Himax opened--ID = ");
	dbg_str(message);
	sprintf(message,"%04x\r\n",udma_cam_control(kCamID, NULL));
	dbg_str(message);
	udma_cam_control(kCamInit, NULL);

	sprintf(message,"ScReEn320\r\n");
	k = 0;
	  while( message[k] != '\0' )
	  {
		  udma_uart_writeraw(1, 1, &message[k]);
		  k++;
	  }
}

static void ov2640Init(const struct cli_cmd_entry *pEntry)
{
	hal_setpinmux(26, 2);		//IO_26, Padmux 0 = apbio_32
	hal_set_gpio_mode(19, 1);	//Mode : 1 = Output, 0 = Input
	hal_set_gpio(19);
	vTaskDelay(200);
	hal_clr_gpio(19);
	vTaskDelay(200);
	hal_set_gpio(19);
	vTaskDelay(200);

}
