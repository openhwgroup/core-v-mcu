..
   Copyright (c) 2023 OpenHW Group
   Copyright (c) 2024 CircuitSutra

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. Level 1
   =======

   Level 2
   -------

   Level 3
   ~~~~~~~

   Level 4
   ^^^^^^^
.. _udma_cam:

uDMA CAMERA
===========
A camera interface is a hardware block that interfaces with different image sensor interfaces and generates output that can be used for image processing.

Features
--------
- Supports RGB565, RGB555 ,RGB444, BYPASS_LITEND and BYPASS_BIGEND image formats.
- Allows windowing. It allows users to select a range of interest in the picture. It can be disabled by the user.
- Parallel data input line for carrying pixel data.
- There is a horizontal sync(HSYNC) input which indicates one line of the frame is transmitted.
- There is a vertical sync(VSYNC) input which indicates that one entire frame is transmitted. It can be configured for polarity.
- Supports active low reset.

Block Architecture
------------------
cam_clk_i is a pixel clock which changes on every pixel. Pixel data is taken as input through cam_data_i, and cam_hsync_i and cam_vsync_i indicate the horizontal and vertical sync value.
It contains a udma dc fifo to store the pixel value before sending it to output.

The Figure below is a high-level block diagram of the uDMA UART:-

.. figure:: udma_cam_image.png
   :name: uDMA_Camera_Block_Diagram
   :align: center
   :alt:

   uDMA Camera Block Diagram

Dual-clock(DC) RX FIFO
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The uDMA core operates using the system clock, while the uDMA Camera operates using both the system clock and the peripheral clock. To ensure the uDMA UART and core are properly synchronized, dual-clock FIFOs are used in the uDMA Camera.
These are 8-depth FIFOs and can store 16-bit wide data. It is implemented using circular FIFO.

Below diagram shows the interfaces of DC FIFO: 

.. figure:: uDMA_UART_Dual_clock_fifo.png
   :name: uDMA_UART_Dual_clock_fifo
   :align: center
   :alt:

   Dual clock FIFO

For Rx operation, source(src_*) interfaces shown in above diagram operate at peripheral clock and destination(dst_*) interfaces operate using system clock.

**Pop operation**

The DC FIFO asserts the dst_valid_o (valid) signal to indicate that valid data is available on the data lines. A module waiting for data should read the data lines only when valid pin is high and drive the dst_ready_i (ready)
signal to high and reset it in next clock cycle. When DC FIFO receives an active ready signal, indicating that the data has been read, it updates the data lines with new data if FIFO is not empty. 
If the FIFO is empty, the dst_valid_o signal is deasserted.

**Push operation**

The DC FIFO asserts the src_ready_o (ready) signal when there is available space to accept incoming data. When an active src_valid_i (valid) signal is received, the data is written into the FIFO.
The src_ready_o signal is kept asserted as long as the FIFO has space for more data. IF the DC FIFO is full, push operation will be stalled until the FIFO has empty space and valid line is high.
A module tranmitting the data to DC FIFO should drive the valid signal low to indicate data lines should not be read.

During Camera receive (Rx) operation, the RX DC FIFO is written internally by the uDMA Camera with the data received from the external device and read by the uDMA core.

RX operation
^^^^^^^^^^^^

 RX operation is enable using 

The uDMA camera communicates with external device using below pins:

uDMA core reads 8 bits of information from external device in a cycle.  and stores it in its internal DC FIFO. uDMA camera communicates 16 bit of information to uDMA core in each clock cycle.

uDMA camera pushes the pixel data onto DC FIFO. Pixel data is transmitted to uDMA core. 

Frame Dropping
^^^^^^^^^^^^^^
The uDMA Camera supports frame dropping, which allows selective skipping of incoming frames. Frame dropping can be configured via the ``FRAMEDROP_EN`` and ``FRAMEDROP_VALUE`` fields in the ``REG_CAM_CFG_GLOB`` control and status register (CSR).
When frame dropping is enabled and the uDMA Camera is configured to receive data from an external source, it uses an internal frame counter to track received frames. The frame counter increments on each new frame. Once it reaches the value specified in ``FRAMEDROP_VALUE``, it is reset to zero, allowing the next frame to be stored.
Frames are considered valid and written to L2 memory only when the frame counter value is zero. If the frame counter is non-zero, the corresponding frames are treated as dropped and are not stored in L2 memory. The counter is also reset under the following conditions:

- A reset signal is received by the uDMA Camera
- Frame dropping is disabled

Frame Slicing
^^^^^^^^^^^^^
The uDMA Camera supports frame slicing(windowing), which allows selective slicing of incoming frames. Frame slicing can be enabled via the ``FRAMESLICE_EN`` bit in the ``REG_CAM_CFG_GLOB`` control and status register (CSR). The size of the sliced frame can be configured using ``REG_CAM_CFG_LL`` and ``REG_CAM_CFG_UR`` CSR.
``REG_CAM_CFG_LL`` CSR is used to select lower left cordinates of frame and ``REG_CAM_CFG_UR`` is used to select upper right cordinates.

If frame slicing is enabled, the current pixel is processed only if it lies within the configured frame slice region, based on the following conditions:
- The current row  is greater than or equal to the frame slice's lower-left Y-coordinate(``FRAMESLICE_LLY``).
- The current row is less than or equal to the frame slice's upper-right Y-coordinate(``FRAMESLICE_URY``).
- The current column is greater than or equal to the frame slice's lower-left X-coordinate(``FRAMESLICE_LLX``).
- The current column is less than or equal to the frame slice's upper-right X-coordinate(``FRAMESLICE_URY``).

If Frame slicing is enabled, pixels outside this region are excluded from processing.

IMAGE FORMAT
^^^^^^^^^^^^
The following image format is supported by uDMA Core: -

- RGB565: Five bits of data is allocated for the red and blue color component and 6 bits data for the green color component.
- RGB555: Five bits of data is allocated for each(R,G and B) the color components.
- RGB444: Four bits of data is allocated for each(R,G and B) the color components.
- BYPASS_LITEND: Used for YUV images. In the YUV image a color is described as a Y component(luma, for brightness) and two chroma(for colors) components U and V.
- BYPASS_BIGEND: Used for YUV images. In the YUV image a color is described as a Y component(luma, for brightness) and two chroma(for colors) components U and V.

Pixel Data Sampling Mechanism
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Pixel data from the external device arives arrives serially over the ``cam_data_i`` pin using two clock cycles per pixel (16-bit RGB565 format over an 8-bit interface).

A full pixel is received over two consecutive clock cycles:

**First cycle (odd clocks: 1, 3, 5, ...):**

- The value from ``cam_data_i`` is captured and stored in a temporary register, let's say ``MSB``
- This value will be used in the next clock cycle.

**Second cycle (even clocks: 2, 4, 6, ...):**

- A new value is received from ``cam_data_i`` (this is the LSB of the pixel).
- The full 16-bit pixel is reconstructed using:
  
  - ``MSB`` (from previous cycle)
  - ``cam_data_i`` (current cycle)


uDMA extract the RGB component form incoming pixel using below rule: -

- RGB565
   Red component = {MSB[7:3],3'b000}
   Green component = {MSB[2:0],cam_data_i[7:5], 2'b00}
   Blue component = {cam_data_i[4:0], 3'b000}
- RGB555
   Red component = {MSB[6:2],3'b000}
   Green component = {MSB[2:0],cam_data_i[7:5], 2'b00}
   Blue component = {cam_data_i[4:0], 3'b000}
- RGB444
   Red component = {MSB[3:0],4'b0000}
   Green component = {cam_data_i[7:4],4'b0000}
   Blue component = {cam_data_i[3:0],4'b0000}
- BYPASS_LITEND
   YUV = {MSB[7:0],cam_data_i[7:0]}
- BYPASS_BIGEND
   YUV = {cam_data_i[7:0],MSB[7:0]}

In the above representation, MSB represent the value of cam_data_i pin in the alternate clock cycle i.e. 1,3,5 etc. Pixel data from the external device is read during each clock cycle.
When first clock is recived data fron cam_data_i is stored in store in MSB(a local varaible), however the value will be reflected in the next clock cycle. In the second clock cycle data will be used from cam_data_i input pin and MSB will have cam_data_i data from the previous clock. 

- Filter values for R, G, B can be obtained by multiplying their respective pixel values by their coefficients. Coefficient can be read from REG_CAM_CFG_FILTER.
- Filter values for all the pixels are added and then shifted right to get the final pixel value which is then passed to fifo. Number of bits needed to be shifted can be read from REG_CAM_CFG_GLOB.

**IMAGE FORMAT: BYPASS_LITEND, BYPASS_BIGEND**
   - These image formats are used for YUV images. In the YUV image a color is described as a Y component(luma) and two chroma components U and V.
   - Luma represents the brightness of the image and chroma conveys the color information of the picture.
   - YUV pixel value can be read from cam_data_i.
   - Filter is not valid.

**Vertical sync**
   - Polarity can be read from REG_CAM_VSYNC_POLARITY..
   - A start of frame is marked by high current vsync value and low previous vsync.

System Architecture
-------------------
The figure below shows how the uDMA UART interfaces with the rest of the CORE-V-MCU components and the external UART device:-

.. figure:: uDMA-Camera-system-Connection-Diagram.png
   :name: uDMA-Camera-CORE-V-MCU-Connection-Diagram
   :align: center
   :alt:

   uDMA Camera CORE-V-MCU connection diagram

Programming Model
------------------
As with the most peripherals in the uDMA Subsystem, software configuration can be conceptualized into three functions:

- Configure the I/O parameters of the peripheral (e.g. frame size).
- Configure the uDMA camera data control parameters.
- Manage the data transfer/reception operation.

uDMA Camera Data Control
^^^^^^^^^^^^^^^^^^^^^^
Refer to the Firmware Guidelines section in the current chapter.

Data Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^
Refer to the Firmware Guidelines section in the current chapter.

uDMA CAMERA CSRs
----------------

Refer to `Memory Map <https://github.com/openhwgroup/core-v-mcu/blob/master/docs/doc-src/mmap.rst>`_ for peripheral domain address of the uDMA CAMERA.

**NOTE:** Several of the uDMA CAMERA CSR are volatile, meaning that their read value may be changed by the hardware.
For example, writting the *REG_RX_SADDR* CSR will set the address of the receive buffer pointer.
As data is received, the hardware will update the value of the pointer to indicate the current address.
As the name suggests, the value of non-volatile CSRs is not changed by the hardware.
These CSRs retain the last value writen by software.

A CSRs volatility is indicated by its "type".

Details of CSR access type are explained `here <https://docs.openhwgroup.org/projects/core-v-mcu/doc-src/mmap.html#csr-access-types>`_.

The CSRs REG_RX_SADDR, REG_RX_SIZE specifies the configuration for the transaction on the RX channel. The uDMA Core creates a local copy of this information at its end and use it for current ongoing transaction.

REG_RX_SADDR
^^^^^^^^^^^^

- Offset: 0x0
- Type:   volatile

+--------+------+--------+------------+----------------------------------------------------------------------------------------------------------+
| Field  | Bits | Access | Default    | Description                                                                                              |
+========+======+========+============+==========================================================================================================+
| SADDR  | 18:0 | RW     |    0x0     | Address of the Rx buffer. This is location in the L2 memory where UART will write the recived data.      |
|        |      |        |            | Read & write to this CSR access different information.                                                   |
|        |      |        |            |                                                                                                          |
|        |      |        |            | **On Write**: Address of Rx buffer for next transaction. It does not impact current ongoing transaction. |
|        |      |        |            |                                                                                                          |
|        |      |        |            | **On Read**:  Address of read buffer for the current ongoing transaction. This is the local copy of      |
|        |      |        |            | information maintained inside the uDMA core.                                                             |
+--------+------+--------+------------+----------------------------------------------------------------------------------------------------------+

REG_RX_SIZE
^^^^^^^^^^^

- Offset: 0x04
- Type:   volatile

+-------+-------+--------+------------+--------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                |
+=======+=======+========+============+============================================================================================+
| SIZE  |  19:0 |   RW   |    0x0     | Size of Rx buffer(amount of data to be transferred by UART to L2 memory). Read & write     |
|       |       |        |            | to this CSR access different information.                                                  |
|       |       |        |            |                                                                                            |
|       |       |        |            | **On Write**: Size of Rx buffer for next transaction.  It does not impact current ongoing  |
|       |       |        |            | transaction.                                                                               |
|       |       |        |            |                                                                                            |
|       |       |        |            | **On Read**:  Bytes left for current ongoing transaction.  This is the local copy of       |
|       |       |        |            | information maintained inside the uDMA core.                                               |
+-------+-------+--------+------------+--------------------------------------------------------------------------------------------+

REG_RX_CFG
^^^^^^^^^^

- Offset: 0x08
- Type:   volatile

+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| Field      |  Bits | Access | Default    | Description                                                                        |
+============+=======+========+============+====================================================================================+
| CLR        |   6:6 |   WO   |    0x0     | Clear the local copy of Rx channel configuration CSRs inside uDMA core             |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| PENDING    |   5:5 |   RO   |    0x0     | - 0x1: The uDMA core Rx channel is enabled and either transmitting data,           |
|            |       |        |            |   waiting for access from the uDMA core arbiter, or stalled due to a full Rx FIFO  |
|            |       |        |            |   of uDMA Core                                                                     |
|            |       |        |            | - 0x0 : Rx channel of the uDMA core does not have data to transmit to L2 memory    |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| EN         |   4:4 |   RW   |    0x0     | Enable the Rx channel of the uDMA core to perform Rx operation                     |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| DATASIZE   |   2:1 |   RW   |    0x2     | Controls uDMA address increment for each transfer from L2 memory                   |
|            |       |        |            |                                                                                    |
|            |       |        |            | - 0x0: increment address by 1 (data is 8 bits)                                     |
|            |       |        |            | - 0x1: increment address by 2 (data is 16 bits)                                    |
|            |       |        |            | - 0x02: increment address by 4 (data is 32 bits)                                   |
|            |       |        |            | - 0x03: increment address by 0                                                     |
|            |       |        |            |                                                                                    |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW   |    0x0     | - 0x0: stop after last transfer for channel                                        |
|            |       |        |            | - 0x1: after last transfer for channel, reload buffer size, start address          |
|            |       |        |            |     and restart channel                                                            |
|            |       |        |            |                                                                                    |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+

REG_CAM_CFG_GLOB
^^^^^^^^^^^^^^^^

- Offset: 0x20
- Type:  non-volatile

+------------------+-------+--------+------------+------------------------------------------------------------------------+
| Field            |  Bits | Access | Default    | Description                                                            |
+==================+=======+========+============+========================================================================+
| EN               | 31:31 |   RW   |    0x0     | Enable data RX from camera interface, Enable/disable only happens      |
|                  |       |        |            | at start of frame                                                      |
|                  |       |        |            |                                                                        |
|                  |       |        |            | - 0x0: disable                                                         |
|                  |       |        |            | - 0x1: enable                                                          |
|                  |       |        |            |                                                                        |
+------------------+-------+--------+------------+------------------------------------------------------------------------+
| SHIFT            | 14:11 |   RW   |    0x0     | Number of bits to right shift final pixel value.                       |
|                  |       |        |            | Note: not used if FORMAT == BYPASS                                     |
+------------------+-------+--------+------------+------------------------------------------------------------------------+
| FORMAT           |  10:8 |   RW   |    0x0     |Input frame format:                                                     |
|                  |       |        |            |                                                                        |
|                  |       |        |            | - 0x0: RGB565                                                          |
|                  |       |        |            | - 0x1: RGB555                                                          |
|                  |       |        |            | - 0x2: RGB444                                                          |
|                  |       |        |            | - 0x4: BYPASS_LITTLEEND                                                |
|                  |       |        |            | - 0x5: BYPASS_BIGEND                                                   |
|                  |       |        |            |                                                                        |
+------------------+-------+--------+------------+------------------------------------------------------------------------+
| FRAMESLICE_EN    |  7:7  |   RW   |    0x0     | Frame Slicing (Windowing) enable:                                      |
|                  |       |        |            |                                                                        |
|                  |       |        |            | - 0x0: disable                                                         |
|                  |       |        |            | - 0x1: enable                                                          |
|                  |       |        |            |                                                                        |
+------------------+-------+--------+------------+------------------------------------------------------------------------+
| FRAMEDROP_VALUE  |  6:1  |   RW   |    0x0     | Frame Drop value:                                                      |
|                  |       |        |            |                                                                        |
|                  |       |        |            |                                                                        |
|                  |       |        |            |                                                                        |
|                  |       |        |            |                                                                        |
+------------------+-------+--------+------------+------------------------------------------------------------------------+
| FRAMEDROP_EN     |  0:0  |   RW   |    0x0     | Frame Drop enable:                                                     |
|                  |       |        |            |                                                                        |
|                  |       |        |            | - 0x0: disable                                                         |
|                  |       |        |            | - 0x1: enable                                                          |
|                  |       |        |            |                                                                        |
+------------------+-------+--------+------------+------------------------------------------------------------------------+

REG_CAM_CFG_LL
^^^^^^^^^^^^^^

- Offset: 0x24
- Type:   volatile

+-----------------+-------+--------+------------+----------------------------------------------------+
| Field           |  Bits | Access | Default    | Description                                        |
+=================+=======+========+============+====================================================+
| FRAMESLICE_LLY  | 31:16 |   RW   |    0x0     | Y coordinate of Lower left corner of Frame.        |
+-----------------+-------+--------+------------+----------------------------------------------------+
| FRAMESLICE_LLX  | 15:0  |   RW   |    0x0     | X coordinate of Lower left corner of Frame.        |
+-----------------+-------+--------+------------+----------------------------------------------------+

REG_CAM_CFG_UR
^^^^^^^^^^^^^^

- Offset: 0x28
- Type:   non-volatile

+-----------------+-------+--------+------------+-------------------------------------------------------+
| Field           |  Bits | Access | Default    | Description                                           |
+=================+=======+========+============+=======================================================+
| FRAMESLICE_URY  | 31:16 |   RW   |    0x0     | Y coordinate of upper right corner of Frame.          |
+-----------------+-------+--------+------------+-------------------------------------------------------+
| FRAMEWINDOW_URX | 15:0  |   RW   |    0x0     | X coordinate of upper right corner of Frame.          |
+-----------------+-------+--------+------------+-------------------------------------------------------+

REG_CAM_CFG_SIZE
^^^^^^^^^^^^^^^^

- Offset: 0x2C
- Type:   non-volatile

+------------+-------+--------+------------+-------------------------------------------------------------------------+
| Field      |  Bits | Access | Default    | Description                                                             |
+============+=======+========+============+=========================================================================+
| ROWLEN     | 31:16 |   RW   |    0x0     | Defines the number of pixels that constitute a single row in the frame. |
+------------+-------+--------+------------+-------------------------------------------------------------------------+

REG_CAM_CFG_FILTER
^^^^^^^^^^^^^^^^^^

- Offset: 0x30
- Type:   volatile

+------------+---------+--------+------------+------------------------------------------------------------------------------------+
| Field      |  Bits   | Access | Default    | Description                                                                        |
+============+=========+========+============+====================================================================================+
| R_COEFF    |   23:16 |   RW   |    0x0     | Coefficent that multiplies R component, Note: not used if FORMAT == BYPASS         |
+------------+---------+--------+------------+------------------------------------------------------------------------------------+
| G_COEFF    |   15:8  |   RW   |    0x0     | Coefficent that multiplies G component, Note: not used if FORMAT == BYPASS         |
+------------+---------+--------+------------+------------------------------------------------------------------------------------+
| B_COEFF    |   7:0   |   RW   |    0x0     | Coefficent that multiplies B component, Note: not used if FORMAT == BYPASS         |
+------------+---------+--------+------------+------------------------------------------------------------------------------------+


REG_CAM_VSYNC_POLARITY
^^^^^^^^^^^^^^^^^^^^^^

- Offset: 0x34
- Type:   volatile

+----------------+-------+--------+------------+---------------------------------+
| Field          |  Bits | Access | Default    | Description                     |
+================+=======+========+============+=================================+
| VSYNC_POLARITY |   0:0 |   RW   |    0x0     | Set vsync polarit               |
|                |       |        |            |                                 |
|                |       |        |            |- 0x0: Active low                |
|                |       |        |            |- 0x0: Active high               |
|                |       |        |            |                                 |
+----------------+-------+--------+------------+---------------------------------+

Firmware Guidelines
-------------------

Clock Enable, Reset & Configure uDMA UART
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Rx Operation
^^^^^^^^^^^^

Pin Diagram
-----------
The Figure below is a high-level block diagram of the uDMA Camera:-

.. figure:: uDMA_Camera_Pin_Diagram.png
   :name: uDMA_Camera_Pin_Diagram
   :align: center
   :alt:

   uDMA Camera Pin Diagram

Below is categorization of these pins:

Rx channel interface
^^^^^^^^^^^^^^^^^^^^
The following pins constitute the Rx channel interface of uDMA UART. uDMA UART uses these pins to write data to interleaved (L2) memory:

- data_rx_datasize_o
- data_rx_o
- data_rx_valid_o
- data_rx_ready_i

These pins reflect the configuration values for the next transaction.

Clock interface
^^^^^^^^^^^^^^^
- clk_i

uDMA CORE derives these clock pins. clk_i is used to synchronize Camera with uDAM Core.

Reset interface
^^^^^^^^^^^^^^^
- rstn_i

uDMA core issues reset signal to Camera using reset pin.

uDMA UART inerface to read-write CSRs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The following interfaces are used to read and write to Camera CSRs. These interfaces are managed by uDMA Core:

- cfg_data_i
- cfg_addr_i
- cfg_valid_i
- cfg_rwn_i
- cfg_ready_o
- cfg_data_o

Rx channel interface
^^^^^^^^^^^^^^^^^^^^
The following pins constitute the Rx channel interface of uDMA UART. uDMA UART uses these pins to write data to interleaved (L2) memory:

- data_rx_datasize_o
- data_rx_o
- data_rx_valid_o
- data_rx_ready_i

These pins reflect the configuration values for the next transaction.

uDMA UART Rx channel configuration interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- uDMA UART uses the following pins to share the value of config CSRs i.e. RX_SADDR, RX_SIZE, and RX_CFG with the uDMA core:-

   - cfg_rx_startaddr_o
   - cfg_rx_size_o
   - cfg_rx_continuous_o
   - cfg_rx_en_o
   - cfg_rx_clr_o

- UART shares the values present over the below pins as read values of the config CSRs i.e. RX_SADDR, RX_SIZE, and RX_CFG:

   - cfg_rx_en_i
   - cfg_rx_pending_i
   - cfg_rx_curr_addr_i
   - cfg_rx_bytes_left_i

   These values are updated by the uDMA core and reflects the configuration values for the current ongoing transactions.

Test Interface
^^^^^^^^^^^^^^

- dft_test_mode_i: Design-for-test mode signal
- dft_cg_enable_i: Clock gating enable during test

*dft_test_mode_i* is used to put uDMA Camera into test mode. *dft_cg_enable_i* is used to control clock gating such that clock behavior can be tested.

Camera clock interface
^^^^^^^^^^^^^^^^^^^^^^

- cam_clk_i

TODO: Add descrition

Camera frame interface
^^^^^^^^^^^^^^^^^^^^^^

- cam_data_i
- cam_hsync_i
- cam_vsync_i

TODO: Add descrition