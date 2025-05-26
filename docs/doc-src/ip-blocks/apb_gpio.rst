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
.. _apb_gpio:

APB GPIO
========
The General Purpose Input/Output (GPIO) IP block supports S/W access
to read and write the values on selected I/O, and configuring selected
I/O to generate interrupts.

Features
--------

-  Configurable number of GPIO pins (Upto 128, current implementation supports 32).
-  Programmable direction control for each pin (input, output, or open-drain).
-  Individual control for setting, clearing, or toggling output pins
-  Pin status reading capability
-  Interrupt generation capabilities with multiple configurable types:
    - Rising edge detection
    - Falling edge detection
    - Active low level detection
    - Active high level detection
-  Input synchronization to prevent metastability issues.

Block Architecture
------------------

The figure below is a high-level block diagram of the APB GPIO module:-

.. figure:: apb_gpio_block_diagram.png
   :name: APB_GPIO_Block_Diagram
   :align: center
   :alt:

   APB GPIO Block Diagram

The APB GPIO IP consists of the following key components:

APB control logic
~~~~~~~~~~~~~~~~~
The APB control logic interfaces with the APB bus to decode and execute commands.
It handles CSR reads and writes according to the APB protocol, providing a standardized interface to the system.

GPIO CSR
~~~~~~~~
These CSRs store the configuration for each GPIO pin, including:
  - Direction settings (input, output, open-drain)
  - Output value
  - Interrupt type configuration
  - Interrupt enable status

Open-Drain Operation
~~~~~~~~~~~~~~~~~~~~
The GPIO module supports open-drain operation for pins configured as outputs. Open-drain is a specific output driver configuration where the GPIO pin can either pull the signal to ground (logic '0') or release it to a high-impedance state,
but cannot actively drive it to a high voltage level (logic '1'). This configuration requires an external pull-up resistor to achieve a logic '1' state.

The external pull-up resistor (typically 1kΩ to 10kΩ) must be connected between the GPIO pin and the desired high-voltage level (VDD).
Without this pull-up resistor, the pin will remain in an undefined state when not actively driven low.

Input Synchronization
~~~~~~~~~~~~~~~~~~~~~
Metastability refers to an unstable state in which the signal fails to settle into a stable low or high level within a required time.
A dual-stage synchronizer in the GPIO module prevents metastability issues when sampling external inputs by synchronizing them to the system clock domain.
This synchronizer consists of two flip-flops in series, which helps to ensure that any glitches or transient signals on the GPIO inputs are filtered out before being processed by the rest of the system.
This synchronization process ensures that the GPIO inputs are stable and reliable when read by the system, preventing false triggering of events or interrupts.
 
Interrupt Generation Logic
~~~~~~~~~~~~~~~~~~~~~~~~~~
This section describes how GPIO pins generate interrupts and the differences between edge-triggered and level-triggered behavior.

Interrupt Capability
^^^^^^^^^^^^^^^^^^^^
GPIO pins can be used to receive interrupts from external devices. Interrupts can only be configured for input pins.

Interrupt Types
^^^^^^^^^^^^^^^
The interrupt logic detects events based on the configured type for each pin:

- **Edge-triggered**: Detects rising or falling edges
- **Level-triggered**: Detects active-high or active-low levels

Interrupt Signal Behavior
^^^^^^^^^^^^^^^^^^^^^^^^^
When an event occurs on a pin configured for interrupts, the interrupt logic generates an output interrupt signal.  
This signal remains high for one clock cycle to indicate the event, after which it is cleared.  

The interrupt signal is captured by the APB Event Controller for further processing.  
Refer to the `APB Event Controller documentation <https://docs.openhwgroup.org/projects/core-v-mcu/doc-src/ip-blocks/apb_event_cntrl.html>`_ for more details.

Edge vs. Level-Triggered Interrupts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The main difference between edge-triggered and level-triggered interrupts lies in how they are generated and cleared:

- **Edge-triggered** interrupts are activated on signal transitions (rising or falling edges) and are automatically cleared after one clock cycle.
- **Level-triggered** interrupts remain active as long as the level condition (high or low) persists, to resolve this the GPIO module blocks the level-triggered interrupt signal after it is generated once and deasserts the output interrupt.

Hence, both edge-triggered and level-triggered interrupts are asserted for one clock cycle, but level-triggered interrupts require explicit acknowledgment to allow new interrupts to be generated.

Interrupt Acknowledgment
^^^^^^^^^^^^^^^^^^^^^^^^
To prevent repeated triggering from persistent level conditions, the APB GPIO disables the interrupt signal after it is generated once and deasserts the output interrupt.  
The APB master must acknowledge the interrupt by writing to the INTACK CSR.  

Once acknowledged, the GPIO can reassert the interrupt signal if the level condition still holds true.

Summary
^^^^^^^
- Both edge-triggered and level-triggered interrupts are signaled through the same interrupt pins.
- In both cases, the interrupt signal output from the GPIO remains high for only one clock cycle.
- For level-triggered interrupts, the APB master must acknowledge the interrupt via INTACK to allow new interrupts to be generated.
- Edge-triggered interrupts do not require explicit acknowledgment, as they are automatically cleared.


System Architecture
-------------------

The figure below depicts the connections between the GPIO and rest of the modules in CORE-V-MCU:-

.. figure:: apb_gpio_soc_connections.png
   :name: APB_GPIO_SoC_Connections
   :align: center
   :alt:

   APB GPIO CORE-V-MCU connections diagram

The gpio_in_sync output is directly connected to the Advanced Timer module.
It provides synchronized GPIO input signals that serve as external event sources for the Advanced Timer.
These signals are processed by the Advanced Timer logic and can ultimately control the up/down counter functionality.
This integration enables external events captured by GPIO pins to influence timer operations.

Programming View Model
----------------------
The APB GPIO IP follows a simple programming model:

GPIO Pin Configuration
~~~~~~~~~~~~~~~~~~~~~~
Each GPIO pin can be configured individually:
  - Configure the pin direction (input, output, or open-drain) using the SETDIR CSR
  - Configure interrupt behavior if necessary using the SETINT CSR

For details, please refer to the 'Firmware Guidelines'.

GPIO Pin Control
~~~~~~~~~~~~~~~~
To control GPIO pins:
  - Use SETGPIO to set a pin high
  - Use CLRGPIO to set a pin low
  - Use TOGGPIO to toggle a pin's state
  - Use OUTx CSRs to set multiple pins at once

For details, please refer to the 'Firmware Guidelines'.

GPIO Pin Status
~~~~~~~~~~~~~~~
To read GPIO pin status:
  - Use RDSTAT to read a selected pin's status
  - Use PINx CSRs to read the status of multiple pins at once

For details, please refer to the 'Firmware Guidelines'.

Interrupt Handling
~~~~~~~~~~~~~~~~~~
When an interrupt occurs:
  - Determine the source by reading pin status
  - Handle the interrupt according to application requirements
  - Acknowledge the interrupt using the INTACK CSR in case of level-triggered interrupts.

For details, please refer to the 'Firmware Guidelines'.

APB GPIO CSRs
-------------

The APB GPIO has a 4KB address space and the CSR interface designed using the APB protocol. There are multiple CSRs allowing the processor to read input GPIO pin states, set
output pin values, and configure various GPIO settings such as interrupt behavior, pin direction etc. The CSRs are designed for 128 GPIO pins, but the current implementation supports only 32 GPIO pins.

NOTE: Several of the Event Controller CSR are volatile, meaning that their read value may be changed by the hardware.
For example, the value of PIN0 CSR may change if the GPIO pin is configured as an input and the external signal changes.
However, the non-volatile CSRs, as the name suggests, will retain their value until explicitly changed by the software.

SETGPIO
~~~~~~~
  - Address Offset: 0x000
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| PIN_SELECT     | [6:0]        | WO       | 0x0         | GPIO pin to set high             |
+----------------+--------------+----------+-------------+----------------------------------+

CLRGPIO
~~~~~~~
  - Address Offset: 0x004
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| PIN_SELECT     | [6:0]        | WO       | 0x0         | GPIO pin to set low              |
+----------------+--------------+----------+-------------+----------------------------------+

TOGGPIO
~~~~~~~
  - Address Offset: 0x008
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| PIN_SELECT     | [6:0]        | WO       | 0x0         | GPIO pin to toggle               |
+----------------+--------------+----------+-------------+----------------------------------+

PIN0
~~~~
  - Address Offset: 0x010
  - Type: volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| GPIO_IN        | [31:0]       | RO       | 0x0         | Read status of GPIO pins 31:0    |
|                |              |          |             | if configured as input pins      |
+----------------+--------------+----------+-------------+----------------------------------+

PIN1
~~~~
  - Address Offset: 0x014
  - Type: volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| GPIO_IN        | [31:0]       | RO       | 0x0         | Read status of GPIO pins 63:32   |
|                |              |          |             | if configured as input pins      |
|                |              |          |             | (Not supported)                  |
+----------------+--------------+----------+-------------+----------------------------------+

PIN2
~~~~
  - Address Offset: 0x018
  - Type: volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| GPIO_IN        | [31:0]       | RO       | 0x0         | Read status of GPIO pins 95:64   |
|                |              |          |             | if configured as input pins      |
|                |              |          |             | (Not supported)                  |
+----------------+--------------+----------+-------------+----------------------------------+

PIN3
~~~~
  - Address Offset: 0x01C
  - Type: volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| GPIO_IN        | [31:0]       | RO       | 0x0         | Read status of GPIO pins 127:96  |
|                |              |          |             | if configured as input pins      |
|                |              |          |             | (Not supported)                  |
+----------------+--------------+----------+-------------+----------------------------------+

OUT0
~~~~
  - Address Offset: 0x020
  - Type: volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| GPIO_OUT       | [31:0]       | RW       | 0x0         | Read & set value of GPIO pins    |
|                |              |          |             | 31:0 if configured as output pins|
+----------------+--------------+----------+-------------+----------------------------------+

OUT1
~~~~
  - Address Offset: 0x024
  - Type: volatile

+----------------+--------------+----------+-------------+------------------------------------+
| Field          | Bits         | Access   | Default     | Description                        |
+================+==============+==========+=============+====================================+
| GPIO_OUT       | [31:0]       | RW       | 0x0         | Read & set value of GPIO pins      |
|                |              |          |             | 63:32 if configured as output pins |
|                |              |          |             | (Not supported)                    |
+----------------+--------------+----------+-------------+------------------------------------+

OUT2
~~~~
  - Address Offset: 0x028
  - Type: volatile

+----------------+--------------+----------+-------------+------------------------------------+
| Field          | Bits         | Access   | Default     | Description                        |
+================+==============+==========+=============+====================================+
| GPIO_OUT       | [31:0]       | RW       | 0x0         | Read & set value of GPIO pins      |
|                |              |          |             | 95:64 if configured as output pins |
|                |              |          |             | (Not supported)                    |
+----------------+--------------+----------+-------------+------------------------------------+

OUT3
~~~~
  - Address Offset: 0x02C

+----------------+--------------+----------+-------------+------------------------------------+
| Field          | Bits         | Access   | Default     | Description                        |
+================+==============+==========+=============+====================================+
| GPIO_OUT       | [31:0]       | RW       | 0x0         | Read & set value of GPIO pins      |
|                |              |          |             | 127:96 if configured as output pins|
|                |              |          |             | (Not supported)                    |
+----------------+--------------+----------+-------------+------------------------------------+

SETSEL
~~~~~~
  - Address Offset: 0x030
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| PIN_SELECT     | [6:0]        | WO       | 0x0         | GPIO pin number to select for    |
|                |              |          |             | reading pin using RDSTAT         |
+----------------+--------------+----------+-------------+----------------------------------+

RDSTAT
~~~~~~
  - Address Offset: 0x034
  - Type: volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| DIR            | [25:24]      | RO       | 0x0         | Direction configuration for      |
|                |              |          |             | selected pin                     |
+----------------+--------------+----------+-------------+----------------------------------+
| INT_TYPE       | [19:17]      | RO       | 0x0         | Interrupt type configuration for |
|                |              |          |             | selected pin                     |
+----------------+--------------+----------+-------------+----------------------------------+
| INT_EN         | [16]         | RO       | 0x0         | Interrupt enable status for      |
|                |              |          |             | selected pin                     |
+----------------+--------------+----------+-------------+----------------------------------+
| PIN_IN         | [12]         | RO       | 0x0         | Input value of selected pin      |
+----------------+--------------+----------+-------------+----------------------------------+
| PIN_OUT        | [8]          | RO       | 0x0         | Output value of selected pin     |
+----------------+--------------+----------+-------------+----------------------------------+
| PIN_SELECT     | [6:0]        | RO       | 0x0         | Currently selected pin number    |
+----------------+--------------+----------+-------------+----------------------------------+

SETDIR
~~~~~~
  - Address Offset: 0x038
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| DIR            | [25:24]      | WO       | 0x0         | Direction configuration:         |
|                |              |          |             |                                  |
|                |              |          |             | 00: Input                        |
|                |              |          |             |                                  |
|                |              |          |             | 01: Output                       |
|                |              |          |             |                                  |
|                |              |          |             | 11: Open-Drain                   |
+----------------+--------------+----------+-------------+----------------------------------+
| PIN_SELECT     | [6:0]        | WO       | 0x0         | GPIO pin number to configure     |
|                |              |          |             | direction                        |
+----------------+--------------+----------+-------------+----------------------------------+

SETINT
~~~~~~
  - Address Offset: 0x03C
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| INT_TYPE       | [19:17]      | WO       | 0x0         | Interrupt type:                  |
|                |              |          |             |                                  |
|                |              |          |             | 000: Active-Low level            |
|                |              |          |             |                                  |
|                |              |          |             | 001: Falling edge                |
|                |              |          |             |                                  |
|                |              |          |             | 010: Rising edge                 |
|                |              |          |             |                                  |
|                |              |          |             | 011: Both edges                  |
|                |              |          |             |                                  |
|                |              |          |             | 100: Active-High level           |
+----------------+--------------+----------+-------------+----------------------------------+
| INT_EN         | [16]         | WO       | 0x0         | Interrupt enable:                |
|                |              |          |             |                                  |
|                |              |          |             | 0: Disable                       |
|                |              |          |             |                                  |
|                |              |          |             | 1: Enable                        |
+----------------+--------------+----------+-------------+----------------------------------+
| PIN_SELECT     | [6:0]        | WO       | 0x0         | GPIO pin number to configure     |
|                |              |          |             | interrupt                        |
+----------------+--------------+----------+-------------+----------------------------------+

INTACK
~~~~~~
  - Address Offset: 0x040
  - Type: non-volatile

+----------------+--------------+----------+-------------+----------------------------------+
| Field          | Bits         | Access   | Default     | Description                      |
+================+==============+==========+=============+==================================+
| PIN_NUM        | [7:0]        | WO       | 0x0         | GPIO pin number to acknowledge   |
|                |              |          |             | interrupt                        |
+----------------+--------------+----------+-------------+----------------------------------+


Firmware Guidelines
-------------------

GPIO Pin Configuration Procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Configuring Pin Direction
^^^^^^^^^^^^^^^^^^^^^^^^^
Direction of a pin can be configured by writing to the SETDIR CSR (address 0x038).
  - To configure as input: Place a value of 0 in bits [25:24] along with the pin number in bits [6:0].
  - To configure as output: Place a value of 1 in bits [25:24] along with the pin number in bits [6:0].
  - To configure as open-drain: Place a value of 3 in bits [25:24] along with the pin number in bits [6:0].


Configuring Interrupt Behavior
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - Interrupts can only be configured for input pins.
  - If the input pin requires interrupt capability, write to the SETINT CSR (address 0x03C).
  - Include the pin number in bits [6:0].
  - To enable interrupts, set bit [16] to 1; to disable, set to 0.
  - To configure interrupt type, set bits [19:17] as follows:
      - 000: Active-Low level detection
      - 001: Falling edge detection
      - 010: Rising edge detection
      - 011: Both edges detection
      - 100: Active-High level detection

GPIO Status Reading Procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reading Individual Pin Status
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - First, select the desired pin by writing its number to SETSEL CSR(address 0x030).
  - Read the RDSTAT CSR (address 0x034).
  - Examine bit [12] for the current input state of the pin.
  - Examine bit [8] for the current output value.
  - Other fields provide configuration information:
        - Bits [25:24]: Direction configuration(input, output, or open-drain)
        - Bits [19:17]: Interrupt type(active-low, falling edge, rising edge, both edges, or active-high)
        - Bit [16]: Interrupt enable status
      
Reading Multiple Pin States
^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - To read the status of multiple pins at once, read the PIN0 CSR, in which each bit represents corresponding output pin.
  - A bit value of 1 indicates a high state, 0 indicates a low state.

GPIO Control Procedure
~~~~~~~~~~~~~~~~~~~~~~

Setting Individual Pins High
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - Write the pin number to the SETGPIO CSR (address 0x000).
  - This operation sets the specified pin to a high state.

Setting Individual Pins Low
^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - Write the pin number to the CLRGPIO CSR (address 0x004).
  - This operation sets the specified pin to a low state.

Toggling Individual Pins
^^^^^^^^^^^^^^^^^^^^^^^^
  - Write the pin number to the TOGGPIO CSR (address 0x008).
  - This inverts the current state of the specified pin.

Controlling Multiple Pins Simultaneously
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - To control multiple pins in one operation, write to the OUT0 CSR.
  - Each bit position corresponds to the respective pin number.
  - Setting a bit to 1 drives the corresponding pin high; setting to 0 drives it low.

Interrupt Handling Procedure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

Interrupt Processing
^^^^^^^^^^^^^^^^^^^^
  - When an interrupt occurs, the GPIO module asserts the corresponding interrupt signal.
  - Process the interrupt according to application requirements.
  - For level-sensitive interrupts, the interrupt needs to be acknowledged/unblocked before it can be reasserted.

Interrupt Acknowledgment
^^^^^^^^^^^^^^^^^^^^^^^^
  - To acknowledge the interrupt, write the pin number to the INTACK CSR (address 0x040).
  - This clears the interrupt signal for the specified pin, allowing it to be reasserted if the condition persists.
  - Note that this acknowledgment is only required for level-triggered interrupts.

Open-Drain Configuration Guidelines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Configuring Open-Drain Mode
^^^^^^^^^^^^^^^^^^^^^^^^^^^
  - Write to SETDIR with a value of 3 in bits [25:24], setting bit 24 makes the pin direction as output and setting bit 25 enables open drain configuration.
  - Include the pin number in bits [6:0].
  - The output value controls whether the pin drives low (output value = 0) or is in high-impedance state (output value = 1).

Using Open-Drain Pins
^^^^^^^^^^^^^^^^^^^^^
  - To drive the pin low: Use CLRGPIO or write a 0 to the corresponding bit in OUT0.
  - To place the pin in high-impedance state: Use SETGPIO or write a 1 to the corresponding bit in OUT0.
  - Ensure an external pull-up resistor is connected to the pin to achieve a high state when not driven low.

Pin Diagram
-----------

The figure below represents the input and output pins for the APB GPIO:-

.. figure:: apb_gpio_pin_diagram.png
   :name: APB_GPIO_Pin_Diagram
   :align: center
   :alt:

   APB GPIO Pin Diagram

Clock and Reset
~~~~~~~~~~~~~~~

- HCLK: System clock input; provided by APB FLL.
- HRESETn: Active-low reset signal for initializing all internal CSRs and logic.
- dft_cg_enable_i: Clock gating enable input for DFT or low-power scenarios; Always 0 in the current implementation.

APB Interface Signals
~~~~~~~~~~~~~~~~~~~~~

- PADDR[11:0]: APB address bus input
- PWDATA[31:0]:  APB write data bus input
- PWRITE: APB write control input (high for write, low for read)
- PSEL: APB peripheral select input
- PENABLE: APB enable input
- PRDATA: APB write data bus input
- PREADY: APB ready output to indicate transfer completion
- PSLVERR: APB error response output signal

GPIO Data Signals
~~~~~~~~~~~~~~~~~
- gpio_in[31:0]: External GPIO input values from the physical pins; provided by external devices.
- gpio_in_sync[31:0]: Synchronized version of `gpio_in`, provides the external signals to Advanced timer block.
- gpio_out[31:0]: Output values driven onto physical GPIO pins, if pin is configured as outputs; provided to external devices.
- gpio_dir[31:0]: Direction control per pin; 1 = output, 0 = input (or high-impedance for open-drain); provided to external devices.

Interrupt Signals
~~~~~~~~~~~~~~~~~
- interrupt[31:0]: Per-pin interrupt outputs, asserted based on edge or level-triggered conditions; provided to APB Event Controller.

