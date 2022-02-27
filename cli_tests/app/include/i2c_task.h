#ifndef __I2C_TASK_H__
#define __I2C_TASK_H__

#include <FreeRTOS.h>
#include <queue.h>

#ifdef __I2C_TASK_C__
#define EXTERN
#else
#define EXTERN extern
#endif


typedef struct {
	volatile uint8_t *rx_saddr;
	volatile uint32_t rx_size;
	volatile uint32_t rx_cfg;
	volatile uint32_t unused1;
	volatile uint8_t *tx_saddr;
	volatile uint32_t tx_size;
	volatile uint32_t tx_cfg;
	volatile uint32_t unused2;
	volatile uint32_t status;
} i2c_channel_t;


#define I2CQueueLength	(3)
typedef struct {
	TaskHandle_t TasktoNotify;
	uint8_t	op;
	uint8_t *cmd;
	uint32_t clen;
	uint8_t *data;
	uint32_t len;
} i2c_struct_t;

void prvI2CTask (void *pvParameters);
void i2c_16write8 (uint8_t dev_addr, uint16_t reg_addr, uint8_t data) ;
uint8_t i2c_16read8 (uint8_t dev_addr, uint16_t reg_addr) ;

EXTERN QueueHandle_t xI2CQueue;  // Print queue

#endif
