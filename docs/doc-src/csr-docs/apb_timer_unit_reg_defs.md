# APB_TIMER_UNIT

Memory address: TIMER_START_ADDDR(0x1A10B000)

### CFG_REG_LO offset = 0x000

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| MODE_64_BIT | 31:31 |    RW |            | 1 = 64-bit mode, 0=32-bit mode |
| MODE_MTIME_BIT | 30:30 |    RW |            | 1=MTIME mode Changes interrupt to be >= CMP value |
| PRESCALER_COUNT |  15:8 |    RW |            | Prescaler divisor |
| REF_CLK_EN_BIT |   7:7 |    RW |            | 1= use Refclk for counter, 0 = use APB bus clk for counter |
| PRESCALER_EN_BIT |   6:6 |    RW |            | 1= Use prescaler 0= no prescaler |
| ONE_SHOT_BIT |   5:5 |    RW |            | 1= disable timer when counter == cmp value |
| CMP_CLR_BIT |   4:4 |    RW |            | 1=counter is reset once counter == cmp,  0=counter is not reset  |
| IEM_BIT    |   3:3 |    RW |            | 1 = event input is enabled |
| IRQ_BIT    |   2:2 |    RW |            | 1 = IRQ is enabled when counter ==cmp value  |
| RESET_BIT  |   1:1 |    RW |            | 1 = reset the counter |
| ENABLE_BIT |   0:0 |    RW |            | 1 = enable the counter to count |

### CFG_REG_HI offset = 0x004

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| MODE_64_BIT | 31:31 |    RW |            |                 |
| MODE_MTIME_BIT | 30:30 |    RW |            |                 |
| PRESCALER_COUNT |  15:8 |    RW |            |                 |
| REF_CLK_EN_BIT |   7:7 |    RW |            |                 |
| PRESCALER_EN_BIT |   6:6 |    RW |            |                 |
| ONE_SHOT_BIT |   5:5 |    RW |            |                 |
| CMP_CLR_BIT |   4:4 |    RW |            |                 |
| IEM_BIT    |   3:3 |    RW |            |                 |
| IRQ_BIT    |   2:2 |    RW |            |                 |
| RESET_BIT  |   1:1 |    RW |            |                 |
| ENABLE_BIT |   0:0 |    RW |            |                 |

### TIMER_VAL_LO offset = 0x008

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_VAL_LO |  31:0 |    RW |        0x0 |                 |

### TIMER_VAL_HI offset = 0x00C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_VAL_HI |  31:0 |    RW |        0x0 |                 |

### TIMER_CMP_LO offset = 0x010

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_CMP_LO |  31:0 |    RW |        0x0 |                 |

### TIMER_CMP_HI offset = 0x014

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_CMP_HI |  31:0 |    RW |        0x0 |                 |

### TIMER_START_LO offset = 0x018

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_START_LO |   0:0 |    WS |        0x0 |                 |

### TIMER_START_HI offset = 0x01C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_START_HI |   0:0 |    WS |        0x0 |                 |

### TIMER_RESET_LO offset = 0x020

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_RESET_LO |   0:0 |    WS |        0x0 |                 |

### TIMER_RESET_HI offset = 0x024

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| TIMER_RESET_HI |   0:0 |    WS |        0x0 |                 |

