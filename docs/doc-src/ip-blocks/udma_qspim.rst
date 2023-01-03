..
   Copyright (c) 2023 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

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
The lack of a formal standard is reflected in a wide variety of protocol options:

- Different word sizes are common.
- Every device defines its own protocol, including whether it supports commands at all.
- Some devices are transmit-only; others are receive-only.
- Chip selects are sometimes active-high rather than active-low.
- Some protocols send the least significant bit first.

CORE-V-MCU QSPI Implementation
------------------------------

The CORE-V-MCU QSPI Master supports an implementation of the SPI and the QSPI (Quad SPI) mode enabling higher bandwidths required by modern embedded devices.
Due to the lack of a formal standard it is impossible to make a claim of compliance to the protocol.
However, CORE-V-MCU’s QSPI interface is known to work with the Micron N25Q256A Serial NOR Flash Memory and *should* work with a large set of QSPI and SPI devices.
The QSPI master described here has some limitations to the supported variants of the SPI protocol.
The major limitation is the lack of support for the full duplex transfers.

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
