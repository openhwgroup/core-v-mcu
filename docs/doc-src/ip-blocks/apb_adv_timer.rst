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

.. _apb_advanced_timer:

APB Advanced Timer
==================
The Advanced Timer support four programable timers called "channels".
A typical use of the Advanced Timer is PWM generation.

Features
--------
- multiple trigger input sources:
   - output signal channels of all timers
   - 32 GPIOs
   - reference clock at 32kHz
   - FLL clock
- configurable input trigger modes
- configurable prescaler for each timer
- configurable counting mode for each timer
- configurable channel threshold action for each timer
- four configurable output events
- configurable clock gating of each timer

Theory of Operation
-------------------

Programming Model
------------------

APB Advanced Timers CSRs
------------------------

TBD offset = 0x00
~~~~~~~~~~~~~~~~~

+------------+-------+------+------------+-------------------------------------------------------------+
| Field      |  Bits | Type | Default    | Description                                                 |
+============+=======+======+============+=============================================================+
| TBD        |  31:0 |   RW |            | To Be Determined                                            |
+------------+-------+------+------------+-------------------------------------------------------------+


