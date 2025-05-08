..
   Copyright (c) 2023 OpenHW Group

   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.. _tcdm_interconnect:

TCDM Interconnect
=================

The Tightly Coupled Data Memory (TCDM) Interconnect is a high-performance, low-latency memory bus designed for efficient data transfers. 

Features
~~~~~~~~
- The processor utilizes the TCDM Interconnect for both instruction fetching and data load/store operations.
- The uDMA Subsystem uses TCDM interconnect to access interleaved(L2) memory.
- Acts as a master to the APB peripheral interconnect.
- 4 TCDM interfaces for eFPGA provide high speed access to the CORE-V-MCU memory
- Provides a JTAG debug interface.
- Support below network topologies
   - Full Crossbar
   - Clos network
   - Butterfly


For more details about TCDM interconnect refer `here <https://github.com/openhwgroup/core-v-mcu/blob/master/rtl/tcdm_interconnect/README.md>`_.

Block Diagram
~~~~~~~~~~~~~~

.. figure:: ../images/TCDM_block_diagram.png
   :name: TCDM_Interconnect_block_diagram
   :align: center
   :alt: 

   TCDM Interconnect block diagram

It contains 9 master ports and 9 slave ports.
   
**Masters:** 

- uDMA Subsystem (2 ports)
- eFPGA (4 ports)
- Core Complex (2 ports)
- Debug Module (1 port)

**Slaves:** 

- Boot ROM
- Non-interleaved memory (2 private memory banks)
- Interleaved memory (4 banks)
- APB peripheral interconnect
- eFPGA APB Target

Master-Slave Communication via TCDM Demux
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The uDMA SS, eFPGA, and Core Complex masters connect to the TCDM Demux, which is responsible for routing requests to the correct slave. The slaves fall into three categories based on address regions:

- AXI Region : For APB peripherals (address range: 0x1A100000 to 0x1A300000)
- Contiguous Slaves : Includes L2 private memory banks (core memory), Boot ROM, and eFPGA APBT1
- Interleaved Slaves : Mapped to address range 0x1C010000 to 0x1C090000

The TCDM Demux integrates an address decoder that inspects each incoming request address and matches it against the configured address ranges for all slave regions. When the match is found, the module outputs a slave_id, which is used
as a select line to route the request to the appropriate slave region — AXI, contiguous, or interleaved.

Interaction with Contiguous Crossbar
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The contiguous crossbar consists of two primary components:

1. Address Decoders - One per master (Total of 9)
2. Single Xbar Module 

Each address decoder receives the ADDR from TCDM demux and checks it against the address ranges of contiguous slaves address. if a match is found, port_sel is generated and sent to the Xbar module's ADDR input.
Meanwhile the actual request (ADDR, WEN, WDATA and BE) is aggregated into single bundle and forwarded to Xbar's WDATA input.

The Xbar is a multi-master and multi-slave module that includes:

1. A dedicated local address decoder and response multiplexer for each master to interpret port_sel
2. A dedicated RR arbiter for each slave to handle requests from multiple masters

The address decoder and response mux route incoming master request to the appropriate slave-specific arbiter. The arbiter grants access to one master per cycle using a round-robin (RR) policy.
Once access is granted, the aggregated request is disaggregated into its original signals (ADDR, WEN, WDATA, BE) and forwarded to the slave.

When a slave detects the REQ signal, it immediately asserts the GNT signal in the same clock cycle to acknowledge the request. For read operations, the r_data and valid signals are updated in the next clock cycle.

Interaction with Interleaved Crossbar
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The interleaved crossbar follows a different mechanism for selecting the target slave. Unlike the contiguous crossbar, it does not use address decoders based on full address ranges.
Instead, it uses specific address bits (often referred to as bank bits) to determine the destination memory bank. These bits are extracted from the request address and forwarded to the Xbar's ADDR input.
Each master aggregates its request (ADDR, WEN, WDATA, and BE) into a bundled format and sends it to the crossbar's DATA input.

Internally, the interleaved crossbar also contains a Xbar module that includes:

1. A dedicated local address decoder and response multiplexer for each master to interpret port_sel
2. A dedicated RR arbiter for each slave to handle requests from multiple masters

As in contiguous cross bar, the address decoder and response mux route incoming master request to the appropriate slave-specific arbiter. The arbitration occurs every clock cycle, ensuring fair access.
Once master is granted access, the aggregated request is disaggregated into its original signals (ADDR, WEN, WDATA, BE) and forwarded to the slave.

When a slave detects the REQ signal, it immediately asserts the GNT signal in the same clock cycle to acknowledge the request. For read operations, the r_data and valid signals are updated in the next clock cycle.

System Architecture
~~~~~~~~~~~~~~~~~~~
.. figure:: ../images/TCDM_Interconnect_block_diagram.png
   :name: TCDM_Interconnect_connection_diagram
   :align: center
   :alt: 

   TCDM Interconnect connection diagram

Pin Diagram
~~~~~~~~~~~~~~

.. figure:: ../images/TCDM_Interconnect_pin_diagram.png
   :name: TCDM_Interconnect_pin_diagram
   :align: center
   :alt: 

   TCDM Interconnect pin diagram

Below is the categorization of these pins:

Clock Interface
^^^^^^^^^^^^^^^

- ``clk_i`` : system clock

Reset Interface
^^^^^^^^^^^^^^^

- ``rst_ni`` : Active low reset signal

Master Interface
^^^^^^^^^^^^^^^^

- ``req_i`` : Request signal from master ports.
- ``add_i`` : Address of the tcdm.
- ``wen_i`` : Write enable signal; 1 = write, 0 = read.
- ``wdata_i`` : Data to be written to memory.
- ``be_i`` : Byte enable signals.
- ``gnt_o`` : Grant signal indicating the request has been accepted.
- ``vld_o`` : Response valid signal, also used for write acknowledgments.
- ``rdata_o`` : Data read from memory for load operations.

Slave Interface
^^^^^^^^^^^^^^^

- ``req_o`` : Request signal sent to slave memory banks.
- ``gnt_i`` : Grant signal from memory banks.
- ``add_o`` : Address within each memory bank.
- ``wen_o`` : Write enable signal to memory banks.
- ``wdata_o`` : Data to be written to memory.
- ``be_o`` : Byte enable signals for each memory bank.
- ``rdata_i`` : Data returned from the memory banks for read operations.