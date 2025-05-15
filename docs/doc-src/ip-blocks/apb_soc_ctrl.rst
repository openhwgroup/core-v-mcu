
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
.. _apb_soc_controller:

APB SoC controller
==================

This APB peripheral primarily controls I/O configuration and serves as the central configuration hub in the CORE-V-MCU for pad multiplexing, boot control, watchdog monitoring, and eFPGA interfacing.

Features
--------
  - Control interface for configurable pad multiplexer and IO configuration
  - Watchdog timer with programmable timeout and reset capability
  - JTAG CSR access for debug and configuration
  - Boot address and fetch enable control for the Fabric Controller (FC)
  - eFPGA control and configuration interface
  - Ready timeout monitoring for system level recovery
  - System information and status CSRs
  - Soft reset capability for all APB Client Peripherals
  - Build date and time information

Block Architecture
------------------

The figure below is a high-level block diagram of the APB SoC Controller module:-

.. figure:: apb_soc_controller_block_diagram.png
   :name: APB_SOC_Controller_Block_Diagram
   :align: center
   :alt:

   APB SoC Controller Block Diagram

The APB SoC Controller IP consists of the following key components:

Pad Configuration
~~~~~~~~~~~~~~~~~
The controller manages pad multiplexing and configuration for all system IOs. It provides the multiplexing information to the Pad control module, which directly manages the IO pads.
Each pad can be individually configured for:
  - Pad multiplexing (selecting the pad function i.e. connecting the I/O to different signals in CORE-V-MCU)
  - Pad electrical configuration (drive strength, pull-up/down, etc.)

These configurations can be accessed through two methods:
  - Directly through the IO_CTRL CSRs (0x400 - 0x4C0)
  - Through the WCFGFUN and RCFGFUN CSRs (0x60 and 0x64).

Note: Pad multiplexing details can be found in the IO Assignment document.(https://docs.openhwgroup.org/projects/core-v-mcu/doc-src/io_assignment_tables.html)

Watchdog Timer
~~~~~~~~~~~~~~
A programmable watchdog timer(WDT) runs on the reference clock(ref_clk_i) and resets the system when expired. The watchdog timer is a safety feature designed to detect and recover from system malfunctions.
Features include:
  - Configurable timeout period through the WD_COUNT CSR
  - Hardware-based countdown mechanism operating on the reference clock
  - Enable/disable control via the WD_CONTROL CSR
  - Refresh mechanism using a magic value (0x6699) written to WD_CONTROL

Initialization and Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - On system power-up, the watchdog timer is disabled by default.
  - Software must configure the timeout value by writing to the WD_COUNT CSR.
      - Note: WD_COUNT is only writable when the watchdog is disabled.
  - The watchdog is enabled by setting the ENABLE_STATUS (bit 31) in the WD_CONTROL CSR.
  - After enabling, the watchdog timer begins counting down on every positive edge of the reference clock(ref_clk_i).

Servicing the Watchdog
^^^^^^^^^^^^^^^^^^^^^^
  - To prevent expiration, software must periodically write the magic value 0x6699 to the WD_CONTROL CSR.
     - This operation is referred to as "servicing" the watchdog.
  - Servicing resets the counter to the value configured in WD_COUNT.

Expiration and Reset Behavior
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - Once enabled, the watchdog cannot be disabled except by a hardware reset i.e.:
      - The whole SoC Controller is resetted by deasserting HRESETn pin.
      - Only the watchdog timer is reset by deasserting the rstpin_ni pin.
  - Hard reset behaviour
      - When rstpin_ni is deasserted, then the watchdog timer is set to it's default value of 0x8000.
      - The reset reason is recorded in the RESET_REASON CSR with the value 1, indicating a hard reset.
      - After this, the watchdog timer will only start counting down from the configured value in WD_COUNT CSR upon servicing.
  - If the watchdog counter reaches zero, the following occurs:
      - The wd_expired_o signal is asserted for one cycle of the reference clock.
      - A system-wide reset is triggered.
      - The reset reason is recorded in the RESET_REASON CSR with the value 2, indicating a watchdog reset.
  - The reset reason is cleared when the APB bus is in waiting state, i.e. after a read or write is performed.

Debugging
^^^^^^^^^
  - The WDT can be paused during debug sessions via the stoptimer_i input signal, improving debuggability by preventing timeouts during breakpoints.
  - The WDT will be paused when the stoptimer_i signal is asserted and will resume counting when deasserted.

eFPGA Interface
~~~~~~~~~~~~~~~
The SoC Controller provides comprehensive management of the embedded FPGA (eFPGA) interface, enabling configuration, control, and monitoring of the eFPGA subsystem.
Key Features:
  - Reset control for the eFPGA quadrants (left bottom, right bottom, right top, left top)
  - Interface enabling/disabling for various eFPGA connections (TCDM, APB, events)
  - Status monitoring and CSR access for eFPGA operations
  - Version information access for the eFPGA subsystem

Initialization and Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - On system reset, all eFPGA interfaces are disabled by default and has to be explicitly enabled.
  - Interfaces are enabled via the ENABLE_IN_OUT_EFPGA CSR and are communicated through various enable signals to the eFPGA.
  - Reset control is asserted and deasserted through the RESET_TYPE1_EFPGA CSR, which allows resetting of individual eFPGA quadrants and is communicated through the 4 bit reset_type1_efpga_o signal.
  - Additional features are controlled through the EFPGA_CONTROL CSR and the same is communicated through 32 bit control_in signal.

Monitoring
^^^^^^^^^^
  - The EFPGA_STATUS CSR provides visibility into the operational state of the eFPGA. The 32 bit status signals(status_out) from eFPGA are made available on this CSR, to make them accessible through APB interface.
  - The EFPGA_VERSION CSR allows software to determine the eFPGA IP version. The 8 bit version signals(version) from eFPGA are made available on this CSR, to make them accessible through APB interface.

Power Management
^^^^^^^^^^^^^^^^
  - Clock gating can be selectively applied to eFPGA-related FIFOs and is provided through the clk_gating_dc_fifo_o signal to eFPGA.
      - Note: As per current design clk_gating_dc_fifo_o is always set to 1.

Ready Timeout Mechanism
~~~~~~~~~~~~~~~~~~~~~~~
The Ready Timeout (RTO) mechanism is a system protection feature that monitors bus transactions and detects when a peripheral does not respond within an expected time frame.
The SoC Controller generates a timeout signal (rto_o) when a peripheral fails to respond within the specified time limit.
It enhances system robustness by preventing indefinite stalls caused by unresponsive peripherals.

The RTO mechanism is segregated into two IPs, the SoC Controller and the Peripheral Interconnect. 
  - The Peripheral Interconnect IP is responsible generating the ready signal(start_rto_i) and informing which peripheral casued timeout through peripheral_rto_i signal.
  - The SoC Controller houses the timeout counter and the CSRs for configuring the timeout period and monitoring the status of peripherals.

Timeout Detection Flow
^^^^^^^^^^^^^^^^^^^^^^
  - Software configures the timeout threshold by writing to the RTO_COUNT CSR.
  - When a bus transaction starts, the peripheral interconnect asserts the start_rto_i signal and the timeout counter begins to decrement.
  - The counter starts counting down from the value set in the RTO_COUNT CSR and decrements on each positive edge of the reference clock(ref_clk_i).
  - If the peripheral responds before the counter reaches zero:
      - The peripheral interconnect deasserts the start_rto_i signal.
      - The counter is reloaded, and no timeout is signaled.
  - If the counter reaches zero:
      - The rto_o signal is asserted to indicate a timeout.
      - The peripheral interconnect updates which peripheral caused timeout through peripheral_rto_i signals, which is then stored in the RTO_PERIPHERAL_ERROR CSR.
      - The timeout event is acknowledged and cleared by writing any data to the RTO_PERIPHERAL_ERROR CSR (the write value is ignored and the CSR is cleared).
      - 


Timeout Management
^^^^^^^^^^^^^^^^^^
  - Software can monitor the RTO_PERIPHERAL CSR to detect which peripherals have timed out.
  - To acknowledge and clear a timeout event, software writes to the same CSR.

Boot Control
~~~~~~~~~~~~
The boot control mechanism manages the system boot process, determining the behavior of the Fabric Controller/Core-Complex during reset and initial execution.
It allows flexible configuration of boot address, fetch control, and boot mode selection.
This mechanism enables software and hardware to coordinate system boot through configurable registers and external signals, supporting multiple boot modes and sources.

Boot Address Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^
  - On system reset, the default boot address is set to 0x1A000080.
  - Software can modify the boot address by writing a new value to FCBOOT CSR.

Fetch Control
^^^^^^^^^^^^^
  - The Fabric Controller/Core-Complex's activity is gated by the fc_fetchen_o signal i.e. allowing dynamic enable/disable of instruction fetch.
  - This signal is controlled through the FCFETCH CSR.

Boot Mode Selection
^^^^^^^^^^^^^^^^^^^
  - Boot mode is influenced by external hardware signals:
      - bootsel_i: Selects between different boot paths.
          - 1 = SPI boot
          - 0 = Host mode via I2Cs
      - dmactive_i: Indicates debug mode active status.
  - The selected boot mode and current boot status, as well as the debug mode status are captured in the BOOTSEL CSR.

JTAG Interface
~~~~~~~~~~~~~~
The SoC Controller provides an interface to the JTAG debug port, enabling bidirectional communication and control for system-level debugging.
Key Features:
  - 8-bit JTAG register interface 
  - Bidirectional communication through JTAGREG CSR
  - Synchronization of incoming JTAG signals to the system clock

Signal Synchronization
^^^^^^^^^^^^^^^^^^^^^^
  - External JTAG signals are synchronized to the internal system clock(HCLK) to ensure reliable data exchange.

Data Access and Communication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - The upper bits of JTAGREG are updated with incoming JTAG data from external device through soc_jtag_reg_i port.
  - The lower bits of JTAGREG can be written by software to transmit data to the external JTAG device through soc_jtag_reg_i port.
  - This bidirectional access enables debug communication, such as status reporting, control signaling, or debug-triggered behaviors.

Soft Reset Mechanism
~~~~~~~~~~~~~~~~~~~~
The soft reset mechanism allows the SoC Controller to reset all APB client peripherals connected to the APB bus without requiring a full system reset. This feature is useful for recovering from peripheral malfunctions or reinitializing peripherals during runtime.
Key Features:
  - Resets all APB client peripherals to their default states.
  - Allows reconfiguration of peripherals without a full system reset.
  - Provides a mechanism to reinitialize APB peripherals through APB interface.
  - Triggered by writing to the SOFT_RESET CSR.

Operation:
  - Writing any value to the SOFT_RESET CSR (at offset 0x00FC) initiates the soft reset sequence.
  - The write value is ignored, as the CSR acts as a write-only strobe.
  - Upon triggering, the soft_reset_o signal is asserted, propagating the reset to all APB client peripherals.
  - APB client peripheral include the following:
      - I2C Slave
      - Event Controller
      - Advanced Timer
      - GPIO
      - Timer
      - FLL
      - uDMA subsystem
      - eFPGA subsystem
  - The SoC Controller itself is only partially reset, retaining WDT and Boot Control configurations.
  - The following CSRs in SoC Controller are reset to their default values:
      - WCFGFUN
      - RCFGFUN
      - IO_CTRL (0x400-0x4C0)
      - RESET_TYPE1_EFPGA
      - ENABLE_IN_OUT_EFPGA
      - EFPGA_CONTROL_IN
      - RTO_PERIPHERAL_ERROR
      - READY_TIMEOUT_COUNT
  - The reset signal(soft_reset_o) is deasserted once the reset sequence is complete.

System Architecture
-------------------

The figure below depicts the connections between the SoC Controller and rest of the modules in CORE-V-MCU:-

.. figure:: apb_soc_controller_soc_connections.png
   :name: APB_SOC_Controller_SoC_Connections
   :align: center
   :alt:

   APB SoC Controller CORE-V-MCU connections diagram

Programming View Model
----------------------

The APB SOC Controller is memory-mapped at a base address defined by the system. All CSRs are accessible via standard APB read/write operations.

CSR Access
^^^^^^^^^^^
CSRs are accessed using 32-bit reads and writes over the APB bus. The address space is organized as follows:
  - Base CSRs: 0x000 - 0x0FC
  - Pad configuration CSRs: 0x400 - 0x4C0

Programming Sequence
^^^^^^^^^^^^^^^^^^^^
Typical programming sequences include:
  - Read system information from INFO CSR
  - Configure boot address and fetch enable
  - Set up pad configuration and multiplexing
  - Configure watchdog timer if needed
  - Set up eFPGA control parameters
  - Monitor status CSRs as needed

APB SoC Controller CSRs
-----------------------

Refer to  `Memory Map <https://github.com/openhwgroup/core-v-mcu/blob/master/docs/doc-src/mmap.rst>`_ for peripheral domain address of the SoC Controller.

NOTE: Several of the SoC Controller CSR are volatile, meaning that their read value may be changed by the hardware. For example, writting the RX_SADDR CSR will set the address of the receive buffer pointer. As data is received, the hardware will update the value of the pointer to indicate the current address. As the name suggests, the value of non-volatile CSRs is not changed by the hardware. These CSRs retain the last value writen by software.

A CSRs volatility is indicated by its "type".

Details of CSR access type are explained here.

INFO
^^^^
  - Address Offset = 0x0000
  - Type: non-volatile

+----------------+-----------+------------+-------------+----------------------------------+
| **Field**      | **Bits**  | **Access** | **Default** | **Description**                  |
+================+===========+============+=============+==================================+
|   N_CORES      |   31:16   |     RO     |     0x1     | Number of cores in design        |
+----------------+-----------+------------+-------------+----------------------------------+
|   N_CLUSTERS   |   15:0    |     RO     |     0x0     | Number of clusters in design     |
+----------------+-----------+------------+-------------+----------------------------------+

FCBOOT
^^^^^^
  - Address Offset = 0x0004
  - Type: non-volatile

+----------------+-----------+------------+-------------+----------------------------------+
| **Field**      | **Bits**  | **Access** | **Default** | **Description**                  |
+================+===========+============+=============+==================================+
|   BOOT_ADDR    |   31:0    |    RW      | 0x1A000080  | Boot address for the FC core     |
+----------------+-----------+------------+-------------+----------------------------------+

FCFETCH
^^^^^^^
  - Address Offset = 0x0008
  - Type: non-volatile

+----------------+-----------+------------+-------------+------------------------------------+
| **Field**      | **Bits**  | **Access** | **Default** | **Description**                    |
+================+===========+============+=============+====================================+
|   ENABLE       |   0:0     |    RW      |     0x1     | Fetch enable bit                   |
|                |           |            |             | Signals FC to initiate instruction |
|                |           |            |             | fetching and processing            |        
+----------------+-----------+------------+-------------+------------------------------------+

BUILD_DATE
^^^^^^^^^^
  - Address Offset = 0x000C
  - Type: non-volatile

+-------------+----------+------------+-------------+--------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**    |
+=============+==========+============+=============+====================+
|   YEAR      |  31:16   |     RO     |     0x0     |   Year in BCD      |
+-------------+----------+------------+-------------+--------------------+
|   MONTH     |   15:8   |     RO     |     0x0     |   Month in BCD     |
+-------------+----------+------------+-------------+--------------------+
|   DAY       |   7:0    |     RO     |     0x0     |   Day in BCD       |
+-------------+----------+------------+-------------+--------------------+

BUILD_TIME
^^^^^^^^^^
  - Address Offset = 0x0010
  - Type: non-volatile

+---------------+----------+------------+-------------+---------------------+
| **Field**     | **Bits** | **Access** | **Default** | **Description**     |
+===============+==========+============+=============+=====================+
|   HOUR        |   23:16  |     RO     |     0x0     |   Hour in BCD       |
+---------------+----------+------------+-------------+---------------------+
|   MINUTES     |   15:8   |     RO     |     0x0     |   Minutes in BCD    |
+---------------+----------+------------+-------------+---------------------+
|   SECONDS     |   7:0    |     RO     |     0x0     |   Seconds in BCD    |
+---------------+----------+------------+-------------+---------------------+

WCFGFUN
^^^^^^^
  - Address Offset = 0x0060
  - type: non-volatile

+-------------+----------+------------+-------------+------------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**              |
+=============+==========+============+=============+==============================+
| RESERVED    | 31:30    |    RO      |    0x0      | Reserved                     |
+-------------+----------+------------+-------------+------------------------------+
| PADCFG      | 29:24    |    RW      |    0x0      | Pad configuration (TBD)      |
+-------------+----------+------------+-------------+------------------------------+
| RESERVED    | 23:18    |    RO      |    0x0      | Reserved                     |
+-------------+----------+------------+-------------+------------------------------+
| PADMUX      | 17:16    |    RW      |    0x0      | Pad mux configuration        |
+-------------+----------+------------+-------------+------------------------------+
| RESERVED    | 15:6     |    RO      |    0x0      | Reserved                     |
+-------------+----------+------------+-------------+------------------------------+
| IO_PAD      | 5:0      |    RW      |    0x0      | IO pad index                 |
+-------------+----------+------------+-------------+------------------------------+

RCFGFUN
^^^^^^^
  - Address Offset = 0x0064
  - Only IO_PAD bit is writable, that allows reading particular IO pad configuration on subsequent reads

+-------------+----------+------------+-------------+------------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**              |
+=============+==========+============+=============+==============================+
| RESERVED    | 31:30    |    RO      |    0x0      | Reserved                     |
+-------------+----------+------------+-------------+------------------------------+
| PADCFG      | 29:24    |    RO      |    0x0      | Pad configuration (TBD)      |
+-------------+----------+------------+-------------+------------------------------+
| RESERVED    | 23:18    |    RO      |    0x0      | Reserved                     |
+-------------+----------+------------+-------------+------------------------------+
| PADMUX      | 17:16    |    RO      |    0x0      | Pad mux configuration        |
+-------------+----------+------------+-------------+------------------------------+
| RESERVED    | 15:6     |    RO      |    0x0      | Reserved                     |
+-------------+----------+------------+-------------+------------------------------+
| IO_PAD      | 5:0      |    RW      |    0x0      | IO pad index                 |
+-------------+----------+------------+-------------+------------------------------+

JTAGREG
^^^^^^^
  - Address Offset = 0x0074
  - Type: volatile

+---------------+----------+------------+-------------+--------------------------+
| **Field**     | **Bits** | **Access** | **Default** | **Description**          |
+===============+==========+============+=============+==========================+
| RESERVED      | 31:16    |    RO      |    0x0      | Reserved                 |
+---------------+----------+------------+-------------+--------------------------+
| JTAG_REG_IN   | 15:8     |    RO      |    0x0      | synchronized data input  |
|               |          |            |             | from soc_jtag_reg_i port |
+---------------+----------+------------+-------------+--------------------------+
| JTAG_REG_OUT  | 7:0      |    RW      |    0x0      | data to be driven on     |
|               |          |            |             | soc_jtag_reg_o port      |
+---------------+----------+------------+-------------+--------------------------+

BOOTSEL
^^^^^^^
  - Address Offset = 0x00C4
  - Type: volatile

+-------------+----------+------------+-------------+-----------------------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**                         |
+=============+==========+============+=============+=========================================+
| BOOTSEL     |   0:0    | RO         |             | Selected Boot device                    |
|             |          |            |             |  1=SPI                                  |
|             |          |            |             |  0=Host mode via I2Cs                   |
|             |          |            |             |                                         | 
|             |          |            |             | Configured from bootsel_i pin on reset  |
+-------------+----------+------------+-------------+-----------------------------------------+
| DMACTIVE    | 1:1      | RO         |             | DMA active value                        |
|             |          |            |             | Configured from dmactive_i pin on reset |
+-------------+----------+------------+-------------+-----------------------------------------+
| RESERVED    | 29:2     | RO         | 0x0         | Reserved                                |
+-------------+----------+------------+-------------+-----------------------------------------+
| BOOTSEL_IN  | 30       | RO         |             | Current status of bootsel_i pin         |
+-------------+----------+------------+-------------+-----------------------------------------+
| DMACTIVE_IN | 31       | RO         |             | Current status of dmactive_i pin        |
+-------------+----------+------------+-------------+-----------------------------------------+

CLKSEL
^^^^^^
  - Address Offset = 0x00C8
  - Type: volatile

+-----------+----------+------------+-------------+--------------------------------+
| **Field** | **Bits** | **Access** | **Default** | **Description**                |
+===========+==========+============+=============+================================+
|   S       |   0:0    |   RO       |             |   This CSR contains            |  
|           |          |            |             |   whether the system clock     |
|           |          |            |             |   is coming from               |
|           |          |            |             |   the FLL or the FLL is        |
|           |          |            |             |   bypassed.                    |
|           |          |            |             |   It is a read-only            |
|           |          |            |             |   CSR by the core but it       |
|           |          |            |             |   can be written via JTAG.     |
|           |          |            |             |                                |
|           |          |            |             | Shows current status of        |
|           |          |            |             | sel_fll_clk_i pin              |
+-----------+----------+------------+-------------+--------------------------------+

WD_COUNT
^^^^^^^^
  - Address Offset = 0x00D0
  - Type: volatile

+-----------+----------+------------+-------------+-------------------------------------+
| **Field** | **Bits** | **Access** | **Default** | **Description**                     |
+===========+==========+============+=============+=====================================+
|   COUNT   |   30:0   |   RW       |   0x8000    |   Watchdog timer initial value      |
|           |          |            |             |   Only writable before Watchdog is  |
|           |          |            |             |   enabled                           |
+-----------+----------+------------+-------------+-------------------------------------+

WD_CONTROL
^^^^^^^^^^
  - Address Offset = 0x00D4
  - Type: volatile

+-----------------+----------+------------+-----------+----------------------------------------+
| **Field**       | **Bits** | **Access** |**Default**| **Description**                        |
+=================+==========+============+===========+========================================+
|  ENABLE_STATUS  |   31:31  |   RW       |   0x0     |   1=Watchdog Enabled,                  |
|                 |          |            |           |                                        |
|                 |          |            |           |   0=Watchdog not enabled.              |
|                 |          |            |           |                                        |
|                 |          |            |           |   Note: once enabled, cannot be        |
|                 |          |            |           |   disabled                             |
+-----------------+----------+------------+-----------+----------------------------------------+
|  WD_VALUE       |   15:0   |   RW       |           |  Set to 0x6699 to reset watchdog when  |
|                 |          |            |           |  enabled, read current WD value        |
+-----------------+----------+------------+-----------+----------------------------------------+

RESET_REASON
^^^^^^^^^^^^
  - Address Offset = 0x00D8
  - Type: volatile
  - The CSR will get cleared when the APB bus is in waiting state, i.e. after a read or write is performed.

+-----------+----------+------------+-------------+----------------------------------------+
| **Field** | **Bits** | **Access** | **Default** | **Description**                        |
+===========+==========+============+=============+========================================+
|   REASON  |   1:0    |   RW       |     0x0     |   2'b01= reset pin(rstpin_ni) asserted | 
|           |          |            |             |                                        |
|           |          |            |             |   2'b11=Watchdog expired               |
+-----------+----------+------------+-------------+----------------------------------------+

RTO_PERIPHERAL_ERROR
^^^^^^^^^^^^^^^^^^^^
  - Address Offset = 0x00E0
  - Type: volatile
  - Configured from peripheral_rto_i pin
  - Writing to this CSR will clear it (the write value is ignored)

+-------------+----------+------------+-------------+----------------------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**                        |
+=============+==========+============+=============+========================================+
|   FCB_RTO   |   8:8    | RW         | 0x0         | 1 indicates that the FCB interface     |
|             |          |            |             | caused a ready timeout                 |
+-------------+----------+------------+-------------+----------------------------------------+
| TIMER_RTO   |   7:7    | RW         | 0x0         | 1 indicates that the TIMER interface   |
|             |          |            |             | caused a ready timeout                 |
+-------------+----------+------------+-------------+----------------------------------------+
| I2CS_RTO    |   6:6    | RW         | 0x0         | 1 indicates that the I2CS interface    |
|             |          |            |             | caused a ready timeout                 |
+-------------+----------+------------+-------------+----------------------------------------+
|EVENT_GEN_RTO|   5:5    | RW         | 0x0         | 1 indicates that the EVENT GENERATOR   |
|             |          |            |             | interface caused a ready timeout       |
+-------------+----------+------------+-------------+----------------------------------------+
|ADV_TIMER_RTO|   4:4    | RW         | 0x0         | 1 indicates that the ADVANCED TIMER    |
|             |          |            |             | interface caused a ready timeout       |
+-------------+----------+------------+-------------+----------------------------------------+
|SOC_CONTROL_R|   3:3    | RW         | 0x0         | 1 indicates that the SOC CONTROL       |
|TO           |          |            |             | interface caused a ready timeout       |
+-------------+----------+------------+-------------+----------------------------------------+
|UDMA_RTO     |   2:2    | RW         | 0x0         | 1 indicates that the UDMA CONTROL      |
|             |          |            |             | interface caused a ready timeout       |
+-------------+----------+------------+-------------+----------------------------------------+
|GPIO_RTO     |   1:1    | RW         | 0x0         | 1 indicates that the GPIO interface    |
|             |          |            |             | caused a ready timeout                 |
+-------------+----------+------------+-------------+----------------------------------------+
|FLL_RTO      |   0:0    | RW         | 0x0         | 1 indicates that the FLL interface     |
|             |          |            |             | caused a ready timeout                 |
+-------------+----------+------------+-------------+----------------------------------------+

READY_TIMEOUT_COUNT
^^^^^^^^^^^^^^^^^^^
  - Address Offset = 0x00E4
  - Type: volatile

+-------------+----------+------------+-------------+----------------------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**                        |
+=============+==========+============+=============+========================================+
| COUNT       |  19:0    | RW         | 0xFF        | Number of APB clocks before a ready    |
|             |          |            |             | timeout occurs.                        |
|             |          |            |             | When writing to this CSR, last 4       |
|             |          |            |             | bits from write data will be replaced  |
|             |          |            |             | by 0xf.                                |
+-------------+----------+------------+-------------+----------------------------------------+

RESET_TYPE1_EFPGA
^^^^^^^^^^^^^^^^^
  - Address Offset = 0x00E8
  - Type: non-volatile

+-------------+----------+------------+-------------+-----------------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**                   |
+=============+==========+============+=============+===================================+
| RESET_LB    |   3:3    | RW         | 0x0         | Reset eFPGA Left Bottom Quadrant  |
+-------------+----------+------------+-------------+-----------------------------------+
| RESET_RB    |   2:2    | RW         | 0x0         | Reset eFPGA Right Bottom Quadrant |
+-------------+----------+------------+-------------+-----------------------------------+
| RESET_RT    |   1:1    | RW         | 0x0         | Reset eFPGA Right Top Quadrant    |
+-------------+----------+------------+-------------+-----------------------------------+
| RESET_LT    |   0:0    | RW         | 0x0         | Reset eFPGA Left Top Quadrant     |
+-------------+----------+------------+-------------+-----------------------------------+

ENABLE_IN_OUT_EFPGA
^^^^^^^^^^^^^^^^^^^
  - Address Offset = 0x00EC
  - Type: non-volatile

+--------------+----------+------------+-------------+----------------------------------------+
| **Field**    | **Bits** | **Access** | **Default** | **Description**                        |
+==============+==========+============+=============+========================================+
|ENABLE_EVENTS |   5:5    | RW         | 0x0         | Enable events from efpga to SOC caused |
|              |          |            |             | a ready timeout                        |
+--------------+----------+------------+-------------+----------------------------------------+
|ENABLE_SOC_ACC|   4:4    | RW         | 0x0         | Enable SOC memory mapped access to     |
|ESS           |          |            |             | EFPGA                                  |
+--------------+----------+------------+-------------+----------------------------------------+
|ENABLE_TCDM_P3|   3:3    | RW         | 0x0         | Enable EFPGA access via TCDM port 3    |
+--------------+----------+------------+-------------+----------------------------------------+
|ENABLE_TCDM_P2|   2:2    | RW         | 0x0         | Enable EFPGA access via TCDM port 2    |
+--------------+----------+------------+-------------+----------------------------------------+
|ENABLE_TCDM_P1|   1:1    | RW         | 0x0         | Enable EFPGA access via TCDM port 1    |
+--------------+----------+------------+-------------+----------------------------------------+
|ENABLE_TCDM_P0|   0:0    | RW         | 0x0         | Enable EFPGA access via TCDM port 0    |
+--------------+----------+------------+-------------+----------------------------------------+

EFPGA_CONTROL_IN
^^^^^^^^^^^^^^^^
  - Address Offset = 0x00F0
  - Type: non-volatile

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
|EFPGA_CONTROL_IN |   31:0   | RW         | 0x0         | EFPGA control bits               |
|                 |          |            |             | (use per eFPGA design)           |
+-----------------+----------+------------+-------------+----------------------------------+

EFPGA_STATUS_OUT
^^^^^^^^^^^^^^^^
  - Address Offset = 0x00F4
  - Type: volatile

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
|EFPGA_CONTROL_OUT|   31:0   | RO         |             | Status from eFPGA                |
|                 |          |            |             | Configured from status_out pin   |
+-----------------+----------+------------+-------------+----------------------------------+

EFPGA_VERSION
^^^^^^^^^^^^^
  - Address Offset = 0x00F8
  - Type: volatile

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
|EFPGA_VERSION    |    7:0   | RO         |             | EFPGA version info               |
|                 |          |            |             | Configured from version pin      |
+-----------------+----------+------------+-------------+----------------------------------+

SOFT_RESET
^^^^^^^^^^
  - Address Offset = 0x00FC
  - Type: volatile
  - This CSR is a write-only strobe i.e. the write value is ignored

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
| SOFT_RESET      |    0:0   | WO         |             | Write only strobe to reset all   |
|                 |          |            |             | APB clients                      |
+-----------------+----------+------------+-------------+----------------------------------+

IO_CTRL
^^^^^^^
  - Address Offset = 0x0400**
  - I/O control supports two functions:
      -  I/O configuration
      -  I/O function selection

I/O configuration (CFG) is a series of bits that may be used to
control I/O PAD characteristics, such as drive strength and slew rate.
These driver control characteristics are implementation technology
dependent and are TBD. I/O selection (MUX) controls the select field of
a mux that connects the I/O to different signals in the device.

Each port is individually addressable at offset + IO_PORT * 4. For
example, the IO_CTRL CSR for IO_PORT 8 is at offset 0x0420.

+-------------+----------+------------+-------------+-------------------------+
| **Field**   | **Bits** | **Access** | **Default** | **Description**         |
+=============+==========+============+=============+=========================+
| CFG         |   13:8   | RW         | 0x00        | Pad configuration (TBD) |
+-------------+----------+------------+-------------+-------------------------+
| MUX         |   1:0    | RW         | 0x00        | Mux select              |
+-------------+----------+------------+-------------+-------------------------+

Firmware Guidelines
--------------------

Initialization Sequence
^^^^^^^^^^^^^^^^^^^^^^^
  - Read System Information
      - Read the INFO CSR at offset 0x00 from the SOC_CTRL_BASE address.
      - Extract the number of cores from bits [31:16] of the read value.
      - Extract the number of clusters from bits [15:0] of the read value.
      - Use this information to properly configure system resources. A few use cases are:
          - Resource Initialization: Software can read the core/cluster count to dynamically allocate memory structures and initialize only the hardware resources that actually exist on the chip variant.
          - Workload Distribution: Task schedulers can use this information to optimize thread distribution across available cores and clusters, balancing performance against power consumption.
  - Configure Boot Parameters
      - Write the desired boot address to the FCBOOT CSR at offset 0x04.
      - The fetch enable bit of FCFETCH CSR at offset 0x08 is enabled by default i.e. the Fabric Control/Core-Complex will start fetching instruction from the provided address.
  - Configure IO Pads
      - For each IO pad that needs configuration:
          - Determine the IO pad index (0 to 47).
          - Select the appropriate multiplexer value for the desired function.
          - Determine the electrical pad configuration ( TBD ).
          - Combine these values: IO index in bits [5:0], multiplexer in bits [17:16], and configuration in bits [29:24].
          - Write this combined value to the WCFGFUN CSR at offset 0x60.
      - Alternatively, configure pads directly through their dedicated addresses:
          - Calculate the pad CSR address: 0x400 + (IO_PORT * 4).
          - Write the multiplexer value to bits [1:0] and configuration to bits [13:8].
  - Configure eFPGA
      - Reset particular eFPGA Quadrant by writing to the RESET_TYPE1_EFPGA CSR at offset 0xE8.
      - Enable the desired interfaces by writing to ENABLE_IN_OUT_EFPGA CSR at offset 0xEC:
          - Bit 0: Enable TCDM0 interface
          - Bit 1: Enable TCDM1 interface
          - Bit 2: Enable TCDM2 interface
          - Bit 3: Enable TCDM3 interface
          - Bit 4: Enable APB interface
          - Bit 5: Enable events interface
      - Set additional control parameters(as per eFPGA design) by writing to the EFPGA_CONTROL CSR at offset 0xF0.

Ready Timeout Management
^^^^^^^^^^^^^^^^^^^^^^^^
  - Initialization:
      - Set the desired timeout value by writing to the RTO_COUNT CSR at offset 0xE4.(only bits [19:4] are used, with the 4 LSBs always set to 0xF)
      - The timeout value should be long enough to accommodate longest legitimate time a peripheral might take to respond with an additional margin.
      - The default value after reset is 0x000FF.
  - Error Handling:
      - When a timeout is detected, identify the source peripheral through RTO_PERIPHERAL_ERROR CSR.
      - Take appropriate recovery actions for the affected peripheral
      - Write any value to the RTO_PERIPHERAL CSR to clear the timeout indication i.e. to clear which peripheral caused the timeout. The write value is ignored.
          - This resets the peripheral timeout indicators but doesn't affect the timeout counter

Watchdog Management
^^^^^^^^^^^^^^^^^^^
  - Watchdog Initialization
      - Determine the appropriate timeout value based on your system requirements.
      - Write this value to the WD_COUNT CSR before enabling the watchdog.
      - The timeout value can be calculated while keeping the following considerations:
          - The timeout should exceed the longest critical section in the code.
          - The timeout should be shorter than the maximum time you can tolerate a system hang.
          - There should be a safety margin to account for unexpected delays. It is recommended to set the timeout value to 1.5x to 2x above your calculated minimum.
          - Since the timeout value is in clock cycles, the below formula can be used to calculate the timeout value:
              - timeout_value = (timeout_in_seconds * ref_clk_frequency) - 1
          - For example, if the reference clock frequency is 100MHz and you want a timeout of 2 seconds, the calculation would be:
              - timeout_value = (2 * 100,000,000) - 1 = 199,999,999
          - This would set the watchdog to timeout/expire after 2 seconds.
  - Watchdog Enabling
      - Enable the watchdog by writing 0x80000000 to the WD_CONTROL CSR.
  - Regular Servicing
      - Establish a reliable mechanism to service the watchdog at regular intervals.
          - This can be a dedicated high priority timer service task running at regular intervals in case of RTOS which is supported by CORE-V-MCU. 
      - The servicing interval(timeperiod between each subsequent servicing) should be typically between 0.5% to 0.75% of the watchdog timeout value.
      - To service the watchdog, write 0x00006699 to the WD_CONTROL CSR.
  - Watchdog Recovery Handling
      - After a watchdog reset, read the reset reason through the RESET_REASON CSR.
      - Implement appropriate post-reset actions, such as logging the event and the system status(various CSRs across CORE-V-MCU system) through software for diagnosis i.e. the software reads and stores CSRs values.

Soft Reset Procedure
^^^^^^^^^^^^^^^^^^^^
  - Prepare for Reset
      - Complete any pending operations and save critical state if needed.
      - Save any necessary state information if required for recovery after the reset.
  - Trigger Reset
      - Write any value to the SOFT_RESET CSR at offset 0xFC(the write value is ignored).
      - The system will immediately begin the reset sequence.
      - The below CSR will be reset to their default values
          - WCFGFUN
          - RCFGFUN
          - IO_CTRL (0x400-0x4C0)
          - RESET_TYPE1_EFPGA
          - ENABLE_IN_OUT_EFPGA
          - EFPGA_CONTROL_IN
          - RTO_PERIPHERAL_ERROR
          - READY_TIMEOUT_COUNT
    - The reset signal will propagate to other APB Client peripherals.
  - Post-Reset Actions
      - The system will automatically reinitialize the APB peripherals to their default states.
      - Reinitialize the affected APB peripherals as needed.

JTAG communication
^^^^^^^^^^^^^^^^^^
  - Write to external device
      - Write the data to the JTAGREG CSR through the APB bus.
      - The written value will be available on the soc_jtag_reg_o output port.
  - Read from external device
      - The external JTAG device writes the data on soc_jtag_reg_i input port.
      - There is double synchronization for the input signal to prevent metastability.
      - Post synchronization, the data can be read from the JTAGREG CSR through the APB bus.

Pin Diagram
-----------

The figure below represents the input and output pins for the APB SoC Controller:-

.. figure:: apb_soc_controller_pin_diagram.png
   :name: APB_SoC_Controller_Pin_Diagram
   :align: center
   :alt:

   APB SoC Controller Pin Diagram

Clock and Reset
^^^^^^^^^^^^^^^
  - HCLK: APB system clock input, generated by APB PLL.
  - HRESETn: Active-low system reset signal for initializing CSRs and logic
  - ref_clk_i: Reference clock input, used for watchdog operations, generated by APB PLL.
  - soft_reset_o: Soft reset output, triggered by writing to SOFT_RESET CSR.

APB Interface
^^^^^^^^^^^^^
  - PADDR[11:0]: APB address bus input
  - PWDATA[31:0]: APB write data bus input
  - PWRITE: APB write enable signal
  - PSEL: APB slave select input
  - PENABLE: APB enable signal
  - PRDATA[31:0]: APB read data bus output
  - PREADY: APB ready signal output, indicates completion of APB transaction
  - PSLVERR: APB slave error output

Boot and Configuration
^^^^^^^^^^^^^^^^^^^^^^
  - sel_fll_clk_i: FLL clock selection input status pin; its value is captured in CLKSEL CSR for monitoring.
  - bootsel_i: Boot select input status pin; its value is captured in BOOTSEL CSR for monitoring.
  - fc_bootaddr_o[31:0]: Boot address output for FC (Fabric Controller); controlled via FCBOOT CSR.
  - fc_fetchen_o: Fetch enable output for FC; controlled via FCFETCH CSR.
  
Watchdog Interface
^^^^^^^^^^^^^^^^^^
  - wd_expired_o: Watchdog expired output signal, triggered when watchdog counter reaches 1
  - stoptimer_i: Timer stop input signal, triggered by core complex
  - rstpin_ni: Active-low reset pin input for resetting watchdog

Pad Configuration Interface
^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - pad_cfg_o[47:0][5:0]: Pad configuration output signals; controlled via IO_CTRL CSRs or WCFGFUN CSR.
  - pad_mux_o[47:0][1:0]: Pad multiplexing output signals; controlled via IO_CTRL CSRs or WCFGFUN CSR.

JTAG Interface
^^^^^^^^^^^^^^
  - soc_jtag_reg_i[7:0]: JTAG CSR input status pin; its value is captured in JTAGREG CSR for monitoring.
  - soc_jtag_reg_o[7:0]: JTAG CSR output; driven by JTAGREG CSR

eFPGA Interface
^^^^^^^^^^^^^^^
  - control_in[31:0]: Control output to peripherals; driven by EFPGA_CONTROL CSR
  - clk_gating_dc_fifo_o: Clock gating for DC FIFO to eFPGA, always 1 as per current implementation
  - reset_type1_efpga_o[3:0]: Reset signals for eFPGA; driven by RESET_TYPE1_EFPGA CSR
  - enable_udma_efpga_o: Enable uDMA to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR
  - enable_events_efpga_o: Enable events to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR
  - enable_apb_efpga_o: Enable APB to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR
  - enable_tcdm3_efpga_o: Enable TCDM3 to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR
  - enable_tcdm2_efpga_o: Enable TCDM2 to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR
  - enable_tcdm1_efpga_o: Enable TCDM1 to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR
  - enable_tcdm0_efpga_o: Enable TCDM0 to eFPGA; driven by ENABLE_IN_OUT_EFPGA CSR

  - status_out[31:0]: Status input signals from eFPGA; its value is captured in EFPGA_STATUS_OUT CSR for monitoring.
  - version[7:0]: eFPGA version input status pin; its value is captured in EFPGA_VERSION CSR for monitoring.
  - dmactive_i: Debug mode active input status pin; its value is captured in BOOTSEL CSR for monitoring.

Ready Timeout Interface
^^^^^^^^^^^^^^^^^^^^^^^
  - rto_o: Ready timeout output signal provided to Peripheral Interconnect; asserted when ready timeout count reaches 0. 
  - start_rto_i: Start ready timeout input controlled by Peripheral Interconnect; triggers the ready timeout counter. 
  - peripheral_rto_i[10:0]: Peripheral ready timeout input provided by Peripheral Interconnect; indicates which peripheral caused the timeout.
