..
   Copyright (c) 2023 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. _udram_uart:

UDMA UART
=========

The uDMA Universal Asynchronous Recevier Transmiter supports most standard options for UART Tx/Rx.
It has a configurable number of data bits from 5 to 8, a configurable number of stop bits(1 or 2) and can add a parity bit at the end of data bits in case of a transmission or check the parity bit in case of a reception.
As the name implies, it is a peripheral function of the uDMA subsystem.
As such its CSRs are not directly accessible via the APB bus.
Rather, the control plane interface to the uDMA UART is managed by the uDMA core within the uDMA subsystem.
This is transparent to the programer as all uDMA UART CSRs appear within the uDMA Subsystem's memory region,
see the *Memory Map* and *UDMA CTRL* chapters.

The uDMA UART has one configuration register to configure both the transmit and receive blocks.
Tx and Rx channels are fully decoupled and support full duplex communication.
Baud rate is determined by configuring a counter which is driven by ref_clk.

Theory of Operation
-------------------

Programming Model
-----------------
As with most peripherals in the uDMA Subsystem, software configuration can be conceptualized into three functions:

1. Configure the I/O parameters.
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

