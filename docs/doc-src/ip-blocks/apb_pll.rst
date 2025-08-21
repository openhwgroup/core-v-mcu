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
.. _apb_pll:

APB PLL
=======

APB PLL module serves as a centralized clock generation system for CORE-V-MCU.
It handles the clock generation to various subsystems like UDMA subsystem, eFPGA subsytem, APB subsystem and On chip memories.


Features
---------
-  Multiple output clock generation

   - SOC clock
   - Peripheral clock
   - Cluster clock
   - Reference clock 

-  Configurable divisor for each output clock

-  Configurable bypass mode


Block Architecture
------------------

APB PLL module's main objective is to generate output clock signals like (peripheral, SoC, and eFPGA clocks) based on the  input ref_clk_i. 
The APB PLL includes submodules such as PLL TOP, divider and cascaded divider and mux. The APB PLL can be configured using CSRs. The CSRs of the APB PLL are accessible using the APB bus.

The ref_clk_i is provided by the external devices. This clock signal can be scaled using various CSR configurations.
APB PLL generates the following clock signals:-

- soc_clk_o, It is the system clock for the CORE_V_MCU 

- periph_clk_o, UDMA subsystem uses this clock 

- cluster_clk_o, eFPGA subsystem uses this clock

- ref_clk_o, APB and eFPGA subsystems uses this clock



The figure below is a high-level block Diagram of APB PLL:

.. figure:: apb_pll_block_diagram.png
   :name: apb_pll_block_diagram
   :align: center
   :alt: 

APB PLL Components
~~~~~~~~~~~~~~~~~~~

The below sections explain the functionality of various components of the APB PLL.

PLL TOP 
^^^^^^^
PLL TOP generats output clock which acts as the input to the cascaded divider and mux.
It also generates a bypass signal to the mux.
PLL TOP takes BYPASS and ref_clk_i as input and process as per the below conditions:

- When the BYPASS bitfield is '1' then output clock period value is same as the period of the ref_clk_i clock.

- When the BYPASS bitfield is '0' then output clock period will be 2.5 times the period of the ref_clk_i.

Cascaded divider and mux 
^^^^^^^^^^^^^^^^^^^^^^^^^
Divider and mux are cascaded to generate various clock signals for peripheral, soc and core domains. Input signal from PLL TOP is provided to each of these 3 Cascaded divider and mux combinations to get 3 unique output clock signals.
Working of the cascaded divider and mux is same for all the 3 types. 

Divider:
^^^^^^^^
Divider receives input from the PLL TOP and provides the output scaled down clock signal to the mux.
The APB PLL uses S_DIV, P_DIV, F_DIV, and R_DIV bitfields in REG_SOC, REG_PERIPH, REG_CLUSTER, and REG_REF to set divider values for the SoC, peripheral, FPGA cluster, and reference clocks respectively.
As these bitfields function the same way, they will be collectively referred to as DIV from here on.
The divider scales down the PLL TOP output frequency by a factor defined by the DIV value

DIV (Clock divisor values):

- If the DIV bitfield value is either 0 or 1, then the output clock itself is not generated.
- If the DIV bitfield value is 2, then the output clock is same as the input clock.
- If the DIV bitfield value is in the range of (0x3 to 0x1FF), then the output clock is generated according to the below formulas.

Frequency Calculation: 

- Output Clock Frequency = Input Clock Frequency / (DIV bitfield value)

Time Period Calculation: 

- Output Clock Time Period = Input Clock Time Period * (DIV bitfield value)

For example, if the Input clock ferquency is 200 MHz and the Div bitfield is 0x28

- Output Clock ferquency = 200 MHz / 0x28 = 5 MHz
- Output Clock Period = (1 / (200 * 10^6)) * 0x28 = 200 ns

Multiplexer or Mux:
^^^^^^^^^^^^^^^^^^^
Multiplexer selects the output signal to be generated for each domain depending on BYPASS bitfield of REG_CTL CSR. BYPASS bit acts as the select line for 2x1 Mux.
It takes two input clocks, One input clock is received from the divider and other input clock is ref_clk_i and and process as per the below conditions:

- When the BYPASS bitfield is '1' then output clock period value is same as the period of the ref_clk_i clock.

- When the BYPASS bitfield is '0' then output clock period value is same as the period of the clock received from the divider.

Reset
^^^^^^

APB PLL can be reset in the following 3 ways:

1. Software Reset via Control Register:

When the RESET bitfield in the REG_CTL CSR is set to '1', only the PLL top module is reset. As a result, clock outputs to all dividers are driven to '0'.

2. Global Reset via HRESETn: 

When the HRESETn pin is deasserted (low), all CSRs are reset, and the PLL top module is also reset. Consequently, clocks to all dividers are driven to '0'.

3. Local Reset via rst_ni:

When the rst_ni pin is deasserted (low), all dividers and multiplexers (muxes) are reset. 
In dividers, the counter and clock are driven to '0'.
In mux, Bypass bit or select line is driven to '0'.


System Architecture:
--------------------

The figure below depicts the connections between the APB PLL and rest of the modules in Core-V-MCU:-

.. figure:: apb_pll_soc_connections.png
   :name: APB PLL SoC Connections
   :align: center
   :alt:

   APB PLL Core-V-MCU connections diagram



Programmers View:
-----------------

Initial Configurations:
~~~~~~~~~~~~~~~~~~~~~~~
There are CSR bitfields in the APB PLL that are required to be configured before any operations are initiated. 

-  Configure Peripheral divisor through P_DIV bitfield in PERIPH_DIV CSR.
-  Configure SOC divisor through S_DIV bitfield in SOC_DIV CSR.
-  Configure eFPGA divisor through F_DIV bitfield in CLUSTER_DIV CSR.
-  Configure reference divisor through R_DIV bitfield in REF_DIV CSR.
-  Mode selection of APB PLL by configuring the MODE in REG_CTL CSR.
-  Locked or unlocked by configuring the LOCK in in REG_CTL CSR.
-  Power down by configuring the PD in REG_CTL CSR.
-  Divisor Power down by configuring the PDDP in REG_CTL CSR.

Control configurations/operations:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are CSR bitfields in the APB PLL which controls operations 

- APB PLL can bypass domain clock signals and provide reference clock as output by setting BYPASS bitfield in REG_CTL CSR.
- APB PLL is resetted by setting RESET bitfield in REG_CTL CSR.

APB PLL CSRs
------------

Refer to  `Memory Map <https://github.com/openhwgroup/core-v-mcu/blob/master/docs/doc-src/mmap.rst>`_  Map for the peripheral domain addresses of the APB PLL.
NOTE: APB PLL CSRs are non-volatile, meaning that their read value will not be changed by the hardware. A CSR's volatility is indicated by its "type".
Details of CSR access type are explained `here <https://docs.openhwgroup.org/projects/core-v-mcu/doc-src/mmap.html#csr-access-types>`_.

REG_CTL
~~~~~~~

- Address Offset = 0x00
- Type: non-volatile

+-----------+-------+--------+---------+------------------------------+
|   Field   | Bits  | Access | Default |   Description                |
|           |       |        |         |                              |
+===========+=======+========+=========+==============================+
| LOCK      | 31:31 |  R     |   0x0   | PLL Lock                     |
|           |       |        |         |                              |
|           |       |        |         | 1= Locked,                   |
|           |       |        |         |                              |
|           |       |        |         | 0= Unlocked                  |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+
| RSVD3     | 30:26 |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| PDDP      | 25:25 |  RW    |   0x1   | PLL Divisor Power Down       |
|           |       |        |         |                              |
|           |       |        |         | 1=Power Down,                |
|           |       |        |         |                              |
|           |       |        |         | 0=Normal Operation           |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+
| PD        | 24:24 |  RW    |   0x1   | PLL Power Down               |
|           |       |        |         |                              |
|           |       |        |         | 1=Power Down,                |
|           |       |        |         |                              |
|           |       |        |         | 0=Normal Operation           |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+
| RSVD2     | 23:18 |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| MODE      | 17:16 |  RW    |   0x0   | MODE                         |
|           |       |        |         |                              |
|           |       |        |         | 0=Normal,                    |
|           |       |        |         |                              |
|           |       |        |         | 1=Fractional,                |
|           |       |        |         |                              |
|           |       |        |         | 2=SpreadSpectrum,            |
|           |       |        |         |                              |
|           |       |        |         | 3=Reserved                   |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+
| RSVD1     | 15:14 |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| DM        | 13:8  |  RW    |   0x1   | Reference Clock Divisor      |
|           |       |        |         |                              |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+
| RSVD0     | 7:2   |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| RESET     | 1:1   |  RW    |   0x1   | PLL Reset                    |
|           |       |        |         |                              |
|           |       |        |         | 1=Reset,                     |
|           |       |        |         |                              |
|           |       |        |         | 0=Normal Operation           |
+-----------+-------+--------+---------+------------------------------+
| BYPASS    | 0:0   |  RW    |   0x1   | PLL/Divisor Bypass           |
|           |       |        |         |                              |
|           |       |        |         | 1= all clocks are reference  |
|           |       |        |         | clocks                       |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+

REG_DIV   
~~~~~~~

- Address Offset = 0x04
- Type: non-volatile

+-----------+-------+--------+---------+------------------------------+
|   Field   | Bits  | Access | Default |   Description                |
|           |       |        |         |                              |
+===========+=======+========+=========+==============================+
| RSVD1     | 31:27 |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| DN        | 26:16 |  RW    |   0xa0  | PLL Feedback Divisor         |
|           |       |        |         | (0xa0 = PLL at1.6GHz)        |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |                    
+-----------+-------+--------+---------+------------------------------+
| RSVD1     | 15:3  |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| DP        | 2:0   |  RW    |   0x4   | PLL Output Divisor           |
|           |       |        |         | (0x4 = 400MHz CLK0)          | 
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+

REG_FRAC   
~~~~~~~~

- Address Offset = 0x08
- Type: non-volatile

+-----------+-------+--------+---------+------------------------------+
|   Field   | Bits  | Access | Default |   Description                |
|           |       |        |         |                              |
+===========+=======+========+=========+==============================+
| RSVD0     | 31:24 |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| FRAC      | 23:0  |  RW    |   0x0   | PLL Fractional part of DN    |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+

REG_SS1  
~~~~~~~

- Address Offset = 0x0C
- Type: non-volatile

+-----------+-------+--------+---------+------------------------------+
|   Field   | Bits  | Access | Default |   Description                |
|           |       |        |         |                              |
+===========+=======+========+=========+==============================+
| RSVD0     | 31:11 |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| SRATE     | 10:0  |  RW    |   0x0   | PLL Spread Spectrum Triangle |
|           |       |        |         | modulation Frequency         |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+

REG_SS2  
~~~~~~~
 
- Address Offset = 0x10
- Type: non-volatile

+-----------+-------+--------+---------+------------------------------+
|   Field   | Bits  | Access | Default |   Description                |
|           |       |        |         |                              |
+===========+=======+========+=========+==============================+
| RSVD0     |31:24  |  RW    |   0x0   | Reserved                     |
|           |       |        |         |                              |
+-----------+-------+--------+---------+------------------------------+
| SSLOPE    | 23:0  |  RW    |   0x0   | PLL Spread Spectrum Step     |
|           |       |        |         |                              |
|           |       |        |         | **Feature not implemented**  |
+-----------+-------+--------+---------+------------------------------+

REG_SOC  
~~~~~~~

- Address Offset = 0x14
- Type: non-volatile

+---------+-------+--------+---------+------------------------------+
|  Field  | Bits  | Access | Default |   Description                |
|         |       |        |         |                              |
+=========+=======+========+=========+==============================+
| RSVD0   |31:10  | RW     |   0x0   | Reserved                     |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+
| S_DIV   | 9:0   | RW     |   0x0   | SOC clock Divisor            |
|         |       |        |         |                              |
|         |       |        |         | 0x0,0x1 = Invalid value      |
|         |       |        |         | (Output clock will be '0')   |
|         |       |        |         |                              |
|         |       |        |         | 0x2 = Same frequency as the  |
|         |       |        |         | input Clock                  |
|         |       |        |         |                              |
|         |       |        |         | (0x3- 0x1FF) = Valid range   |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+


REG_PERIPH  
~~~~~~~~~~

- Address Offset = 0x18
- Type: non-volatile

+---------+-------+--------+---------+------------------------------+
|  Field  | Bits  | Access | Default |   Description                |
|         |       |        |         |                              |
+=========+=======+========+=========+==============================+
| RSVD0   |31:10  | RW     |   0x0   | Reserved                     |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+
| P_DIV   | 9:0   | RW     |   0x0   | Peripheral clock Divisor     |
|         |       |        |         |                              |
|         |       |        |         | 0x0,0x1 = Invalid value      |
|         |       |        |         | (Output clock will be '0')   |
|         |       |        |         |                              |
|         |       |        |         | 0x2 = Same frequency as the  |
|         |       |        |         | input Clock                  |
|         |       |        |         |                              |
|         |       |        |         | (0x3- 0x1FF) = Valid range   |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+


REG_CLUSTER  
~~~~~~~~~~~

- Address Offset = 0x1C
- Type: non-volatile

+---------+-------+--------+---------+------------------------------+
|  Field  | Bits  | Access | Default |   Description                |
|         |       |        |         |                              |
+=========+=======+========+=========+==============================+
| RSVD0   |31:10  | RW     |   0x0   | Reserved                     |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+
| F_DIV   | 9:0   | RW     |   0x0   | FPGA clock Divisor           |
|         |       |        |         |                              |
|         |       |        |         | 0x0,0x1 = Invalid value      |
|         |       |        |         | (Output clock will be '0')   |
|         |       |        |         |                              |
|         |       |        |         | 0x2 = Same frequency as the  |
|         |       |        |         | input Clock                  |
|         |       |        |         |                              |
|         |       |        |         | (0x3- 0x1FF) = Valid range   |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+


REG_REF  
~~~~~~~

- Address Offset = 0x20
- Type: non-volatile

+---------+-------+--------+---------+------------------------------+
|  Field  | Bits  | Access | Default |   Description                |
|         |       |        |         |                              |
+=========+=======+========+=========+==============================+
| RSVD0   | 31:10 | RW     |   0x0   | Reserved                     |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+
| R_DIV   | 9:0   | RW     |   0x0   | Reference clock Divisor      |
|         |       |        |         |                              |
|         |       |        |         | 0x0,0x1 = Invalid value      |
|         |       |        |         | (Output clock will be '0')   |
|         |       |        |         |                              |
|         |       |        |         | 0x2 = Same frequency as the  |
|         |       |        |         | input Clock                  |
|         |       |        |         |                              |
|         |       |        |         | (0x3- 0x1FF) = Valid range   |
|         |       |        |         |                              |
+---------+-------+--------+---------+------------------------------+


Firmware Guidelines
-------------------

Initialization:
~~~~~~~~~~~~~~~
- Set the RESET bitfield of REG_CTL CSR to reset PLL.
- FW can update the below bitfields to any custom value as per their description before ref_clk_i is triggered. Otherwise, all the config values of CSRs to be updated to default.

  - The S_DIV bitfields of SOC_DIV CSR for soc_clk_o. 

  - The F_DIV bitfields of CLUSTER_DIV CSR for cluster_clk_o.

  - The P_DIV bitfields of PERIPH_DIV CSR for periph_clk_o.

  - The R_DIV bitfields of REF_DIV CSR for ref_clk_o.


Output clock generation of the APB_PLL:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FW can observe the following APB_PLL generated output clock signals:

- soc_clk_o
- periph_clk_o
- cluster_clk_o
- ref_clk_o


Bypass the domain clock signals:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if the BYPASS bitfield is set to '1' then all the domain output clock signals are driven by the ref_clk_i and the divider will not scale the clock.



Pin Diagram
-----------

The figure below represents the input and output pins for the APB PLL:-

.. figure:: apb_pll_pin_diagram.png
   :name: APB_PLL_Pin_Diagram
   :align: center
   :alt:
   
   APB PLL Pin Diagram

Clock and Reset Signals
~~~~~~~~~~~~~~~~~~~~~~~
- HCLK: System clock input. It is driven by the soc_clk_o.
- HRESETn: Active-low reset input

APB Interface Signals
~~~~~~~~~~~~~~~~~~~~~
- PADDR[11:0]: APB address bus input
- PSEL: APB peripheral select input
- PENABLE: APB enable input
- PWRITE: APB write control input (high for write, low for read)
- PWDATA[31:0]: APB write data bus input
- PREADY: APB ready output to indicate transfer completion  
- PRDATA[31:0]: APB read data bus output
- PSLVERR: APB slave error

APB PLL Interface Signals
~~~~~~~~~~~~~~~~~~~~~~~~~~
- ref_clk_i: Reference clock input from the external devices.
- rst_ni: Reset the clock dividers and mux
- soc_clk_o: Output clock for the core soc domain
- periph_clk_o: Output clock for the peripheral domain
- cluster_clk_o: Output clock for the cluster/eFPGA domain
- ref_clk_o: Output reference clock
- AVDD: Bidirectional voltage AVDD  (**Feature not implemented**)
- AVDD2: Bidirectional voltage AVDD2  (**Feature not implemented**)
- AVSS: Bidirectional voltage AVSS  (**Feature not implemented**)
- VDDC: Bidirectional voltage VDDC  (**Feature not implemented**)
- VSSC: Bidirectional voltage VSSC  (**Feature not implemented**)