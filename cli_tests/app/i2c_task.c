

#define __I2C_TASK_C__

#include <app/include/i2c_task.h>
#include <string.h>
//#include "pmsis/implem/drivers/fc_event/fc_event.h"
#include "hal/include/hal_fc_event.h"

static TaskHandle_t xTasktoNotify;
static void ISR_i2c_handler() {
	BaseType_t *pxHigherPriorityTaskWoken;
	configASSERT(xTasktoNotify);

	vTaskNotifyGiveFromISR(xTasktoNotify,
	                       &pxHigherPriorityTaskWoken );
	portYIELD_FROM_ISR( pxHigherPriorityTaskWoken );
}

void prvI2CTask (void *pvParameters)
{
	uint8_t *string2print = NULL;
	i2c_channel_t *i2c;
	i2c_struct_t i2c_struct;

	volatile uint32_t *udma_cg = (uint32_t*)0x1a102000;

	i2c = (i2c_channel_t*) 0x1a102180;
	xI2CQueue = xQueueCreate(I2CQueueLength, sizeof(i2c_struct_t));
	configASSERT(xI2CQueue);
    /* Set handlers. */
    pi_fc_event_handler_set(SOC_EVENT_UDMA_I2C_RX(0), ISR_i2c_handler, NULL);
    pi_fc_event_handler_set(SOC_EVENT_UDMA_I2C_TX(0), ISR_i2c_handler, NULL);
    /* Enable SOC events propagation to FC. */
    hal_soc_eu_set_fc_mask(SOC_EVENT_UDMA_I2C_RX(0));
    hal_soc_eu_set_fc_mask(SOC_EVENT_UDMA_I2C_TX(0));
    *udma_cg  |= 4;  // turn on i2c clock>?

    for (;;) {
		xQueueReceive(xI2CQueue, &i2c_struct, portMAX_DELAY);
		xTasktoNotify = xTaskGetCurrentTaskHandle();

		if (i2c_struct.op &1) { // read
			i2c->rx_saddr = i2c_struct.data;
			i2c->rx_size = i2c_struct.len;
			i2c->rx_cfg = 0x10; // start the cycle
		}
		i2c->tx_saddr = i2c_struct.cmd;
		i2c->tx_size = i2c_struct.clen;
		i2c->tx_cfg = 0x10; // start the cycle
	    ulTaskNotifyTake(pdTRUE,          /* Clear the  value before exiting. */
	                     portMAX_DELAY );

	    if (!(i2c_struct.op & 0)) { // write
			i2c->tx_saddr = i2c_struct.data;
			i2c->tx_size = i2c_struct.len;
			i2c->tx_cfg = 0x10; // start the cycle
			ulTaskNotifyTake(pdTRUE,          /* Clear the  value before exiting. */
	                     portMAX_DELAY );
	    }
	    if (i2c_struct.op & 0x80) { // send stop
	    	i2c_struct.cmd[0] = 0x20; // I2C_CMD_STOP
	    	i2c_struct.cmd[1] = 0xA0; // I2C_CMD_WAIT
	    	i2c_struct.cmd[2] = 0xff;
	    	i2c->tx_saddr = i2c_struct.cmd;
	    	i2c->tx_size = 3;
			i2c->tx_cfg = 0x10; // start the cycle
			ulTaskNotifyTake(pdTRUE,          /* Clear the  value before exiting. */
	                     portMAX_DELAY );
	    }
		if (i2c_struct.TasktoNotify)
			xTaskNotifyGive(i2c_struct.TasktoNotify);
		vPortFree(i2c_struct.cmd);
    }
}

i2c_read(uint8_t addr, uint8_t *buffer, uint32_t len, uint8_t op) {
	i2c_struct_t  i2c;
	uint8_t *cmd;

	int i = 0;
	configASSERT(cmd = pvPortMalloc(16));
	cmd[i++] = 0xe0; // I2C_CMD_CFG
	cmd[i++] = 0x00; // I2C DIV MSB
	cmd[i++] = 25; // I2C DIV LSB
	cmd[i++] = 0x00; // I2C_CMD_START
	cmd[i++] = 0x80; // I2C_CMD_WR
	cmd[i++] = addr | 0x01; // I2C address/rw
	if (len > 1) {
		cmd[i++] = 0xC0; // I2C_CMD_RPT
		cmd[i++] = len-1;
		cmd[i++] = 0x40; // I2C_CMD_RD_ACK
		}
	cmd[i++] = 0x60; // I2C CMD_RD_NACK
	i2c.TasktoNotify = xTaskGetCurrentTaskHandle();
	i2c.cmd = cmd;
	i2c.clen = i;
	i2c.data = buffer;
	i2c.len = len;
	i2c.op = op;  // read and stop
	xQueueSend(xI2CQueue, &i2c, portMAX_DELAY);
    ulTaskNotifyTake(pdTRUE,          /* Clear the  value before exiting. */
                         portMAX_DELAY );
}

i2c_write (uint8_t addr, uint8_t *data, uint32_t len, uint8_t op) {
	i2c_struct_t i2c;
	uint8_t *cmd;
	int i =  0;

	configASSERT(cmd = pvPortMalloc(16));

	cmd[i++] = 0xe0; // I2C_CMD_CFG
	cmd[i++] = 0x00; // I2C DIV MSB
	cmd[i++] = 25; // I2C DIV LSB
	cmd[i++] = 0x00; // I2C_CMD_START
	cmd[i++] = 0x80; // I2C_CMD_WR
	cmd[i++] = addr & 0xfe; // I2C address/rw
	if (len > 1) {
		cmd[i++] = 0xC0; // I2C_CMD_RPT
		cmd[i++] = len;
	}
	cmd[i++] = 0x80; // I2C CMD_WR
	i2c.cmd = cmd;
	i2c.clen = i;
	i2c.data = data;
	i2c.len = len;
	i2c.op = op;  // stop if requested
	i2c.TasktoNotify = xTaskGetCurrentTaskHandle();
	xQueueSend(xI2CQueue, &i2c, portMAX_DELAY);
    ulTaskNotifyTake(pdTRUE,          /* Clear the  value before exiting. */
                         portMAX_DELAY );
}

i2c_16write8 (uint8_t dev_addr, uint16_t reg_addr, uint8_t data) {
	uint8_t cmd[3] ;
	cmd[0] = (reg_addr >> 8) & 0xff;
	cmd[1] = reg_addr & 0xff;
	cmd[2] = data;
	cmd[3] = 0;
	i2c_write(dev_addr, &cmd, 3, 0x80) ;
}

uint8_t i2c_16read8 (uint8_t dev_addr, uint16_t reg_addr) {
	uint8_t return_data;
	uint16_t swapped_addr;
	swapped_addr = (reg_addr >> 8) | (reg_addr << 8) ;
	i2c_write (dev_addr, &swapped_addr, 2, 0x0);
	i2c_read (dev_addr, &return_data, 1 ,0x81);
	return return_data;
}

