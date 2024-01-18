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
.. _apb_timer:

**APB Timer**
=============

APB Timer supports two 32 bit individual timers with separate interrupt
lines. APB Timer can also be configured as a 64 bit timer.

**Features**

-  Multiple trigger input sources

-  Configurable 32 bit or 64 bit timer

-  Two 32 bit configurable prescaler

-  Configurable input trigger modes

-  Configurable clock gating for each timer

**Theory of Operation**
-----------------------

Block Diagram of APB_Timer:

.. image:: apb_timer_image.png
   :width: 5in
   :height: 2.38889in

| APB_Timer can be configured in various modes like 32 bit mode or 64 bit mode.

**32 bit mode timer:**

-  It supports 32 bit timer_low and 32 bit timer_high and they can be configured parallelly at the same time.

-  timer low which has a 32 bit prescaler and 32 bit counter which will have unique input_lo and output_lo pins.

-  timer high which has a 32 bit prescaler and 32 bit counter which will have unique input_hi and output_hi pins.

**64 bit mode timer:**

-  It supports a single 64 bit timer.

-  the 64 bit timer has a 32 bit prescaler and 64 bit counter. The FW has to drive both the high and low input pins

-  The output will be driven in the low pin for 64 bit mode.

Assuming there is no initial count configured for the counter, basic
operations of the timer are explained. The following four combinations
can be run in both 32 bit mode and 64 bit mode.

**Timer operation with both Prescaler and ref_clk disabled:**

-  Timer module directly enables the counter to start incrementing the count for every positive edge of Hclk clock from '0' till it reaches the compare value. When the count reaches the target compare value the timer value drives the output interrupt pins if its enabled.

**Timer operation with Prescaler disabled and ref_clk enabled:**

-  Timer modules wait until the reference clock's edge is detected and then enable the counter to start incrementing the count for every positive edge of the reference clock from '0' till it reaches the compare value. When the count reaches the target compare value the timer value drives the output interrupt pins if its enabled.

**Timer operation with Prescaler enabled and ref_clk disabled:**

-  Timer module will enable the prescaler and counter in the cascaded manner that is once the prescaler target is achieved the counter will start. The prescaler will be configured and once the target compare value of the prescaler is reached then the counter will start incrementing the count for every positive edge of Hclk clock from '0' till it reaches the compare value. When the count reaches the target compare value the timer value drives the output interrupt pins if its enabled.

**Timer operation with Prescaler enabled and ref_clk enabled:**

-  Timer will enable the prescaler and counter in the cascaded manner that is once the prescaler target is achieved and reference clock's edge is detected the counter will start. The prescaler will be configured and once the target compare value of the prescaler is reached then the counter will start incrementing the count for every positive edge of the reference clock from '0' till it reaches the compare value. When the count reaches the target compare value the timer value drives the output interrupt pins if its enabled.

**Programming Model**
---------------------

**Various modes supported by the APB_TIMER:**

-  One shot mode:

   In this mode, the timer will be disabled completely as soon as the
   timer count reaches the target count for the first time.

-  Compare clear mode:

   In this mode, the timer will still be enabled but the timer count
   will be reset to '0' as soon as the timer count reaches the target
   compare count. So that if all the other input configurations are
   valid then interrupt will be driven as many times the count reaches
   the target compare count

**Various features enabled in the APB_TIMER:**

-  Mode selection of 32 bit or 64 bit counters by configuring the MODE_64_BIT in CFG_REG_LO or CFG_REG_HI register.

-  Reset the counter value by configuring the RESET_BIT in CFG_REG_LO or CFG_REG_HI register.

-  Enable or disable the ref_clk by configuring the REF_CLK_EN_BIT in CFG_REG_LO or CFG_REG_HI register.

-  Enable or disable the prescaler by configuring the PRESCALER_BIT in CFG_REG_LO or CFG_REG_HI register.

-  Enable or disable the counter to start the counting by configuring the ENABLE_BIT in CFG_REG_LO or CFG_REG_HI register.

-  Configure the Mode_mtime bit so that in the 64 bit mode even if the IRQ_bit is not set an interrupt is being driven when the count == compare_value. Configure the MODE_MTIME_BIT in CFG_REG_LO or CFG_REG_HI register.

-  Stoptimer_i pin is used to stop the counter operation of the timer module directly.

-  busy_o pin is used to provide will be driven high if anyone of the counter is enabled.

-  Overwriting the counter value directly via the by configuring the TIMER_VAL_LO or TIMER_VAL_HI register.

-  Initial counter value can be configured to start the timer counter value by configuring the TIMER_VAL_LO or TIMER_VAL_HI register

**APB Timer CSRs**
------------------

**FG_REG_LO offset = 0x000**

+-------------+-------+------+---------+-------------------------------------+
|   Field     | Bits  | Type | Default |            Description              |
+=============+=======+======+=========+=====================================+
| MODE_64_BIT | 31:31 |  RW  |         | 1 = 64-bit mode, 0=32-bit mode      |
+-------------+-------+------+---------+-------------------------------------+
| MOD         | 30:30 |  RW  |         | 1=MTIME mode Changes interrupt to   |
| E_MTIME_BIT |       |      |         | be >= CMP value                     |
+-------------+-------+------+---------+-------------------------------------+
| PRES        | 15:8  |  RW  |         | Prescaler divisor                   |
| CALER_COUNT |       |      |         |                                     |
+-------------+-------+------+---------+-------------------------------------+
| REF         |  7:7  |  RW  |         | 1= use Refclk for counter,          |
| _CLK_EN_BIT |       |      |         | 0 = use APB bus clk for counter     |
+-------------+-------+------+---------+-------------------------------------+
| PRESC       |  6:6  |  RW  |         | 1= Use prescaler                    |
| ALER_EN_BIT |       |      |         | 0= no prescaler                     |
+-------------+-------+------+---------+-------------------------------------+
| O           |  5:5  |  RW  |         | 1= disable timer when counter ==    |
| NE_SHOT_BIT |       |      |         | cmp value                           |
+-------------+-------+------+---------+-------------------------------------+
| CMP_CLR_BIT |  4:4  |  RW  |         | 1=counter is reset once             |
|             |       |      |         | counter == cmp,                     |
|             |       |      |         | 0=counter is not reset              |
+-------------+-------+------+---------+-------------------------------------+
| IEM_BIT     |  3:3  |  RW  |         | 1 = event input is enabled          |
+-------------+-------+------+---------+-------------------------------------+
| IRQ_BIT     |  2:2  |  RW  |         | 1 = IRQ is enabled when counter     |
|             |       |      |         | ==cmp value                         |
+-------------+-------+------+---------+-------------------------------------+
| RESET_BIT   |  1:1  |  RW  |         | 1 = reset the counter               |
+-------------+-------+------+---------+-------------------------------------+
| ENABLE_BIT  |  0:0  |  RW  |         | 1 = enable the counter to count     |
+-------------+-------+------+---------+-------------------------------------+

**CFG_REG_HI offset = 0x004**

+------------------+-------+------+---------+--------------------------------+
|     Field        | Bits  | Type | Default |         Description            |
+==================+=======+======+=========+================================+
| MODE_64_BIT      | 31:31 |  RW  |         | 1 = 64-bit mode, 0=32-bit mode |
+------------------+-------+------+---------+--------------------------------+
| MODE_MTIME_BIT   | 30:30 |  RW  |         | 1=MTIME mode Changes interrupt |
|                  |       |      |         | to be >= CMP value             |
+------------------+-------+------+---------+--------------------------------+
| PRESCALER_COUNT  | 15:8  |  RW  |         | Prescaler divisor              |
+------------------+-------+------+---------+--------------------------------+
| REF_CLK_EN_BIT   |  7:7  |  RW  |         | 1= use Refclk for counter,     |
|                  |       |      |         | 0 = use APB bus clk for counter|
+------------------+-------+------+---------+--------------------------------+
| PRESCALER_EN_BIT |  6:6  |  RW  |         | 1= Use prescaler               |
|                  |       |      |         | 0= no prescaler                |
+------------------+-------+------+---------+--------------------------------+
| ONE_SHOT_BIT     |  5:5  |  RW  |         | 1= disable timer when          |
|                  |       |      |         | counter == cmp value           |
+------------------+-------+------+---------+--------------------------------+
| CMP_CLR_BIT      |  4:4  |  RW  |         | 1=counter is reset once        |
|                  |       |      |         | counter == cmp,                |
|                  |       |      |         | 0=counter is not reset         |
+------------------+-------+------+---------+--------------------------------+
| IEM_BIT          |  3:3  |  RW  |         | 1 = event input is enabled     |
+------------------+-------+------+---------+--------------------------------+
| IRQ_BIT          |  2:2  |  RW  |         | 1 = IRQ is enabled when        |
|                  |       |      |         | counter ==cmp value            |
+------------------+-------+------+---------+--------------------------------+
| RESET_BIT        |  1:1  |  RW  |         | 1 = reset the counter          |
+------------------+-------+------+---------+--------------------------------+
| ENABLE_BIT       |  0:0  |  RW  |         | 1 = enable the counter to count|
+------------------+-------+------+---------+--------------------------------+

**TIMER_VAL_LO offset = 0x008**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_VAL_LO    | 31:0 |  RW  |   0x0   | 32-bit counter value - low  |
|                 |      |      |         | 32-bits in 64-bit mode      |
+-----------------+------+------+---------+-----------------------------+

**TIMER_VAL_HI offset = 0x00C**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_VAL_HI    | 31:0 |  RW  |   0x0   | 32-bit counter value - high |
|                 |      |      |         | 32-bits in 64-bit mode      |
+-----------------+------+------+---------+-----------------------------+

**TIMER_CMP_LO offset = 0x010**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_CMP_LO    | 31:0 |  RW  |   0x0   | compare value for low       |
|                 |      |      |         | 32-bit counter              |
+-----------------+------+------+---------+-----------------------------+

**TIMER_CMP_HI offset = 0x014**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_CMP_HI    | 31:0 |  RW  |   0x0   | compare value for high      |
|                 |      |      |         | 32-bit counter              |
+-----------------+------+------+---------+-----------------------------+

**TIMER_START_LO offset = 0x018**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_START_LO  | 31:0 |  WS  |   0x0   | Write strobe address for    |
|                 |      |      |         | starting low counter        |
+-----------------+------+------+---------+-----------------------------+

**TIMER_START_HI offset = 0x01C**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_START_HI  | 31:0 |  WS  |   0x0   | Write strobe address for    |
|                 |      |      |         | starting high counter       |
+-----------------+------+------+---------+-----------------------------+

**TIMER_RESET_LO offset = 0x020**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_START_LO  | 31:0 |  WS  |   0x0   | Write strobe address for    |
|                 |      |      |         | resetting the low counter   |
+-----------------+------+------+---------+-----------------------------+

**TIMER_RESET_HI offset = 0x024**

+-----------------+------+------+---------+-----------------------------+
|     Field       | Bits | Type | Default |        Description          |
+=================+======+======+=========+=============================+
| TIMER_START_HI  | 31:0 |  WS  |   0x0   | Write strobe address for    |
|                 |      |      |         | resetting the high counter  |
+-----------------+------+------+---------+-----------------------------+
