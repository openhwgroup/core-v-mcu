
#include <drivers/include/camera.h>
#include "hal/include/hal_pinmux.h"
#include "hal/include/hal_fc_event.h"
#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"
#include "hal/include/hal_udma_ctrl_reg_defs.h"
#include "hal/include/hal_apb_soc_ctrl_regs.h"
static TaskHandle_t xTasktoNotify;


//uint8_t picture[244*324];
uint8_t picture[1*1];
char atable[16] = {48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70};
#if 0
uint16_t udma_cam_enableClock (uint8_t cam_id)
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
	return 0;
}



void udma_cam_open(uint8_t cam_id)
{
	camera_struct_t *cam;

	//cam = (camera_struct_t *)0x1A102380;  // Peripheral 6?

	cam = (camera_struct_t *)(UDMA_CH_ADDR_CAM + cam_id * UDMA_CH_SIZE);
	cam->rx_saddr = picture;
	cam->rx_size = (244*324);
	cam->rx_cfg = 0x12;  // start 16-bit transfers
	cam->cfg_ll = 0<<16 | 0;
	cam->cfg_ur = 323<<16 | 243; // 320 x 240 ?
	cam->cfg_filter = (1 << 16) | (1 << 8) | 1;
	cam->cfg_size = 324;
	cam->vsync_pol = 1;
	cam->cfg_glob = (0 << 0) | //  framedrop disabled
			(000000 << 1) | // number of frames to drop
			(0 << 7) | // Frame slice disabled
			(004 << 8) | // Format binary 100 = ByPass little endian
			(0000 << 11) | // Shift value ignored in bypass
			(1 << 31) ; // enable 1 == go
}
static void ISR_cam_handler() {
	BaseType_t *pxHigherPriorityTaskWoken;
	configASSERT(xTasktoNotify);

	vTaskNotifyGiveFromISR(xTasktoNotify,
	                       &pxHigherPriorityTaskWoken );
	portYIELD_FROM_ISR( pxHigherPriorityTaskWoken );
}



void prvCAMTask (void *pvParameters)
{
	camera_struct_t *cam;
	cam = (camera_struct_t *)(UDMA_CH_ADDR_CAM + 0 * UDMA_CH_SIZE);
	uint8_t *print_buf;

	udma_cam_enableClock(0);
	print_buf = pvPortMalloc(80);

	//i2c_16write8(0x48,0x103,00);
	//i2c_16read8(0x48,0x0001);

    //pi_fc_event_handler_set(SOC_EVENT_UDMA_CPI_RX(0), ISR_cam_handler, NULL);
	//hal_soc_eu_set_fc_mask(SOC_EVENT_UDMA_CPI_RX(0));
	xTasktoNotify = xTaskGetCurrentTaskHandle();

	//himaxBoot(0x48);
	udma_cam_open(0);

	for (;;) {
        ulTaskNotifyTake(pdTRUE,          /* Clear the  value before exiting. */
                         portMAX_DELAY );
        for (int j = 0; j<240; j++) {
    	for (int k = 0; k < 320; k += 16) {
    	  int l = 0;
    	  sprintf(print_buf,"ImAgE %d %d\r\n",j,k);
    	  //vSendString(print_buf,strlen(print_buf));
    	  while (l < 16) {
    		  print_buf[l*3] = 0x20;
    	  	  print_buf[(l*3)+1] = atable[((picture[650+j*324+k+l]) >> 4) & 0xf];
    	  	  print_buf[(l*3)+2] = atable[(picture[650+j*324+k+l]) & 0xf];
    	  	  l++;
    	  }
    	  print_buf[l*3] = 0xa;
    	  print_buf[l*3+1] = 0x0d;
    	  print_buf[l*3+2] = 0;
    	  //vSendString(print_buf,l*3+2);
    	}
          }
		//vSendString(".c.\r\n",6);
		cam->rx_saddr = picture;
		cam->rx_size = (244*324);
		cam->rx_cfg = 0x12;  // start 16-bit transfers
	}
}

#endif
