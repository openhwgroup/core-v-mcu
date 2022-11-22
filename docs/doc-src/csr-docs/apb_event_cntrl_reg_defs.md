# APB_EVENT_CNTRL

Memory address: SOC_EVENT_GEN_START_ADDR(`SOC_EVENT_START_ADDR)

This APB peripheral device collects all the events which presented
to the CPU as IRQ11 (Machine interrupt).
Each event is individually maskable by the appropriate bit in the
EVENT_MASKx register.
When an enabled event (unmasked) is received it is placed in a event FIFO
and the IRQ11 signal is presented to the CPU which can then read
the EVENT FIFO to determine which event cause the interrupt.
each event has a queue of depth four to collect events if the 
queue for any event overflows an error is logged into the appropriate
EVENT_ERR register  and IRQ31 is presented to the CPU. 

### APB_EVENTS offset = 0x000

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| apb_event  |  15:0 |       |            | 16-bits of software generated events |

### EVENT_MASK0 offset = 0x004

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 0 - 31 1=mask event |

### EVENT_MASK1 offset = 0x008

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |       |            | individual masks for events 32 - 63 1=mask event |

### EVENT_MASK2 offset = 0x00C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 64 - 95 1=mask event |

### EVENT_MASK3 offset = 0x010

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 96 - 127 1=mask event |

### EVENT_MASK4 offset = 0x014

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 128 - 159 1=mask event |

### EVENT_MASK5 offset = 0x018

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 160 - 191 1=mask event |

### EVENT_MASK6 offset = 0x01C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 192 - 223 1=mask event |

### EVENT_MASK7 offset = 0x020

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 | 0xFFFFFFFF |            | individual masks for events 224 - 255 1=mask event |

### EVENT_ERR0 offset = 0x064

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_err  | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 0 - 31 |

### EVENT_ERR1 offset = 0x068

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 32 - 63 |

### EVENT_ERR2 offset = 0x06C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 64 - 95 |

### EVENT_ERR3 offset = 0x070

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 96 - 127 |

### EVENT_ERR4 offset = 0x074

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 128 - 159 |

### EVENT_ERR5 offset = 0x078

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 160 - 191 |

### EVENT_ERR6 offset = 0x07C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 192 - 223 |

### EVENT_ERR7 offset = 0x080

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event_enable | 31:30 |   0x0 |            | individual error bits to indicate event queue overflow for events 224 - 255 |

### TIMER_LO_EVENT offset = 0x0084

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event      |   7:0 |       | specifies which event should be routed to the lo timer |                 |

### TIMER_HI_EVENT offset = 0x0088

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| event      |   7:0 |       | specifies which event should be routed to the hi timer |                 |

### EVENT_FIFO offset = 0x090

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| EVENT_ID   |   7:0 |    RO |            | ID of triggering event to be read by interrupt handler |

