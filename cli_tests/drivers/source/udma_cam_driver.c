/*
 * Copyright 2021 QuickLogic
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <drivers/include/camera.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "FreeRTOS.h"
#include "semphr.h"

#include "target/core-v-mcu/include/core-v-mcu-config.h"

#include "hal/include/hal_fc_event.h"
#include "hal/include/hal_udma_ctrl_reg_defs.h"
#include "hal/include/hal_udma_cam_reg_defs.h"

#include <drivers/include/udma_cam_driver.h>
#include <drivers/include/udma_i2cm_driver.h>

#include "drivers/include/himax.h"
#include "drivers/include/camera.h"

SemaphoreHandle_t  cam_semaphore_rx;
static uint8_t cam;
static void camISR() {

}
void cam_open (uint8_t cam_id)
{
	int i = 0;
	volatile UdmaCtrl_t*		pudma_ctrl = (UdmaCtrl_t*)UDMA_CH_ADDR_CTRL;

	/* Enable reset and enable uart clock */
	pudma_ctrl->reg_rst |= (UDMA_CTRL_CAM0_CLKEN << cam_id);
	pudma_ctrl->reg_rst &= ~(UDMA_CTRL_CAM0_CLKEN << cam_id);
	pudma_ctrl->reg_cg |= (UDMA_CTRL_CAM0_CLKEN << cam_id);

	//psdio_regs->clk_div_b.clk_div = 5;
	//psdio_regs->clk_div_b.valid = 1;
	hal_setpinmux(21, 0);
	hal_setpinmux(22, 0);
	hal_setpinmux(25, 0);
	for(i=0; i<8; i++ )
	{
		//set pin muxes to sdio functionality
		 hal_setpinmux(29+i, 0);
	}

	/* See if already initialized */
	if (cam_semaphore_rx != NULL ){
		return;
	}

	/* Set semaphore */
	SemaphoreHandle_t shSemaphoreHandle;		// FreeRTOS.h has a define for xSemaphoreHandle, so can't use that
	shSemaphoreHandle = xSemaphoreCreateBinary();
	configASSERT(shSemaphoreHandle);
	xSemaphoreGive(shSemaphoreHandle);
	cam_semaphore_rx = shSemaphoreHandle;


	/* Set handlers. */
	pi_fc_event_handler_set(SOC_EVENT_UDMA_CAM_RX(cam_id), camISR, cam_semaphore_rx);
	/* Enable SOC events propagation to FC. */
	hal_soc_eu_set_fc_mask(SOC_EVENT_UDMA_CAM_RX(cam_id));

	/* configure */
	cam = 0x48; // Himax address
	udma_cam_control(kCamReset, NULL);

	return;
}
uint16_t udma_cam_control(udma_cam_control_type_t control_type, void* pparam) {
	short retval = 0;
	uint16_t i;
	SemaphoreHandle_t shSemaphoreHandle;
	camera_struct_t *camera;
	//camera = (camera_struct_t *)0x1A102300;  // Peripheral 5?
	camera = (camera_struct_t *)(UDMA_CH_ADDR_CAM + 0 * UDMA_CH_SIZE);
	shSemaphoreHandle = cam_semaphore_rx;

	switch (control_type) {
	case kCamReset:
		_himaxRegWrite(SW_RESET, HIMAX_RESET);
		break;
	case kCamID:
		udma_i2cm_16read8(0, cam, MODEL_ID_H, 2, &retval, 0);
		retval = (retval >> 8) & 0xff | (retval <<8);
		break;
	case kCamInit:
	    for(i=0; i<(sizeof(himaxRegInit)/sizeof(reg_cfg_t)); i++){
	        _himaxRegWrite(himaxRegInit[i].addr, himaxRegInit[i].data);
	    }
	    camera->cfg_ll = 0<<16 | 0;
	    	camera->cfg_ur = 323<<16 | 243; // 320 x 240 ?
	    	camera->cfg_filter = (1 << 16) | (1 << 8) | 1;
	    	camera->cfg_size = 324;
	    	camera->vsync_pol = 1;
	    	camera->cfg_glob = (0 << 0) | //  framedrop disabled
	    			(000000 << 1) | // number of frames to drop
	    			(0 << 7) | // Frame slice disabled
	    			(004 << 8) | // Format binary 100 = ByPass little endian
	    			(0000 << 11);  // Shift value ignored in bypass

	    break;
	case kCamFrame:
		configASSERT( xSemaphoreTake( shSemaphoreHandle, 1000000 ) == pdTRUE );
		camera->rx_saddr = pparam;
		camera->rx_size = (244*324);
		camera->rx_cfg = 0x12;  // start 16-bit transfers
    	camera->cfg_glob = camera->cfg_glob |
    			(1 << 31) ; // enable 1 == go

		configASSERT( xSemaphoreTake( shSemaphoreHandle, 1000000 ) == pdTRUE );
    	camera->cfg_glob = camera->cfg_glob &
    			(0x7fffffff) ; // enable 1 == go
		configASSERT( xSemaphoreGive( shSemaphoreHandle ) == pdTRUE );
	}
	return retval;
}

void _himaxRegWrite(unsigned int addr, unsigned char value){
	uint8_t naddr;
	uint16_t data;
	naddr = (addr>>8) & 0xff;
	data = (value << 8) | (addr & 0xff);
	udma_i2cm_write (0, cam, naddr, 2, &data, 0);
   //     i2c_16write8(cam,addr,value);
}
