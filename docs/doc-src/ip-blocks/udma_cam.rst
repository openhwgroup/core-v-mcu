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
A camera interface is a hardware block that interfaces with different
image sensor interfaces and generates output that can be used for
image processing.

FEATURES:
---------
   - Supports RGB565, RGB555 ,RGB444, BYPASS_LITEND and BYPASS_BIGEND
     image formats.

   - Allows windowing. It allows users to select a range of interest in
     the picture. It can be disabled by the user.

   - Parallel data input line for carrying pixel data.

   - There is a horizontal sync(HSYNC) input which indicates one line of
     the frame is transmitted.

   - There is a vertical sync(VSYNC) input which indicates that one
     entire frame is transmitted. It can be configured for polarity.

THEORY OF OPERATION:
^^^^^^^^^^^^^^^^^^^^
     cam_clk_i is a pixel clock which changes on every pixel. Pixel data
     is taken as input through cam_data_i, and cam_hsync_i and
     cam_vsync_i indicate the horizontal and vertical sync value. It
     supports active low reset. It contains a udma dc fifo to store the
     pixel value before sending it to output.

BLOCK DIAGRAM:
^^^^^^^^^^^^^^^^^^^

   |image1|
   
   - Read write input pin, cfg_rwn_i indicates if we want to write to
     the register or read from the register. If the input is high then the
     register is selected for reading and else for writing. Address of the
     register is provided through cfg_addr_i.

   - Value read through the register is provided as output through
     cfg_data_o. 
   
   - cfg_data_i writes values to register.

   - Data in register REG_RX_SADDR is passed through cfg_rx_startaddr_o.
   
   - Data in register REG_RX_SIZE is passed through cfg_rx_size_o.

   - Data in the REG_RX_CFG is passed through cfg_rx_continuous_o,
     cfg_rx_en_o, cfg_rx_clr_o and data_rx_datasize_o.

   - Frame counter:
      ○ Frame counter is incremented at start of frame if frame drop is
      enabled.

      ○ Counter is reset if the counter value reaches frame drop value.or
      frame drop is disabled.

      ○ Frame drop enable status and frame drop value can be read from
      REG_CAM_CFG_GLOB.

      ○ Non zero frame counter value indicates a valid frame.

   - WINDOWING:
      ○ Window of interest can be selected by using the windowing
      feature.

      ○ Its enable or disable status can be read from REG_CAM_CFG_GLOB.

      ○ Coordinates of the window can be written to and read from
      REG_CAM_CFG_LL and REG_CAM_CFG_UR.

      ○ A pixel is valid only if it is inside the window of interest if
      windowing is enabled.

      ○ If windowing is disabled, pixels will be valid for every valid
      frame.

   - Row counter and column counter:
      ○ Counts the row and column at every camera clock.

      ○ Counter is reset at the start of the frame.

      ○ These counter values are used when windowing is enabled to check
      the validity of pixels.

      ○ Column counter is incremented at posedge of cam_clk_i. Column ends
      when the column counter reaches ROWLEN, which resets the counter
      value. ROWLEN value can be read from REG_CAM_CFG_SIZE.

      ○ Row counter is incremented at the end of each column.

  - IMAGE FORMAT: RGB565, RGB555, RGB444
      ○ RGB565: Five bits of data is allocated for the red and blue color
      component and 6 bits data for the green color component.

      ○ RGB555: Five bits of data is allocated for all the color
      components.

      ○ RGB444: Four bits of data is allocated for all the color
      components.

      ○ R, G, B pixel values can be read from cam_data_i.

      ○ Filter values for R, G, B can be obtained by multiplying their
      respective pixel values by their coefficients. Coefficient can be
      read from
      REG_CAM_CFG_FILTER.

      ○ Filter values for all the pixels are added and then shifted right
      to get the final pixel value which is then passed to fifo. Number of
      bits needed to be shifted can be read from REG_CAM_CFG_GLOB.

  - IMAGE FORMAT: BYPASS_LITEND, BYPASS_BIGEND
      ○ These image formats are used for YUV images. In the YUV image a
      color is described as a Y component(luma) and two chroma components
      U and V. Luma represents the brightness of the image and chroma
      conveys the color information of the picture.

      ○ YUV pixel value can be read from cam_data_i.

      ○ Filter is not valid.

  - Vertical sync:
      ○ Polarity can be read from REG_CAM_VSYNC_POLARITY..

      ○ A start of frame is marked by high current vsync value and low
      previous vsync.

  - udma_dc_fifo:
      ○ RGB or YUV pixel values are sent as input udma_dc_fifo.

      ○ Valid output is passed through data_rx_valid_o if there is data in
      fifo to be read.

      ○ Data can be read from the fifo through data_rx_data_o.

uDMA CAMERA CSRs
^^^^^^^^^^^^^^^^^

REG_RX_SADDR (Offset = 0x00)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - SADDR
     - 31:0
     - RW
     - 
     - Address of receive memory buffer:
   * -
     - 
     - 
     - 
     - Read: value of pointer until transfer is over, then 0
   * - 
     - 
     - 
     - 
     - Write: set memory buffer start address  
..

REG_RX_SIZE (Offset = 0x04)
^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - SIZE
     - 15:0
     - RW
     - 0x00
     - Buffer size in bytes (1MB max)
   * -
     - 
     - 
     - 
     - Read: bytes remaining until transfer complete
   * - 
     - 
     - 
     - 
     - Write: set number of bytes to transfer
..

REG_RX_CFG (Offset = 0x08)
^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
    :widths: 10 20 10 10 20
    :header-rows: 1

    * - Field
      - Bits
      - Type
      - Default
      - Description
    * - CLR
      - 6:6
      - WO
      - 0x00
      - Clear the receive channel
    * - PENDING
      - 5:5
      - RO
      - 0x00
      - Receive transaction is pending
    * - EN
      - 4:4
      - RW
      - 0x00
      - Enable the receive channel
    * - DATASIZE
      - 2:1
      - RW
      - 0X02
      - Controls uDMA address increment
    * - 
      - 
      - 
      -
      - 0x00: increment address by 1 (data is 8 bits)
        
        0x01: increment address by 2 (data is 16 bits)
    * - 
      - 
      - 
      -
      - 0x02: increment address by 4 (data is 32 bits)
    * - 
      - 
      - 
      -
      - 0x03: increment address by 0.
    * - CONTINUOUS
      - 0:0
      - RW
      - 0x00
      - 0x0: stop after last transfer for channel
    * - 
      - 
      - 
      -      
      - 0x1: after last transfer for channel 
        
        reload buffer size and start address and restart channel
..

REG_CAM_CFG_GLOB (Offset = 0x20)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
  :widths: 10 20 10 10 20
  :header-rows: 1

  * - Field
    - Bits
    - Type
    - Default
    - Description
  * - EN
    - 31:31
    - RW
    - 0x00
    - Enable data RX from camera interface
  * - 
    - 
    - 
    - 
    - Enable/disable only happens at start of frame
  * - 
    - 
    - 
    - 
    - 0x0: disable
  * - 
    - 
    - 
    - 
    - 0x1: enable
  * - SHIFT
    - 14:11
    - RW
    - 0x00
    - Number of bits to right shift final pixel value
  * - 
    - 
    - 
    - 
    - Note: not used if FORMAT == BYPASS
  * - FORMAT
    - 10:8
    - RW
    - 0x00
    - Input frame format:
  * - 
    - 
    - 
    - 
    - 0x0: RGB565
  * - 
    - 
    - 
    - 
    - 0x1: RGB555
  * - 
    - 
    - 
    - 
    - 0x2: RGB444
  * - 
    - 
    - 
    - 
    - 0x4: BYPASS_LITTLEEND
  * - 
    - 
    - 
    - 
    - 0x5: BYPASS_BIGEND
  * - FRAMEWINDOW_EN
    - 7:7
    - RW
    - 0x00
    - Windowing enable:
  * - 
    - 
    - 
    - 
    - 0x0: disable
  * - 
    - 
    - 
    - 
    - 0x1: enable
..
  
REG_CAM_CFG_LL (Offset = 0x24)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - SIZE
     - 15:0
     - RW
     - 0x00
     - Buffer size in bytes (1MB max)
   * -
     - 
     - 
     - 
     - Read: bytes remaining until transfer complete
   * - 
     - 
     - 
     - 
     - Write: set number of bytes to transfer
..

REG_CAM_CFG_UR (Offset = 0x28)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - SIZE
     - 31:16
     - RW
     - 0x00
     - Y coordinate of upper right corner of window.
   * - FRAMEWINDOW_URX
     - 15:0
     - RW
     - 0X00
     - X coordinate of upper right corner of window.
..

REG_CAM_CFG_SIZE (Offset = 0x2C)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - ROWLEN
     - 31:16
     - RW
     - 0x00
     - N-1 where N is the number of horizontal pixels
   * -
     - 
     - 
     - 
     - (used in window mode)
..

REG_CAM_CFG_FILTER (Offset = 0x30)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - R_COEFF
     - 23:16
     - RW
     - 0x00
     - Coefficent that multiplies R component
   * -
     - 
     - 
     - 
     - Note: not used if FORMAT == BYPASS
   * - G_COEFF
     - 15:8
     - RW
     - 0x00
     - Coefficent that multiplies G component
   * -
     - 
     - 
     - 
     - Note: not used if FORMAT == BYPASS
   * - B_COEFF
     - 7:0
     - RW
     - 0x00
     - Coefficent that multiplies B component
   * -
     - 
     - 
     - 
     - Note: not used if FORMAT == BYPASS
..

REG_CAM_VSYNC_POLARITY (Offset = 0x34)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. list-table::
   :widths: 10 20 10 10 20
   :header-rows: 1

   * - Field
     - Bits
     - Type
     - Default
     - Description
   * - VSYNC_POLARITY
     - 0:0
     - RW
     - 0x00
     - Set vsync polarity:
   * -
     - 
     - 
     - 
     - 0x0: Active low
   * -
     - 
     - 
     - 
     - 0x1: Active high
..

.. |image1| image:: udma_cam_image.png
   :width: 6.5in
   :height: 2.83333in
