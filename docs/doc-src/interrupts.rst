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

.. _interrupts:

Interrupt Strategy
==================

The ``core_v_mcu`` supports a 2-level interrupt strategy to interact with the ``cv32e40p`` core.

The ``cv32e40p`` can receive up to 19 events, namely the 3 CLINT machine-interrupts (so called software, timer, and external),
and 16 custom events called fast-interrupts. See [here](https://docs.openhwgroup.org/projects/cv32e40p-user-manual/en/cv32e40p_v1.0.0_doc/exceptions_interrupts.html) for the core specific documentation.

The 19 interrupts are generated when the raising-edge of the related event gets triggered, expect for the event `11`, which instead is level-sensitive, and the priority is defined in the CPU as described in the link
provided above.

Following the list of such events is presented.

First Level Interrupts Map
--------------------------

`3`: CLINT Software Event
`7`: CLINT Timer Event
`11`: CLINT External Event
`16`: CUSTOM FAST Timer_LO Event
`17`: CUSTOM FAST Timer HI Event
`18`: CUSTOM FAST Reference Clock Rise Event
`19`: CUSTOM FAST Reference Clock Fall Event
`20`: CUSTOM FAST I2C Event
`21`: CUSTOM FAST Advanced-Timer Events0
`22`: CUSTOM FAST Advanced-Timer Events1
`23`: CUSTOM FAST Advanced-Timer Events2
`24`: CUSTOM FAST Advanced-Timer Events3
`25`: CUSTOM FAST eFPGA Events0
`26`: CUSTOM FAST eFPGA Events1
`27`: CUSTOM FAST eFPGA Events2
`28`: CUSTOM FAST eFPGA Events3
`29`: CUSTOM FAST eFPGA Events4
`30`: CUSTOM FAST eFPGA Events5
`31`: CUSTOM FAST Error Event

Please refer to the specific module's documentation for detailed description of the conditions that trigger such events.

The `11` CLINT External Event is a special Event that gathers all the platform-specific events, which will be too many to plug directly to the CPU.
The `11` CLINT External Event represents the 2nd level of the interrupt strategy, as the CPU first responds to the Event `11` jumping to its interrupt-service-routine,
then it reades the `event generator` memory to discover which platform specific event triggered the CPU.
The platform-specific events are organized in a First-In-First-Out strategy before triggering the External Event.

Following the coarse-grain Map of the platform-specific events is listed.

Platform-Specific (Second Level) Interrupts Map
-----------------------------------------------

There are 84 events reserved for the peripheral-domain, 8 events that can be triggered in software by writing to the `REG_EVENT` of the event generator (so called APB Software Events),
and 1 event coming from the rising edge of the reference clock, for a total of 93 events mapped from 0 to 168 (with some lines reserved for future use).
If one of them 'triggers', and if it is 'enabled' in the even generator (and specific peripheral), then the event CLINT Extenral Event triggers.


`0-3`: UART-0 Events
`4-7`: UART-1 Events
`8-11`: QSPI-0 Events
`12-15`: QSPI-1 Events
`16-19`: I2C-0 Events
`20-23`: I2C-1 Events
`24-27`: SDIO Events
`28-31`: Camera Events
`32-35`: Filter Events
`36-111`: RESERVED
`112-127`: eFPGA Events
`128-159`: GPIO Events
`160-167`: APB Software Events
`168`: Reference Clock Rise Event












