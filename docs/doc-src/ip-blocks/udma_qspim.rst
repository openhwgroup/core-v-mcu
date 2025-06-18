..
   Copyright (c) 2023 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. Level 1
   =======

   Level 2
   -------

   Level 3
   ~~~~~~~

   Level 4
   ^^^^^^^

.. _udma_qspim:

UDMA QSPI Master
================

The Standard Peripheral Interface bus (SPI) is a synchronous serial communication interface specification used for short distance communications.
The interface has been developed first by Motorola and now has become a de facto standard.

The CORE-V-MCU QSPI Master supports an implementation of the SPI and the QSPI (Quad SPI) mode enabling higher bandwidths required by modern embedded devices.
Due to the lack of a formal standard it is impossible to make a claim of compliance to the protocol.
However, CORE-V-MCU’s QSPI interface is known to work with the Micron N25Q256A Serial NOR Flash Memory and *should* work with a large set of QSPI and SPI devices.
The QSPI master described here has some limitations to the supported variants of the SPI protocol.
The major limitation is the lack of support for the full duplex transfers.

Features
--------

Block Architecture
------------------

uDMA QSPI is a peripheral function of the uDMA subsystem. As such, its CSRs are not directly accessible via the APB bus. Rather, the control plane interface to the uDMA QSPI is managed by the uDMA core within the uDMA subsystem.
This is transparent to the programmer as all uDMA QSPI CSRs appear within the uDMA Subsystem's memory region. As is the case for all uDMA subsystem peripherals, I/O operations are controlled by the uDMA core. This is not transparent to the programmer.

The Figure below is a high-level block diagram of the uDMA QSPI:-

.. figure:: uDMA_QSPI_Block_Diagram.png
   :name: uDMA_QSPI_Block_Diagram
   :align: center
   :alt:

   uDMA QSPI Block Diagram

RX operation
^^^^^^^^^^^^

TX operation
^^^^^^^^^^^^


Example Transactions
--------------------
Below are examples of typical writes and reads to external memories using the standard 4-wire SPI protocol.

.. figure:: ../../images/simple_spi_write_transfer.png
   :name: Simple_SPI_Write_Transfer
   :align: center
   :alt: 

   Simple SPI Write Transfer

.. figure:: ../../images/simple_spi_read_transfer.png
   :name: Simple_SPI_Read_Transfer
   :align: center
   :alt: 

   Simple SPI Read Transfer

Next we see an example transfer in QSPI mode.
All 4 datalines are bidirectional and the communication is always half duplex.

.. figure:: ../../images/quad_spi_transfer.png
   :name: Quad_SPI_Transfer
   :align: center
   :alt: 

   Quad SPI Transfer


UDMA QSPI Control Buffer
------------------------

The actions of the QSPI controller are controlled using a sequence of commands that are written to the transmit buffer.
Therefore, to use the QSPI driver software must assemble the appropriate sequence of commands in a buffer, and use the uDMA to send the buffer to the QSPI contoller.
Note that the uDMA core manages both data buffers and interrupts on behalf of the QSPI controller.

+------+----------------------+-------+----------------------------------------------------+
| Code |   Command/Field      |  Bits | Description                                        |
+======+======================+=======+====================================================+
| 0x0  |     SPI_CMD_CFG      |       | Sets the configuration for the SPI Master IP       |
+------+----------------------+-------+----------------------------------------------------+
|      |          CLKDIV      |   7:0 | Sets the clock divider value                       |
+------+----------------------+-------+----------------------------------------------------+
|      |            CPHA      |   8:8 | Sets the clock phase:                              |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0:                                               |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1:                                               |
+------+----------------------+-------+----------------------------------------------------+
|      |            CPOL      |   9:9 | Sets the clock polarity:                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0:                                               |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1:                                               |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x0)                           |
+------+----------------------+-------+----------------------------------------------------+
| 0x1  |     SPI_CMD_SOT      |       | Sets the Chip Select (CS)                          |
+------+----------------------+-------+----------------------------------------------------+
|      |              CS      |   1:0 | Sets the Chip Select (CS):                         |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: select csn0                                   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: select csn1                                   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x2: select csn2                                   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x3: select csn3                                   |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x1)                           |
+------+----------------------+-------+----------------------------------------------------+
| 0x2  | SPI_CMD_SEND_CMD     |       | Transmits up to 16bits of data sent in the command |
+------+----------------------+-------+----------------------------------------------------+
|      |      DATA_VALUE      |  15:0 | Sets the command to send.                          |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | MSB must always be at bit 15                       |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |  if cmd size is less than 16                       |
+------+----------------------+-------+----------------------------------------------------+
|      |       DATA_SIZE      | 19:16 | N-1,  where N is the size in bits of the command   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | to send                                            |
+------+----------------------+-------+----------------------------------------------------+
|      |             LSB      | 26:26 | Sends the data starting from LSB                   |
+------+----------------------+-------+----------------------------------------------------+
|      |             QPI      | 27:27 | Sends the command using QuadSPI                    |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x2)                           |
+------+----------------------+-------+----------------------------------------------------+
| 0x4  |   SPI_CMD_DUMMY      |       | Receives a number of dummy bits                    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | which are not sent to the RX interface             |
+------+----------------------+-------+----------------------------------------------------+
|      |     DUMMY_CYCLE      | 21:16 | Number of dummy cycles to perform                  |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x4)                           |
+------+----------------------+-------+----------------------------------------------------+
| 0x5  |    SPI_CMD_WAIT      |       | Waits for an external event to move to the next    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | instruction                                        |
+------+----------------------+-------+----------------------------------------------------+
|      | EVENT_ID_CYCLE_COUNT |   6:0 | External event id or Number of wait cycles         |
+------+----------------------+-------+----------------------------------------------------+
|      |       WAIT_TYPE      |   9:8 | Type of wait:                                      |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: wait for and soc event selected by EVENT_ID   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: wait CYCLE_COUNT cycles                       |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x2: rfu                                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x3: rfu                                           |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x5)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0x6  | SPI_CMD_TX_DATA      |       | Sends data (max 256Kbits)                          |
+------+----------------------+-------+----------------------------------------------------+
|      |        WORD_NUM      |  15:0 | N-1, where N is the number of words to send        |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | (max 64K)                                          |
+------+----------------------+-------+----------------------------------------------------+
|      |       WORD_SIZE      | 20:16 | N-1, where N is the number of bits in each word    |
+------+----------------------+-------+----------------------------------------------------+
|      | WORD_PER_TRANSF      | 22:21 | Number of words transferred from SRAM at           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | each transfer                                      |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: 1 word per transfer                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: 2 words per transfer                          |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x2: 4 words per transfer                          |
+------+----------------------+-------+----------------------------------------------------+
|      |             LSB      | 26:26 | 0x0: MSB first                                     |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: LSB first                                     |
+------+----------------------+-------+----------------------------------------------------+
|      |             QPI      | 27:27 | 0x0: single bit data                               |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: quad SPI mode                                 |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x6)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0x7  | SPI_CMD_RX_DATA      |       | Receives data (max 256Kbits)                       |
+------+----------------------+-------+----------------------------------------------------+
|      |        WORD_NUM      |  15:0 | N-1, where N is the number of words to send        |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | (max 64K)                                          |
+------+----------------------+-------+----------------------------------------------------+
|      |       WORD_SIZE      | 20:16 | N-1, where N is the number of bits in each word    |
+------+----------------------+-------+----------------------------------------------------+
|      | WORD_PER_TRANSF      | 22:21 | Number of words transferred from SRAM at           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | each transfer                                      |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: 1 word per transfer                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: 2 words per transfer                          |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x2: 4 words per transfer                          |
+------+----------------------+-------+----------------------------------------------------+
|      |             LSB      | 26:26 | 0x0: MSB first                                     |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: LSB first                                     |
+------+----------------------+-------+----------------------------------------------------+
|      |             QPI      | 27:27 | 0x0: single bit data                               |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: quad SPI mode                                 |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x7)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0x8  |     SPI_CMD_RPT      |       | Repeat the commands until RTP_END for N            |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | times                                              |
+------+----------------------+-------+----------------------------------------------------+
|      |         RPT_CNT      |  15:0 | Number of repeat iterations (max 64K)              |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x8)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0x9  |     SPI_CMD_EOT      |       | Clears the Chip Select (CS)                        |
+------+----------------------+-------+----------------------------------------------------+
|      |       EVENT_GEN      |   0:0 | Enable EOT event:                                  |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: disable                                       |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: enable                                        |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0x9)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0xA  | SPI_CMD_RPT_END      |       | End of the repeat loop command                     |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0xA)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0xB  | SPI_CMD_RX_CHECK     |       | Checks up to 16 bits of data against an expected   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | value                                              |
+------+----------------------+-------+----------------------------------------------------+
|      |       COMP_DATA      |  15:0 | Data to compare                                    |
+------+----------------------+-------+----------------------------------------------------+
|      |     STATUS_SIZE      | 19:16 | N-1, where N is the size in bits of the word       |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | to read                                            |
+------+----------------------+-------+----------------------------------------------------+
|      |      CHECK_TYPE      | 25:24 | How to compare:                                    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: compare bit by bit                            |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: compare only ones                             |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x2: compare only zeros                            |
+------+----------------------+-------+----------------------------------------------------+
|      |             LSB      | 26:26 | 0x0: Receieved data is LSB first                   |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: Received data is MSB first                    |
+------+----------------------+-------+----------------------------------------------------+
|      |             QPI      | 27:27 | 0x0: single bit data                               |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: quad SPI mode                                 |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0xB)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0xC  | SPI_CMD_FULL_DUPL    |       | Activate full duplex mode                          |
+------+----------------------+-------+----------------------------------------------------+
|      |       DATA_SIZE      |  15:0 | N-1, where N is the number of bits to send         |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | (max 64K)                                          |
+------+----------------------+-------+----------------------------------------------------+
|      |             LSB      | 26:26 | 0x0: Data is LSB first                             |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: Data is MSB first                             |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0xC)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0xD  | SPI_CMD_SETUP_UCA    |       | Sets address for uDMA tx/rx channel                |
+------+----------------------+-------+----------------------------------------------------+
|      |      START_ADDR      |  20:0 | Address of start of buffer                         |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0xD)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
| 0xE  | SPI_CMD_SETUP_UCS    |       | Sets size and starts uDMA tx/rx channel            |
+------+----------------------+-------+----------------------------------------------------+
|      |            SIZE      |       | N-1, where N is the number of bytes to transfer    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |  (max size depends on the TRANS_SIZE parameter)    |
+------+----------------------+-------+----------------------------------------------------+
|      | WORD_PER_TRANSF      | 26:25 | Number of words from SRAM for each transfer:       |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: 1 word per transfer                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: 2 words per transfer                          |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x2: 4 words per transfer                          |
+------+----------------------+-------+----------------------------------------------------+
|      |          TX_RXN      | 27:27 | Selects TX or RX channel:                          |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x0: RX channel                                    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       | 0x1: TX channel                                    |
+------+----------------------+-------+----------------------------------------------------+
|      |         SPI_CMD      | 31:28 | Command to execute (0xE)                           |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+
|      |                      |       |                                                    |
+------+----------------------+-------+----------------------------------------------------+

System Architecture
-------------------

The figure below shows how the uDMA QSPI interfaces with the rest of the CORE-V-MCU components and the external QSPI device:-

.. figure:: uDMA-QSPI-CORE-V-MCU-Connection-Diagram.png
   :name: uDMA-QSPI-CORE-V-MCU-Connection-Diagram
   :align: center
   :alt:

   uDMA QSPI CORE-V-MCU connection diagram

Programming Model
------------------
As with the most peripherals in the uDMA Subsystem, software configuration can be conceptualized into three functions:

- Configure the I/O parameters of the peripheral (e.g. baud rate).
- Configure the uDMA data control parameters.
- Manage the data transfer/reception operation.

uDMA QSPI Data Control
^^^^^^^^^^^^^^^^^^^^^^
Refer to the Firmware Guidelines section in the current chapter.

Data Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^
Refer to the Firmware Guidelines section in the current chapter.

uDMA QSPI CSRs
--------------
Refer to `Memory Map <https://github.com/openhwgroup/core-v-mcu/blob/master/docs/doc-src/mmap.rst>`_ for peripheral domain address of the uDMA QSPI0 and uDMA QSPI1.

**NOTE:** Several of the uDMA QSPI CSR are volatile, meaning that their read value may be changed by the hardware.
For example, writting the *RX_SADDR* CSR will set the address of the receive buffer pointer.
As data is received, the hardware will update the value of the pointer to indicate the current address.
As the name suggests, the value of non-volatile CSRs is not changed by the hardware.
These CSRs retain the last value writen by software.

A CSRs volatility is indicated by its "type".

Details of CSR access type are explained `here <https://docs.openhwgroup.org/projects/core-v-mcu/doc-src/mmap.html#csr-access-types>`_.

The CSRs RX_SADDR, RX_SIZE specifies the configuration for the transaction on the RX channel. The CSRs TX_SADDR, TX_SIZE specify the configuration for the transaction on the TX channel. The uDMA Core creates a local copy of this information at its end and use it for current ongoing transaction.

RX_SADDR
^^^^^^^^
- Offset: 0x0
- Type:   volatile

+--------+------+--------+------------+----------------------------------------------------------------------------------------------------------+
| Field  | Bits | Access | Default    | Description                                                                                              |
+========+======+========+============+==========================================================================================================+
| SADDR  | 18:0 | RW     |    0x0     | Address of the Rx buffer. This is location in the L2 memory where QSPI will write the recived data.      |
|        |      |        |            | Read & write to this CSR access different information.                                                   |
|        |      |        |            |                                                                                                          |
|        |      |        |            | **On Write**: Address of Rx buffer for next transaction. It does not impact current ongoing transaction. |
|        |      |        |            |                                                                                                          |
|        |      |        |            | **On Read**:  Address of read buffer for the current ongoing transaction. This is the local copy of      |
|        |      |        |            | information maintained inside the uDMA core.                                                             |
+--------+------+--------+------------+----------------------------------------------------------------------------------------------------------+

RX_SIZE
^^^^^^^
- Offset: 0x04
- Type:   volatile

+-------+-------+--------+------------+--------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                |
+=======+=======+========+============+============================================================================================+
| SIZE  |  19:0 |   RW   |    0x0     | Size of Rx buffer(amount of data to be transferred by QSPI to L2 memory). Read & write     |
|       |       |        |            | to this CSR access different information.                                                  |
|       |       |        |            |                                                                                            |
|       |       |        |            | **On Write**: Size of Rx buffer for next transaction.  It does not impact current ongoing  |
|       |       |        |            | transaction.                                                                               |
|       |       |        |            |                                                                                            |
|       |       |        |            | **On Read**:  Bytes left for current ongoing transaction.  This is the local copy of       |
|       |       |        |            | information maintained inside the uDMA core.                                               |
+-------+-------+--------+------------+--------------------------------------------------------------------------------------------+

RX_CFG
^^^^^^
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
| DATASIZE   |   2:1 |   RW   |    0x02    | Controls uDMA address increment                                                    |
|            |       |        |            |                                                                                    |
|            |       |        |            | - 0x00: increment address by 1 (data is 8 bits)                                    |
|            |       |        |            | - 0x01: increment address by 2 (data is 16 bits)                                   |
|            |       |        |            | - 0x02: increment address by 4 (data is 32 bits)                                   |
|            |       |        |            | - 0x03: increment address by 0                                                     |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW   |    0x0     | - 0x0: stop after last transfer for channel                                        |
|            |       |        |            | - 0x1: after last transfer for channel, reload buffer size                         |
|            |       |        |            |   and start address and restart channel                                            |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+

TX_SADDR
^^^^^^^^
- Offset: 0x10
- Type:   volatile

+-------+-------+--------+------------+-------------------------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                                 |
+=======+=======+========+============+=============================================================================================================+
| SADDR |  18:0 |   RW   |    0x0     | Address of the Tx buffer. This is location in the L2 memory from where QSPI will read the data to transmit. |
|       |       |        |            | Read & write to this CSR access different information.                                                      |
|       |       |        |            |                                                                                                             |
|       |       |        |            | **On Write**: Address of Tx buffer for next transaction. It does not impact current ongoing transaction.    |
|       |       |        |            |                                                                                                             |
|       |       |        |            | **On Read**: Address of Tx buffer for the current ongoing transaction.This is the local copy of information |
|       |       |        |            | maintained inside the uDMA core.                                                                            |
+-------+-------+--------+------------+-------------------------------------------------------------------------------------------------------------+

TX_SIZE
^^^^^^^
- Offset: 0x14
- Type:   volatile

+-------+-------+--------+------------+--------------------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                            |
+=======+=======+========+============+========================================================================================================+
| SIZE  |  19:0 |   RW   |    0x0     | Size of Tx buffer(amount of data to be read by QSPI from L2 memory for Tx operation). Read & write     |
|       |       |        |            | to this CSR access different information.                                                              |
|       |       |        |            |                                                                                                        |
|       |       |        |            | **On Write**: Size of Tx buffer for next transaction. It does not impact current ongoing transaction.  |
|       |       |        |            |                                                                                                        |
|       |       |        |            | **On Read**: Bytes left for current ongoing transaction, i.e. bytes left to read from L2 memory. This  |
|       |       |        |            | is the local copy of information maintained inside the uDMA core.                                      |
+-------+-------+--------+------------+--------------------------------------------------------------------------------------------------------+

TX_CFG
^^^^^^
- Offset: 0x18
- Type:   volatile

+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| Field      |  Bits | Access | Default    | Description                                                                        |
+============+=======+========+============+====================================================================================+
| CLR        |   6:6 |   WO   |    0x0     | Clear the local copy of Tx channel configuration CSRs inside uDMA core             |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| PENDING    |   5:5 |   RO   |    0x0     | - 0x1: The uDMA core Tx channel is enabled and is either receiving data,           |
|            |       |        |            |   waiting for access from the uDMA core arbiter, or stalled due to a full Tx FIFO  |
|            |       |        |            | - 0x0 : Tx channel of the uDMA core does not have data to read from L2 memory      |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| EN         |   4:4 |   RW   |    0x0     | Enable the transmit channel of uDMA core to perform Tx operation                   |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| DATASIZE   |   2:1 |   RW   |    0x02    | Controls uDMA address increment                                                    |
|            |       |        |            |                                                                                    |
|            |       |        |            | - 0x00: increment address by 1 (data is 8 bits)                                    |
|            |       |        |            | - 0x01: increment address by 2 (data is 16 bits)                                   |
|            |       |        |            | - 0x02: increment address by 4 (data is 32 bits)                                   |
|            |       |        |            | - 0x03: increment address by 0                                                     |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW   |            | - 0x0: stop after last transfer for channel                                        |
|            |       |        |    0x0     | - 0x1: after last transfer for channel,reload buffer size                          |
|            |       |        |            |   and start address and restart channel                                            |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+

CMD_SADDR
~~~~~~~~~

- Offset: 0x20
- Type:   volatile

+-------+-------+--------+------------+-------------------------------------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                                             |
+=======+=======+========+============+=========================================================================================================================+
| SADDR |  18:0 |   RW   |    0x0     | Address of the command memory buffer. This is location in the L2 memory from where QSPI will read the data to transmit. |
|       |       |        |            | Read & write to this CSR access different information.                                                                  |
|       |       |        |            |                                                                                                                         |
|       |       |        |            | **On Write**: Address of command memory buffer for next transaction. It does not impact current ongoing transaction.    |
|       |       |        |            |                                                                                                                         |
|       |       |        |            | **On Read**: Address of command memory buffer for the current ongoing transaction.This is the local copy of information |
|       |       |        |            | maintained inside the uDMA core.                                                                                        |
+-------+-------+--------+------------+-------------------------------------------------------------------------------------------------------------------------+

CMD_SIZE
~~~~~~~~

- Offset: 0x24
- Type:   volatile

+-------+-------+--------+------------+-------------------------------------------------------------------------------------------------------------------+
| Field |  Bits | Access | Default    | Description                                                                                                       |
+=======+=======+========+============+===================================================================================================================+
| SIZE  |  19:0 |   RW   |    0x0     | Size of command memory buffer(amount of data to be read by QSPI from L2 memory). Read & write                     |
|       |       |        |            | to this CSR access different information.                                                                         |
|       |       |        |            |                                                                                                                   |
|       |       |        |            | **On Write**: Size of command memory buffer for next transaction. It does not impact current ongoing transaction. |
|       |       |        |            |                                                                                                                   |
|       |       |        |            | **On Read**: Bytes left for current ongoing transaction, i.e. bytes left to read from L2 memory. This             |
|       |       |        |            | is the local copy of information maintained inside the uDMA core.                                                 |
+-------+-------+--------+------------+-------------------------------------------------------------------------------------------------------------------+


CMD_CFG 
~~~~~~~

- Offset: 0x28
- Type:   volatile

+---------------+-------+------+------------+-----------------------------------------------------------------------------------+
| Field         |  Bits | Type | Default    | Description                                                                       |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| Field      |  Bits | Access | Default    | Description                                                                        |
+============+=======+========+============+====================================================================================+
| CLR        |   6:6 |   WO   |    0x0     | Clear the local copy of Tx channel configuration CSRs inside uDMA core             |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| PENDING    |   5:5 |   RO   |    0x0     | - 0x1: The uDMA core Tx channel is enabled and is either receiving data,           |
|            |       |        |            |   waiting for access from the uDMA core arbiter, or stalled due to a full Tx FIFO  |
|            |       |        |            | - 0x0 : Tx channel of the uDMA core does not have data to read from L2 memory      |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| EN         |   4:4 |   RW   |    0x0     | Enable the transmit channel of uDMA core to perform Tx operation                   |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| DATASIZE   |   2:1 |   RW   |    0x02    | Controls uDMA address increment                                                    |
|            |       |        |            |                                                                                    |
|            |       |        |            | - 0x00: increment address by 1 (data is 8 bits)                                    |
|            |       |        |            | - 0x01: increment address by 2 (data is 16 bits)                                   |
|            |       |        |            | - 0x02: increment address by 4 (data is 32 bits)                                   |
|            |       |        |            | - 0x03: increment address by 0                                                     |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW   |            | - 0x0: stop after last transfer for channel                                        |
|            |       |        |    0x0     | - 0x1: after last transfer for channel,reload buffer size                          |
|            |       |        |            |   and start address and restart channel                                            |
+------------+-------+--------+------------+------------------------------------------------------------------------------------+

STATUS
~~~~~~

- Offset: 0x30
- Type:   volatile

+---------------+-------+------+------------+-------------------------------------------------------------+
| Field         |  Bits | Type | Default    | Description                                                 |
+===============+=======+======+============+=============================================================+
| BUSY          |   1:0 |   RO |            | 0x00: STAT_NONE                                             |
|               |       |      |            | 0x01: STAT_CHECK (matched)                                  |
|               |       |      |            | 0x02: STAT_EOL (end of loop)                                |
+---------------+-------+------+--------------------------------------------------------------------------+

Firmware Guidelines
-------------------

Clock Enable, Reset & Configure uDMA QSPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Configure uDMA Core's PERIPH_CLK_ENABLE to enable uDMA QSPI's peripheral clock. A peripheral clock is used to calculate the baud rate in uDMA QSPI.
- Configure uDMA Core's PERIPH_RESET CSR to issue a reset signal to uDMA QSPI. It acts as a soft reset for uDMA QSPI.
- Configure QSPI Operation using  SETUP CSR. Refer to the CSR details for detailed information.
- The DIV bit of QSPI SETUP should be updated with a non-zero value as it is used for buadrate calculation. The baud rate is determined by the period of the ref_clk divided by the value of DIV.

Tx Operation
^^^^^^^^^^^^

Rx Operation
^^^^^^^^^^^^

Pin Diagram
-----------
The Figure below is a high-level block diagram of the uDMA:-

.. figure:: uDMA_QSPI_Pin_Diagram.png
   :name: uDMA_QSPI_Pin_Diagram
   :align: center
   :alt:

   uDMA QSPI Pin Diagram

Below is categorization of these pins:

Tx channel interface
^^^^^^^^^^^^^^^^^^^^
The following pins constitute the Tx channel interface of uDMA QSPI. uDMA QSPI uses these pins to read data from interleaved (L2) memory:

- data_tx_req_o
- data_tx_gnt_i
- data_tx_datasize_o
- data_tx_i
- data_tx_valid_i
- data_tx_ready_o

data_tx_datasize_o pin is hardcoded to value 0x0. These pins reflect the configuration values for the next transaction.

Rx channel interface
^^^^^^^^^^^^^^^^^^^^
The following pins constitute the Rx channel interface of uDMA QSPI. uDMA QSPI uses these pins to write data to interleaved (L2) memory:

- data_rx_datasize_o
- data_rx_o
- data_rx_valid_o
- data_rx_ready_i

 data_rx_datasize_o pin is hardcoded to value 0x0. These pins reflect the configuration values for the next transaction.

Clock interface
^^^^^^^^^^^^^^^
- sys_clk_i
- periph_clk_i

uDMA CORE derives these clock pins. periph_clk_i is used to calculate baud rate. sys_clk_i is used to synchronize QSPI with uDAM Core.

Reset interface
^^^^^^^^^^^^^^^
- rstn_i

uDMA core issues reset signal to QSPI using reset pin.

uDMA QSPI interface to get/send data from/to external device
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- QSPI_rx_i
- QSPI_tx_o

uDMA QSPI receieves data from external QSPI device on QSPI_rx_i and transmits via QSPI_tx_o.

uDMA QSPI interface to generate interrupt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- rx_char_event_o
- err_event_o

Overflow and Parity error are generated over err_event_o interface. Receive data event will be generated over rx_char_event_o interface.

uDMA QSPI inerface to read-write CSRs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The following interfaces are used to read and write to QSPI CSRs. These interfaces are managed by uDMA Core:

- cfg_data_i
- cfg_addr_i
- cfg_valid_i
- cfg_rwn_i
- cfg_ready_o
- cfg_data_o

uDMA QSPI Rx channel configuration interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- uDMA QSPI uses the following pins to share the value of config CSRs i.e. RX_SADDR, RX_SIZE, and RX_CFG with the uDMA core:-

   - cfg_rx_startaddr_o
   - cfg_rx_size_o
   - cfg_rx_datasize_o
   - cfg_rx_continuous_o
   - cfg_rx_en_o
   - cfg_rx_clr_o

   cfg_rx_datasize_o pin is stubbed.

- QSPI shares the values present over the below pins as read values of the config CSRs i.e. RX_SADDR, RX_SIZE, and RX_CFG:

   - cfg_rx_en_i
   - cfg_rx_pending_i
   - cfg_rx_curr_addr_i
   - cfg_rx_bytes_left_i

   These values are updated by the uDMA core and reflects the configuration values for the current ongoing transactions.

uDMA QSPI Tx channel configuration interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- uDMA QSPI uses the following pins to share the value of config CSRs i.e. TX_SADDR, TX_SIZE, and TX_CFG with the uDMA core:-

   - cfg_tx_startaddr_o
   - cfg_tx_size_o
   - cfg_tx_datasize_o
   - cfg_tx_continuous_o
   - cfg_tx_en_o
   - cfg_tx_clr_o

  cfg_tx_datasize_o pin is stubbed.

- QSPI shares the values present over the below pins as read values of the config CSRs i.e. TX_SADDR, TX_SIZE, and TX_CFG:

   - cfg_tx_en_i
   - cfg_tx_pending_i
   - cfg_tx_curr_addr_i
   - cfg_tx_bytes_left_i

   These values are updated by the uDMA core and reflects the configuration values for the current ongoing transactions.