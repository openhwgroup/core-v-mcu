#include "xqspips.h"
#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "hal/include/hal_fc_event.h"
#include "hal/include/hal_udma_ctrl_reg_defs.h"
#include "hal/include/hal_udma_qspi_reg_defs.h"
#include <drivers/include/udma_qspi_driver.h>

static uint32_t gsAuccmd[16];

s32 XQspiPs_PolledTransfer(XQspiPs *InstancePtr, u8 *SendBufPtr,
			    u8 *RecvBufPtr, u32 ByteCount)
{
#if 0
	UdmaQspi_t*	pqspim_regs = (UdmaQspi_t*)(( UDMA_CH_ADDR_QSPIM + 0) * UDMA_CH_SIZE);
	uint32_t*	pcmd = gsAuccmd;
	SemaphoreHandle_t shSemaphoreHandle = qspim_semaphores_eot[qspim_id];
	configASSERT( xSemaphoreTake( shSemaphoreHandle, 1000000 ) == pdTRUE );
	shSemaphoreHandle = qspim_semaphores_rx[qspim_id];
	configASSERT( xSemaphoreTake( shSemaphoreHandle, 1000000 ) == pdTRUE );

	udma_qspim_control((uint8_t) 0, (udma_qspim_control_type_t) kQSPImReset , (void*) 0);
#endif

	return XST_SUCCESS;
}

int XQspiPs_SetSlaveSelect(XQspiPs *InstancePtr)
{

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This is a stub for the status callback. The stub is here in case the upper
* layers forget to set the handler.
*
* @param	CallBackRef is a pointer to the upper layer callback reference
* @param	StatusEvent is the event that just occurred.
* @param	ByteCount is the number of bytes transferred up until the event
*		occurred.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static void StubStatusHandler(void *CallBackRef, u32 StatusEvent,
				unsigned ByteCount)
{
	(void) CallBackRef;
	(void) StatusEvent;
	(void) ByteCount;

	Xil_AssertVoidAlways();
}

/*****************************************************************************/
/**
*
* Initializes a specific XQspiPs instance such that the driver is ready to use.
*
* The state of the device after initialization is:
*   - Master mode
*   - Active high clock polarity
*   - Clock phase 0
*   - Baud rate divisor 2
*   - Transfer width 32
*   - Master reference clock = pclk
*   - No chip select active
*   - Manual CS and Manual Start disabled
*
* @param	InstancePtr is a pointer to the XQspiPs instance.
* @param	ConfigPtr is a reference to a structure containing information
*		about a specific QSPI device. This function initializes an
*		InstancePtr object for a specific device specified by the
*		contents of Config.
* @param	EffectiveAddr is the device base address in the virtual memory
*		address space. The caller is responsible for keeping the address
*		mapping from EffectiveAddr to the device physical base address
*		unchanged once this function is invoked. Unexpected errors may
*		occur if the address mapping changes after this function is
*		called. If address translation is not used, use
*		ConfigPtr->Config.BaseAddress for this device.
*
* @return
*		- XST_SUCCESS if successful.
*		- XST_DEVICE_IS_STARTED if the device is already started.
*		It must be stopped to re-initialize.
*
* @note		None.
*
******************************************************************************/
int XQspiPs_CfgInitialize(XQspiPs *InstancePtr, XQspiPs_Config *ConfigPtr,
				u32 EffectiveAddr)
{
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(ConfigPtr != NULL);

	/*
	 * If the device is busy, disallow the initialize and return a status
	 * indicating it is already started. This allows the user to stop the
	 * device and re-initialize, but prevents a user from inadvertently
	 * initializing. This assumes the busy flag is cleared at startup.
	 */
	if (InstancePtr->IsBusy == TRUE) {
		return XST_DEVICE_IS_STARTED;
	}

	/*
	 * Set some default values.
	 */
	InstancePtr->IsBusy = FALSE;

	InstancePtr->Config.BaseAddress = EffectiveAddr;
	InstancePtr->StatusHandler = StubStatusHandler;

	InstancePtr->SendBufferPtr = NULL;
	InstancePtr->RecvBufferPtr = NULL;
	InstancePtr->RequestedBytes = 0;
	InstancePtr->RemainingBytes = 0;
	InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

	InstancePtr->Config.ConnectionMode = ConfigPtr->ConnectionMode;

	/*
	 * Reset the QSPI device to get it into its initial state. It is
	 * expected that device configuration will take place after this
	 * initialization is done, but before the device is started.
	 */
	//XQspiPs_Reset(InstancePtr);

	return XST_SUCCESS;
}
