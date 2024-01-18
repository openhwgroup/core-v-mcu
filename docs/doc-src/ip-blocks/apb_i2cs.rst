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
.. _apb_i2c_slave:

**APB I2C SLAVE**
=================

The I2C slave responds to the transaction made by the master.

**FEATURES:**

-  Supports 32 bit read and write data.

-  Interrupts may be generated in any direction.

-  Support 7 bit I2C addressing.

-  Data is transferred in the sequence of 8 bits.

**THEORY OF OPERATION:**

I2C slave contains i2c peripheral interface and APB slave interface.
There are FIFO and registers for handling communication with external
I2C controllers.

**Block diagram of APB I2C Peripheral:**

.. APB_I2C_slave_image:: APB_I2C_slave_image2.png
   :width: 6.5in
   :height: 3.38889in

**Block diagram of internal modules:**

.. APB_I2C_slave_image:: APB_I2C_slave_image3.png
   :width: 6.5in
   :height: 2.69444in

**APB SLAVE INTERFACE:**

-  APB slave interface is driving the APB output ports and input to register module.

-  A successful reset will clear apb_reg_waddr_o, apb_reg_wdata_o, apb_reg_wrenable_o, apb_reg_rd_byte_complete_o.

-  apb_pready_o is driven high if apb_psel_i and apb_penable_i are high.

-  apb_prdata_o is driven by apb_reg_rdata_i which we get from the i2c peripheral register.

-  apb_reg_raddr_o and apb_reg_waddr_o are driven by apb_paddr_i.

-  apb_reg_wdata_o is driven by apb_pwdata_i.

-  apb_reg_wrenable_o is driven high if apb_psel_i, apb_penable_i and apb_pwrite_i are high else it is driven low.

-  apb_reg_rd_byte_complete_o is driven high if apb_psel_i and apb_penable_i are high and apb_pwrite_i is low else it is driven low.

**I2C PERIPHERAL REGISTER:**

I2C peripheral register is assigning value to CSRs and driving the
interrupt port for APB and I2C. It is taking input from APB slave
interface and i2c interface.

There are two FIFO instantiated in this module:

-  FIFO_sync_256x8_i2c_to_apb: Transfer data from i2c to apb.

-  FIFO_sync_256x8_apb_to_i2c: Transfer data from apb to i2c.

**I2C PERIPHERAL INTERFACE:** 

START AND STOP CONDITION:

-  The start and stop sequence mark the start and end of the transaction.e

..

   .. APB_I2C_slave_image:: APB_I2C_slave_image1.png
      :width: 6.41667in
      :height: 1.98958in

-  To generate the start condition, the data line should change from high to low while the clock is high.

-  To generate the stop condition, the data line should change from low to high while the clock is high.

READ/WRITE BIT:

-  When sending out the 7 bit address we still send 8 bits. The last bit is used to inform if the master wants to write to the slave or read from the slave. If the bit is 0, master is writing to the slave else it is reading from the slave.

ACKNOWLEDGEMENT BIT:

-  For every 8 bit transfer the device receiving the data sends an acknowledgement bit.

   .. APB_I2C_slave_image:: APB_I2C_slave_image4.png
      :width: 5.16667in
      :height: 1.14583in

-  Low acknowledgement bit sent by the receiving device indicate that it has received the data and it is ready to accept another byte.

-  High acknowledgement bit sent by the receiving device indicate that it cannot accept new data and the master should terminate the transfer.

**I2C STATES:**

-  I2C slave has 10 states:

   -  ST_IDLE:

      -  Initially slave is in this state.

      -  Slave may also come to this state if stop is detected.

   -  ST_DEVADDR:

      -  Slave comes to this state after the start sequence is detected and i2c_enabled_i is high.

      -  Slave receives the device address and transfer type (read/write).

      -  Stop the transfer if the device address is not received.

   -  ST_DEVADDRACK:

      -  Slave comes to this state after receiving the i2c device address and sends the acknowledgement.

      -  i2c_sda_o is driven low to indicate successful acknowledgement.

      -  Acknowledgement is released by driving i2c_sda_o to high before new transfer.

      -  Read operation sets i2c state to ST_REGRDATA. I2c_reg_rddata_i is driven to i2c_sda_o.

      -  Write operation sets i2c state to ST_REGADDR.

   -  ST_REGADDR:

      -  If the master wants to write then the slave comes to this state.

      -  Slave receives the register address inside the device where the master wants to write. This register address is driven to i2c_reg_addr_o.

   -  ST_REGADDRACK:

      -  After receiving the register address successfully the slave comes to this state and sends acknowledgement.

      -  i2c_sda_o is driven low to indicate successful acknowledgement.

      -  Acknowledgement is released by driving i2c_sda_o to high before new transfer.

   -  ST_REGWDATA:

      -  After sending acknowledgement, the slave comes to this state and writes data to the register.

      -  I2c_reg_wrenable is driven high.

   -  ST_REGWDATAACK:

      -  After successfully writing the data, an acknowledgement bit is sent.

      -  I2c_reg_wrenable is driven low.

      -  i2c_sda_o is driven low to indicate successful acknowledgement.

      -  Acknowledgement is released by driving i2c_sda_o to high before new transfer.

   -  ST_REGRDATA:

      -  Slave comes to this state if the master wants to read the data.

      -  After successful read i2c_rd_byte_complete is driven high.

   -  ST_REGRDATAACK:

      -  After successful reading, acknowledgement is received.

      -  I2c_rd_byte_complete is cleared.

      -  If negative acknowledgement is received, transfer is stopped.

      -  If successful acknowledgement is received then i2c state is set to ST_REGRDATA and more data is read.

   -  ST_WTSTOP:

      -  Slave comes to this state if there is no more transaction or we want to stop the transfer.

**APB I2C CSR's:**
------------------

**I2CS_DEV_ADDRESS:Offset = 0x000**

+------------------+------+------+---------+------------------------------+
| Field            | Bits | Type | Default | Description                  |
+==================+======+======+=========+==============================+
| RESERVED         | 7:7  | RW   |         | Reserved                     |
+------------------+------+------+---------+------------------------------+
| SLAVE_ADDR       | 6:0  | RW   | 0X6F    | I2C device address           |
+------------------+------+------+---------+------------------------------+

**I2CS_ENABLE:Offset = 0X004**

+------------------+------+------+---------+------------------------------+
| Field            | Bits | Type | Default | Description                  |
+==================+======+======+=========+==============================+
| RESERVED         | 7:1  | RW   |         | Reserved                     |
+------------------+------+------+---------+------------------------------+
| IP_ENABLE        | 0:0  | RW   | 0X00    | IP enabling bit              |
+------------------+------+------+---------+------------------------------+

**I2CS_DEBOUNCE_LENGTH:Offset = 0x008**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| DEB_LEN          | 7:0  | RW   | 0X14    | Represents the number of    |
|                  |      |      |         | system clocks over which    |
|                  |      |      |         | each I2C line (SL and SDA)  |
|                  |      |      |         | should be debounced.        |
+------------------+------+------+---------+-----------------------------+

**I2CS_SCL_DELAY_LENGTH:Offset = 0x00C**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| SCL_DLY_LEN      | 7:0  | RW   | 0X14    | Represents the number of    |
|                  |      |      |         | system clocks over which    |
|                  |      |      |         | the SCL line will be delayed|
|                  |      |      |         | relative to SDA line        |
+------------------+------+------+---------+-----------------------------+

**I2CS_SDA_DELAY_LENGTH:Offset = 0x010**

+------------------+------+------+--------+-----------------------------+
| Field            | Bits | Type | Default| Description                 |
+==================+======+======+========+=============================+
| SDA_DLY_LEN      | 7:0  | RW   | 0X08   | Represents the number of    |
|                  |      |      |        | system clocks over which    |
|                  |      |      |        | the SDA line will be        |
|                  |      |      |        | delayed relative to the SCL |
|                  |      |      |        | line.                       |
+------------------+------+------+--------+-----------------------------+

**I2CS_MSG_I2C_APB:Offset = 0x040**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| I2C_TO_APB       | 7:0  | RW   | 0X00    | This register provide a     |
|                  |      |      |         | method for passing a single |
|                  |      |      |         | byte message from the I2C   |
|                  |      |      |         | interface to the APB        |
|                  |      |      |         | interface.                  |
+------------------+------+------+---------+-----------------------------+

**I2CS_MSG_I2C_APB_STATUS:Offset = 0x044**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:1  | RW   |         |                             |
+------------------+------+------+---------+-----------------------------+
|I2C_TO_APB_STATUS | 0:0  | RW   | 0X00    | This register provide a     |
|                  |      |      |         | method for passing a single |
|                  |      |      |         | byte message from the I2C   |
|                  |      |      |         | interface to the APB        |
|                  |      |      |         | interface.                  |
+------------------+------+------+---------+-----------------------------+

**I2CS_MSG_APB_I2C:Offset = 0x048**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| APB_TO_I2C       | 7:0  | RW   | 0X00    | This register provides a    |
|                  |      |      |         | method for passing a single |
|                  |      |      |         | byte message from the APB   |
|                  |      |      |         | interface to the I2C        |
|                  |      |      |         | interface.                  |
+------------------+------+------+---------+-----------------------------+

**I2CS_MSG_APB_I2C_STATUS:Offset = 0x4C**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:1  | RW   |         |                             |
+------------------+------+------+---------+-----------------------------+
|APB_TO_I2C_STATUS | 0:0  | RW   | 0X00    | This register provides a    |
|                  |      |      |         | method for passing a single |
|                  |      |      |         | byte message from the APB   |
|                  |      |      |         | interface to the I2C        |
|                  |      |      |         | interface.                  |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_I2C_APB_WRITE_DATA_PORT:Offset = 0x080**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| I2C_APB_WRITE_DA | 31:0 | RW   |         | This is the write data port |
| TA_PORT          |      |      |         | for the I2C to APB fifo.    |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_I2C_APB_READ_DATA_PORT:Offset = 0x084**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| I2C_APB_READ_DA  | 31:0 | RW   |         | This is the read data port  |
| TA_PORT          |      |      |         | for the I2C to APB fifo.    |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_I2C_APB_FLUSH:Offset = 0x088**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:1  | RW   |         | RESERVED                    |
+------------------+------+------+---------+-----------------------------+
| ENABLE           | 0:0  | RW   |         | Writing a 1 to this         |
|                  |      |      |         | register bit will flush     |
|                  |      |      |         | the I2CtoAPB FIFO clearing  |
|                  |      |      |         | all the contents and        |
|                  |      |      |         | rendering the FIFO to be    |
|                  |      |      |         | empty.                      |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_I2C_APB_WRITE_FLAGS:Offset = 0x08C**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:3  | RW   |         | RESERVED                    |
+------------------+------+------+---------+-----------------------------+
| FLAGS            | 2:0  | RW   |         | Represent the number of     |
|                  |      |      |         | spaces left in FIFO.        |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_I2C_APB_READ_FLAGS:Offset = 0x90**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:3  | RW   |         | RESERVED                    |
+------------------+------+------+---------+-----------------------------+
| FLAGS            | 2:0  | RW   |         | Represent the items         |
|                  |      |      |         | present in FIFO to read.    |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_APB_I2C_WRITE_DATA_PORT:Offset = 0X0C0**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| I2C_APB_WRITE_DA | 31:0 | RW   |         | This is the write data      |
| TA_PORT          |      |      |         | port for the APBtoI2C FIFO  |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_APB_I2C_READ_DATA_PORT:Offset = 0X0C4**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| I2C_APB_READ_DA  | 31:0 | RW   |         | This is the read data       |
| TA_PORT          |      |      |         | port for the APBtoI2C FIFO  |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_APB_I2C_FLUSH:Offset = 0X0C8**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:1  | RW   |         | RESERVED                    |
+------------------+------+------+---------+-----------------------------+
| ENABLE           | 0:0  | RW   |         | Writing a 1 to this         |
|                  |      |      |         | register bit will flush     |
|                  |      |      |         | the APBtoI2C FIFO,          |
|                  |      |      |         | clearing all contents and   |
|                  |      |      |         | rendering the FIFO to be    |
|                  |      |      |         | empty.                      |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_APB_I2C_WRITE_FLAGS:Offset = 0X0CC**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:3  | R    |         |                             |
+------------------+------+------+---------+-----------------------------+
| FLAGS            | 2:0  | R    |         | Represent number of spaces  |
|                  |      |      |         | left in FIFO                |
+------------------+------+------+---------+-----------------------------+

**I2CS_FIFO_APB_I2C_READ_FLAGS:Offset = 0X0D0**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:3  | R    |         |                             |
+------------------+------+------+---------+-----------------------------+
| FLAGS            | 2:0  | R    |         | Represent the items         |
|                  |      |      |         | present in FIFO to read.    |
+------------------+------+------+---------+-----------------------------+

**I2CS_INTERRUPT_STATUS:Offset = 0x100**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:3  | R    |         | Reserved                    |
+------------------+------+------+---------+-----------------------------+
| I2C_APB_F        | 2:2  | R    |         | 1: Interrupt is generated   |
| IFO_WRITE_STATUS |      |      |         | for this field              |
|                  |      |      |         | 0: Not genertated           |
+------------------+------+------+---------+-----------------------------+
| APB_I2C_F        | 1:1  | R    |         | 1: Interrupt is generated   |
| IFO_READ_STATUS  |      |      |         | for this field              |
|                  |      |      |         | 0: Not genertated           |
+------------------+------+------+---------+-----------------------------+
| APB_I2C_M        | 0:0  | R    |         | 1: Interrupt is generated   |
| ESSAGE_AVAILABLE |      |      |         | for this field              |
|                  |      |      |         | 0: Not genertated           |
+------------------+------+------+---------+-----------------------------+

**I2CS_INTERRUPT_ENABLE:Offset = 0x104**

+------------------+------+------+---------+-----------------------------+
| Field            | Bits | Type | Default | Description                 |
+==================+======+======+=========+=============================+
| RESERVED         | 7:3  | RW   |         | Reserved                    |
+------------------+------+------+---------+-----------------------------+
| I2C_A            | 2:2  | RW   |         | 1: enabled                  |
| PB_FIFO_WRITE_S  |      |      |         |                             |
| TATUS_INT_ENABLE |      |      |         |                             |
+------------------+------+------+---------+-----------------------------+
| APB_I2C_F        | 1:1  | RW   |         | 1: enabled                  |
| IFO_READ_S       |      |      |         |                             |
| TATUS_INT_ENABLE |      |      |         |                             |
+------------------+------+------+---------+-----------------------------+
| APB_I2C_M        | 0:0  | RW   |         | 1: enabled                  |
| ESSAGE_AVAI      |      |      |         |                             |
| LABLE_INT_ENABLE |      |      |         |                             |
+------------------+------+------+---------+-----------------------------+

**I2CS_INTERRUPT_I2C_APB_WRITE_FLAGS_SELECT:Offset = 0x108**

+------------------+-----+------+-------+----------------------------+
| Field            | Bits| Type |Default| Description                |
+==================+=====+======+=======+============================+
| WRITE_FLAG_FULL  | 7:7 | RW   |       | 1:The write FIFO is full   |
+------------------+-----+------+-------+----------------------------+
| WRITE_FL         | 6:6 | RW   |       | 1: one space left          |
| AG_1_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG       | 5:5 | RW   |       | 1: 2-3 spaces left         |
| _2_3_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG       | 4:4 | RW   |       | 1: 4-7 spaces left         |
| _4_7_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG       | 3:3 | RW   |       | 1: 8-31 spaces left        |
| _8_31_SPACE_AVAIL|     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG_3     | 2:2 | RW   |       | 1: 32-63 spaces left       |
| 2_63_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG_64    | 1:1 | RW   |       | 1: 64-127 spaces left      |
| _127_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG_1     | 0:0 | RW   |       | 1: 128+ spaces left        |
| 28__SPACE_AVAIL  |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+

**I2CS_INTERRUPT_APB_I2C_READ_FLAGS_SELECT:Offset = 0x10C**

+------------------+-----+------+-------+----------------------------+
| Field            | Bits| Type |Default| Description                |
+==================+=====+======+=======+============================+
| READ_FLAG        | 7:7 | RW   |       | 1: 128 items present       |
| _128_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_64     | 6:6 | RW   |       | 1: 64-127 items to read    |
| _127_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAAG_3     | 5:5 | RW   |       | 1: 32-63 items present     |
| 2_63_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_8      | 4:4 | RW   |       | 1: 8-31 items              |
| _31_SPACE_AVAIL  |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG        | 3:3 | RW   |       | 1: 4-7 items               |
| _4_7_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG        | 2:2 | RW   |       | 1: 2-3 items               |
| _2_3_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FL          | 1:1 | RW   |       | 1: 1 item                  |
| AG_1_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_EMPTY  | 0:0 | RW   |       | 1: 0 items, empty          |
+------------------+-----+------+-------+----------------------------+

**I2CS_INTERRUPT_TO_APB_STATUS:Offset = 0x140**

+------------------+-----+------+-------+----------------------------+
| Field            | Bits| Type |Default| Description                |
+==================+=====+======+=======+============================+
| RESERVED         | 7:3 | RW   |       | Reserved                   |
+------------------+-----+------+-------+----------------------------+
| APB_I2C_F        | 2:2 | RW   |       | Interrupt status           |
| IFO_WRITE_STATUS |     |      |       | representing whether       |
|                  |     |      |       | interrupt will generate or |
|                  |     |      |       | not.                       |
|                  |     |      |       | 1: Interrupt generated     |
+------------------+-----+------+-------+----------------------------+
| I2C_APB_F        | 1:1 | RW   |       | Interrupt status           |
| IFO_READ_STATUS  |     |      |       | representing whether       |
|                  |     |      |       | interrupt will generate or |
|                  |     |      |       | not.                       |
|                  |     |      |       | 1: Interrupt generated     |
+------------------+-----+------+-------+----------------------------+
| NEW_I            | 0:0 | RW   |       | Interrupt status           |
| 2C_APB_MSG_AVAIL |     |      |       | representing whether       |
|                  |     |      |       | interrupt will generate or |
|                  |     |      |       | not.                       |
|                  |     |      |       | 1: Interrupt generated     |
+------------------+-----+------+-------+----------------------------+

**I2CS_INTERRUPT_TO_APB_ENABLE:Offset = 0x0144**

+------------------+-----+------+-------+----------------------------+
| Field            | Bits| Type |Default| Description                |
+==================+=====+======+=======+============================+
| RESERVED         | 7:3 | RW   |       | Reserved                   |
+------------------+-----+------+-------+----------------------------+
| APB_I2C_FIFO_WRI | 2:2 | RW   |       | 1: enabled                 |
| TE_STATUS_ENABLE |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| I2C_APB_FIFO_RE  | 1:1 | RW   |       | 1: enabled                 |
| AD_STATUS_ENABLE |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| NEW_I2C_APB_M    | 0:0 | RW   |       | 1: enabled                 |
| SG_AVAIL_ENABLE  |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+

**I2CS_INTERRUPT_APB_I2C_WRITE_FLAGS_SELECT:Offset = 0x148**

+------------------+-----+------+-------+----------------------------+
| Field            | Bits| Type |Default| Description                |
+==================+=====+======+=======+============================+
| WRITE_FLAG_FULL  | 7:7 | RW   |       | 1 : The Write FIFO is full |
+------------------+-----+------+-------+----------------------------+
| WRITE_FL         | 6:6 | RW   |       | 1: one space left          |
| AG_1_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG       | 5:5 | RW   |       | 1: 2-3 spaces left         |
| _2_3_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG       | 4:4 | RW   |       | 1: 4-7 spaces left         |
| _4_7_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG_8     | 3:3 | RW   |       | 1: 8-31 spaces left        |
| _31_SPACE_AVAIL  |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG_3     | 2:2 | RW   |       | 1: 32-63 spaces left       |
| 2_63_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG_64    | 1:1 | RW   |       | 1: 64-127 spaces left      |
| _127_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| WRITE_FLAG       | 0:0 | RW   |       | 1: 128+ spaces left        |
| _128_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+

**I2CS_INTERRUPT_I2C_APB_READ_FLAGS_SELECT:Offset = 0x14C**

+------------------+-----+------+-------+----------------------------+
| Field            | Bits| Type |Default| Description                |
+==================+=====+======+=======+============================+
| READ_FLAG        | 7:7 | RW   |       | 1: 128 items present       |
| _128_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_64     | 6:6 | RW   |       | 1: 64 - 127 items present  |
| _127_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_3      | 5:5 | RW   |       | 1: 32-63 items present     |
| 2_63_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_8      | 4:4 | RW   |       | 1: 8-31 items present      |
| _31_SPACE_AVAIL  |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG        | 3:3 | RW   |       | 1: 4-7 items present       |
| _4_7_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG        | 2:2 | RW   |       | 1: 2-3 items present       |
| _2_3_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FL          | 1:1 | RW   |       | 1: 1 item present          |
| AG_1_SPACE_AVAIL |     |      |       |                            |
+------------------+-----+------+-------+----------------------------+
| READ_FLAG_EMPTY  | 0:0 | RW   |       | 1: 0 items, empty          |
+------------------+-----+------+-------+----------------------------+