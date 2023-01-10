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

.. _udram_i2cm:

UDMA I2C Master
===============
I2C (Inter-Integrated Circuit), is a multi-master, multi-slave, single-ended, serial computer bus invented by Philips Semiconductor (now NXP Semiconductors).
It is typically used for attaching lower-speed peripheral ICs to processors and microcontrollers.
I2C uses only two bidirectional open-drain lines, Serial Data Line (SDA) and Serial Clock Line (SCL), pulled up with resistors.
The I2C reference design has a 7-bit or a 10-bit (depending on the device used) address space.
Common I2C bus speeds are the 100 kbit/s standard mode and the 10 kbit/s low-speed mode, but arbitrarily low clock frequencies are also allowed.

Theory of Operation
-------------------

I2C defines basic types of messages, each of which begins with a START and ends with a STOP:

- Single message where a master writes data to a slave;
- Single message where a master reads data from a slave;
- Combined messages, where a master issues at least two reads and/or writes to one or more slaves.


All I2C transfers could be splitted in a reduced number of bus accesses types, those are:
- Start Bit
- Send Byte and get acknowledge
- Get Byte and send acknowledge
- Get Byte and send not acknowledge
- Stop Bit

With different combinations of the above, we can create any type of I2C transfer.
Under those conditions we decided to change the interface of the I2C IP and have it fetch command from L2 memory instead of only data.
In this way we can recreate complex I2C transfer fully autonomously and without any intervention of the CPU.

Programming Model
-----------------
As with most peripherals in the uDMA Subsystem, software configuration can be conceptualized into three functions:

1. Configure the I/O parameters.
2. Configure the uDMA data control parameters.
3. Manage the data transfer operation.

uDMA I2C Master I/O Parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The actions of the uDMA I2C master are controlled using a sequence of commands that are written to the transmit buffer.
Using the uDMA I2C master involves writting the appropriate sequence of commands to the Tx buffer, and using the uDMA to send the buffer to the I2C contoller.

A list of the available commands and their encoding is shown in the Table below.

+--------------+-----------------+-------------------------------------------------------------------------+
| Encoding     | Command Name    | Command Description                                                     |
+==============+=================+=========================================================================+
| 0x00         | I2C_CMD_START   | Signals a start bit on the I2C bus                                      |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0x10         | I2C_WAIT_EV     | TBC: Inject wait states of data[1:0] in command buffer is non-zero      |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0x20         | I2C_CMD_STOP    | Signals a stop bit on the I2C bus                                       |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0x40         | I2C_CMD_RD_ACK  | Receives 1 byte and sends 1 acknowledge                                 |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0x60         | I2C_CMD_RD_NACK | Receives 1 byte and sends 1 negative acknowledge                        |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0x80         | I2C_CMD_WR      | Sends 1 byte and wait for acknowledge                                   |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0xA0         | I2C_CMD_WAIT    | The following byte indicates number of I2C cycles to wait               |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0xC0         | I2C_CMD_RPT     | The following byte indicates number of times to repeat next instruction |
+--------------+-----------------+-------------------------------------------------------------------------+
| 0xE0         | I2C_CMD_CFG     | Next two bytes are the MSB and LSB of the clock divider                 |
+--------------+-----------------+-------------------------------------------------------------------------+


uDMA I2C Master Data Control
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
By way of example, what follows is a relatively complex I2C transfer that generates a write to an external device connected to the I2C bus.
The command sequence starts by generating a start bit on the bus followed by a byte write and waiting for the slave acknoledge.
The first byte, following the I2C standard sends the 7-bit address with the last bit coding the access type(0 for write 1 for read) so in for example if the first byte sent is 8'b1010_0100 (0xA4), the operation is a write and the address is 7'b101_0010 (0x52).
The following instructions tell the I2C IP to repeat the next instructions 16 times.
The instruction to be repeated is the write and the data for each write instruction is queued.
Here we do write 16 bytes 0x00, 0x01…0x0F.
The I2C_CMD_STOP generates the stop bits and ends the transfer.
I2C_CMD_WAIT waits some I2C cycles (in this case 16) and the following I2C_CMD_START restart a new I2C transfer.
The next command is a read from the same addres (0xA5 is a read of addr 0x52).
The next command says to read 15 bytes and sends acknowledge at each byte and then read the last byte followed by a not acknoledge to inform the slave that we are done with the transfer.
A stop bit then finalizes the transfer.
All the commands are read through the Tx port while each read pushes data to the Rx channel.

+-----------------+--------------------------+-------------------------------------+
| Command Issued  | Command Data             | Comment                             |
+=================+==========================+=====================================+
| I2C_CMD_START   |                          | Start the transfer                  |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_WR      | 0xA4                     | First byte: write to addr=0x52      |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_RPT     | 0x10                     | Repeat 16 times                     |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_WR      | 0x00, 0x01, 0x02, 0x3    |                                     |
+-----------------+--------------------------+-------------------------------------+
|                 | 0x04, 0x05, 0x06, 0x7    |                                     |
+-----------------+--------------------------+-------------------------------------+
|                 | 0x08, 0x09, 0x0A, 0xB    |                                     |
+-----------------+--------------------------+-------------------------------------+
|                 | 0x0C, 0x0D, 0x0E, 0xF    |                                     |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_STOP    |                          | Generate stop bits and end transfer |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_WAIT    | 0x10                     | Wait 16 I2C cycles                  |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_START   |                          | Start the next transfer             |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_WR      | 0xA5                     | First byte: read from addr=0x52     |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_RPT     | 0x0F                     | Repeat 15 times                     |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_RD_ACK  |                          |                                     |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_RD_NACK |                          |                                     |
+-----------------+--------------------------+-------------------------------------+
| I2C_CMD_STOP    |                          | We're done!                         |
+-----------------+--------------------------+-------------------------------------+


Data Transfer Operation
~~~~~~~~~~~~~~~~~~~~~~~


UDMA I2CM CSRs
--------------

RX_SADDR offset = 0x00
~~~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| SADDR      |  11:0 |   RW |            | Address of receive buffer on write; current address on read |
+------------+-------+------+------------+-------------------------------------------------------------+

RX_SIZE offset = 0x04
~~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| SIZE       |  15:0 |   RW |            | Size of receive buffer on write; bytes left on read         |
+------------+-------+------+------------+-------------------------------------------------------------+

RX_CFG offset = 0x08
~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| CLR        |   6:6 |   WO |            | Clear the receive channel                                   |
+------------+-------+------+------------+-------------------------------------------------------------+
| PENDING    |   5:5 |   RO |            | Receive transaction is pending                              |
+------------+-------+------+------------+-------------------------------------------------------------+
| EN         |   4:4 |   RW |            | Enable the receive channel                                  |
+------------+-------+------+------------+-------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW |            | 0x0: stop after last transfer for channel                   |
+------------+-------+------+------------+-------------------------------------------------------------+
|            |       |      |            | 0x1: after last transfer for channel,                       |
+------------+-------+------+------------+-------------------------------------------------------------+
|            |       |      |            | reload buffer size and start address and restart channel    |
+------------+-------+------+------------+-------------------------------------------------------------+

TX_SADDR offset = 0x10
~~~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| SADDR      |  11:0 |   RW |            | Address of Tx buffer on write; current address on read      |
+------------+-------+------+------------+-------------------------------------------------------------+

TX_SIZE offset = 0x14
~~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| SIZE       |  15:0 |   RW |            | Size of receive buffer on write; bytes left on read         |
+------------+-------+------+------------+-------------------------------------------------------------+

TX_CFG offset = 0x18
~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| CLR        |   6:6 |   WO |            | Clear the transmit channel                                  |
+------------+-------+------+------------+-------------------------------------------------------------+
| PENDING    |   5:5 |   RO |            | Transmit transaction is pending                             |
+------------+-------+------+------------+-------------------------------------------------------------+
| EN         |   4:4 |   RW |            | Enable the transmit channel                                 |
+------------+-------+------+------------+-------------------------------------------------------------+
| CONTINUOUS |   0:0 |   RW |            | 0x0: stop after last transfer for channel                   |
+------------+-------+------+------------+-------------------------------------------------------------+
|            |       |      |            | 0x1: after last transfer for channel,                       |
+------------+-------+------+------------+-------------------------------------------------------------+
|            |       |      |            | reload buffer size and start address and restart channel    |
+------------+-------+------+------------+-------------------------------------------------------------+

STATUS offset = 0x20
~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| AL         |   1:1 |   RO |            | Always returns 0                                            |
+------------+-------+------+------------+-------------------------------------------------------------+
| BUSY       |   0:0 |   RO |            | Always returns 0                                            |
+------------+-------+------+------------+-------------------------------------------------------------+

SETUP offset = 0x24
~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| RESET      |   0:0 |   RW |            | Reset I2C controller                                        |
+------------+-------+------+------------+-------------------------------------------------------------+

