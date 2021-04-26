# APB_INTERRUPT_CNTRL

Memory address: EU_START_ADDR(0x1A109000)

### REG_MASK offset = 0x000

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_MASK_SET offset = 0x004

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_MASK_CLEAR offset = 0x008

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_INT offset = 0x00C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_INT_SET offset = 0x010

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_INT_CLEAR offset = 0x014

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_ACK offset = 0x018

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_ACK_SET offset = 0x01C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_ACK_CLEAR offset = 0x020

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fc_hp_events | 31:30 |       |            |                 |
| fc_err_events | 29:29 |       |            |                 |
| unused1    | 28:24 |       |       0x00 |                 |
| ref_change_event | 23:23 |       |            | ref_rise or ref_fall |
| adv_timer_evens | 22:19 |       |            |                 |
| gpio_event | 18:18 |       |            |                 |
| timer_hi_event | 17:17 |       |            |                 |
| timer_lo_event | 16:16 |       |            |                 |
| unused2    |  15:8 |       |       0x00 |                 |
| timer_lo_event |   7:7 |       |            | MTIME irq       |
| reserved   |   6:0 |       |            | Reserved for s/w events routed to irq3? |

### REG_FIFO offset = 0x024

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| EVENT_ID   |   7:0 |    RO |            | ID of triggering event |

### Notes:

| Access type | Description |
| ----------- | ----------- |
| RW          | Read & Write |
| RO          | Read Only    |
| RC          | Read & Clear after read |
| WO          | Write Only |
| WS          | Write Sets (value ignored; always writes a 1) |
| RW1S        | Read & on Write bits with 1 get set, bits with 0 left unchanged |
| RW1C        | Read & on Write bits with 1 get cleared, bits with 0 left unchanged |
| RW0C        | Read & on Write bits with 0 get cleared, bits with 1 left unchanged |
