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

.. _udram_uart:

UDMA UART
=========

The uDMA Universal Asynchronous Recevier Transmiter supports most standard options for UART Tx/Rx.

It has a configurable number of data bits from 5 to 8, a configurable number of stop bits(1 or 2) and can add a parity bit at the end of data bits in case of a transmission or check the parity bit in case of a reception.
As the name implies, it is a peripheral function of the uDMA subsystem.
As such its CSRs are not directly accessible via the APB bus.
Rather, the control plane interface to the uDMA UART is managed by the uDMA core within the uDMA subsystem.
This is transparent to the programer as all uDMA UART CSRs appear within the uDMA Subsystem's memory region,

As is the case for all uDMA subsystem peripherals, I/O operations are controlled by the uDMA core.
This is not transparent to the programmer.

The uDMA UART has one configuration register to configure both the transmit and receive blocks.
Tx and Rx channels are fully decoupled and support full duplex communication.
Baud rate is determined by configuring a counter which is driven by ref_clk.

Programming Model
-----------------
As with most peripherals in the uDMA Subsystem, software configuration can be conceptualized into three functions:

1. Configure the I/O parameters of the peripheral (e.g. baud rate).
2. Configure the uDMA data control parameters.
3. Manage the data transfer operation.

uDMA UART I/O Parameters
~~~~~~~~~~~~~~~~~~~~~~~~
Bit-fields of **UART_SETUP** CSR controls the I/O parameters of the UART.
For the most part, the field names are self-explanitory with the exception of the **DIV** field which sets the baud rate.
The baud rate is determined by the period of the ref_clk divided by the value of **DIV**.

uDMA UART Data Control
~~~~~~~~~~~~~~~~~~~~~~

Data Transfer Operation
~~~~~~~~~~~~~~~~~~~~~~~

UDMA_UART CSRs
--------------

RX_SADDR offset = 0x00
~~~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| SADDR      |  11:0 | RW   |            | Address of receive buffer on write; current address on read |
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
|                                        | 0x1: after last transfer for channel,                       |
+------------+-------+------+------------+-------------------------------------------------------------+
|                                        | reload buffer size and start address and restart channel    |
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
|                                        | 0x1: after last transfer for channel,                       |
+------------+-------+------+------------+-------------------------------------------------------------+
|                                        | reload buffer size and start address and restart channel    |
+------------+-------+------+------------+-------------------------------------------------------------+

STATUS offset = 0x20
~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| RX_BUSY    |   1:1 |   RO |            | 0x1: receiver is busy                                       |
+------------+-------+------+------------+-------------------------------------------------------------+
| TX_BUSY    |   0:0 |   RO |            | 0x1: transmitter is busy                                    |
+------------+-------+------+------------+-------------------------------------------------------------+

UART_SETUP offset = 0x24
~~~~~~~~~~~~~~~~~~~~~~~~

+---------------+-------+------+------------+-------------------------------------------------------------+
| Field         |  Bits | Type | Default    | Description                                                 |
+===============+=======+======+============+=============================================================+
| DIV           | 31:16 |   RW |            |                                                             |
+---------------+-------+------+------------+-------------------------------------------------------------+
| EN_RX         |   9:9 |   RW |            | Enable the reciever                                         |
+---------------+-------+------+------------+-------------------------------------------------------------+
| EN_TX         |   8:8 |   RW |            | Enable the transmitter                                      |
+---------------+-------+------+------------+-------------------------------------------------------------+
| RX_CLEAN_FIFO |   5:5 |   RW |            | Empty the receive FIFO                                      |
+---------------+-------+------+------------+-------------------------------------------------------------+
| RX_POLLING_EN |   4:4 |   RW |            | Enable polling mode for receiver                            |
+---------------+-------+------+------------+-------------------------------------------------------------+
| STOP_BITS     |   3:3 |   RW |            | 0x0: 1 stop bit                                             |
+---------------+-------+------+------------+-------------------------------------------------------------+
|                                           | 0x1: 2 stop bits                                            |
+---------------+-------+------+------------+-------------------------------------------------------------+
| BITS          |   2:1 |   RW |            | 0x0: 5 bit transfers                                        |
+---------------+-------+------+------------+-------------------------------------------------------------+
|                                           | 0x1: 6 bit transfers                                        |
+---------------+-------+------+------------+-------------------------------------------------------------+
|                                           | 0x2: 7 bit transfers                                        |
+---------------+-------+------+------------+-------------------------------------------------------------+
|                                           | 0x3: 8 bit transfers                                        |
+---------------+-------+------+------------+-------------------------------------------------------------+
| PARITY_EN     |   0:0 |   RW |            | Enable parity                                               |
+---------------+-------+------+------------+-------------------------------------------------------------+

ERROR offset = 0x28
~~~~~~~~~~~~~~~~~~~

+--------------+-------+------+------------+-------------------------------------------------------------+
| Field        |  Bits | Type | Default    | Description                                                 |
+==============+=======+======+============+=============================================================+
| PARITY_ERR   |   1:1 |   RC |            | 0x1 indicates parity error; read clears the bit             |
+--------------+-------+------+------------+-------------------------------------------------------------+
| OVERFLOW_ERR |   0:0 |   RC |            | 0x1 indicates overflow error; read clears the bit           |
+--------------+-------+------+------------+-------------------------------------------------------------+

IRQ_EN offset = 0x2C
~~~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| ERR_IRQ_EN |   1:1 |   RW |            | Enable the error interrupt                                  |
+------------+-------+------+------------+-------------------------------------------------------------+
| RX_IRQ_EN  |   0:0 |   RW |            | Enable the receiver interrupt                               |
+------------+-------+------+------------+-------------------------------------------------------------+

VALID offset = 0x30
~~~~~~~~~~~~~~~~~~~

+---------------+-------+------+------------+-------------------------------------------------------------+
| Field         |  Bits | Type | Default    | Description                                                 |
+===============+=======+======+============+=============================================================+
| RX_DATA_VALID |   0:0 |   RO |            | Cleared when RX_DATA is read                                |
+---------------+-------+------+------------+-------------------------------------------------------------+

DATA offset = 0x34
~~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| RX_DATA    |   7:0 |   RO |            | Receive data; reading clears RX_DATA_VALID                  |
+------------+-------+------+------------+-------------------------------------------------------------+

