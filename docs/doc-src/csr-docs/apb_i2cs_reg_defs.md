# APB_I2CS

Memory address: I2CS_START_ADDR(0x1A107000)

### I2CS_DEV_ADDRESS offset = 0x000

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:7 |    RW |            | Reserved        |
| SLAVE_ADDR |   6:0 |    RW |       0x6F | I2C Device Address |

### I2CS_ENABLE offset = 0x004

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:1 |    RW |            |                 |
| IP_ENABLE  |   0:0 |    RW |            |                 |

### I2CS_DEBOUNCE_LENGTH offset = 0x008

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| DEB_LEN    |   7:0 |    RW |       0x14 |                 |

### I2CS_SCL_DELAY_LENGTH offset = 0x00C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SCL_DLY_LEN |   7:0 |    RW |       0x14 |                 |

### I2CS_SDA_DELAY_LENGTH offset = 0x010

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| SDA_DLY_LEN |   7:0 |    RW |       0x14 |                 |

### I2CS_MSG_I2C_APB offset = 0x040

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| I2C_TO_APB |   7:0 |    RW |       0x00 |                 |

### I2CS_MSG_I2C_APB_STATUS offset = 0x044

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:1 |    RW |            | Reserved        |
| I2C_TO_APB_STATUS |   0:0 |    RW |       0x00 |                 |

### I2CS_MSG_APB_I2C offset = 0x048

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| APB_TO_I2C |   7:0 |    RW |       0x00 |                 |

### I2CS_MSG_APB_I2C_STATUS offset = 0x04C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:1 |    RW |            | Reserved        |
| APB_TO_I2C_STATUS |   0:0 |    RW |       0x00 |                 |

### I2CS_FIFO_I2C_APB_WRITE_DATA_PORT offset = 0x080

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| I2C_APB_WRITE_DATA_PORT |  31:0 |    RW |            |                 |

### I2CS_FIFO_I2C_APB_READ_DATA_PORT offset = 0x084

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| I2C_APB_READ_DATA_PORT |  31:0 |    RW |            |                 |

### I2CS_FIFO_I2C_APB_FLUSH offset = 0x088

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:1 |    RW |            | Reserved        |
| ENABLE     |   0:0 |    RW |            | Writing a 1 to this register bit will flush the I2CtoAPB FIFO, clearing all contents and rendering the FIFO to be empty |

### I2CS_FIFO_I2C_APB_WRITE_FLAGS offset = 0x08C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |    RW |            | Reserved        |
| FLAGS      |   2:0 |    RW |            |                 |

### I2CS_FIFO_I2C_APB_READ_FLAGS offset = 0x090

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |    RW |            | Reserved        |
| FLAGS      |   2:0 |    RW |            |                 |

### I2CS_FIFO_APB_I2C_WRITE_DATA_PORT offset = 0x0C0

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| I2C_APB_WRITE_DATA_PORT |  31:0 |    RW |            |                 |

### I2CS_FIFO_APB_I2C_READ_DATA_PORT offset = 0x0C4

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| I2C_APB_READ_DATA_PORT |  31:0 |    RW |            |                 |

### I2CS_FIFO_APB_I2C_FLUSH offset = 0x0C8

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:1 |    RW |            | Reserved        |
| ENABLE     |   0:0 |    RW |            | Writing a 1 to this register bit will flush the APBtoI2C FIFO, clearing all contents and rendering the FIFO to be empty |

### I2CS_FIFO_APB_I2C_WRITE_FLAGS offset = 0x0CC

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |     R |            | Reserved        |
| FLAGS      |   2:0 |     R |            |                 |

### I2CS_FIFO_APB_I2C_READ_FLAGS offset = 0x0D0

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |     R |            | Reserved        |
| FLAGS      |   2:0 |     R |            |                 |

### I2CS_INTERRUPT_STATUS offset = 0x100

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |     R |            | Reserved        |
| I2C_APB_FIFO_WRITE_STATUS |   2:2 |     R |            |                 |
| APB_I2C_FIFO_READ_STATUS |   1:1 |     R |            |                 |
| APB_I2C_MESSAGE_AVAILABLE |   0:0 |     R |            |                 |

### I2CS_INTERRUPT_ENABLE offset = 0x104

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |    RW |            | Reserved        |
| I2C_APB_FIFO_WRITE_STATUS_INT_ENABLE |   2:2 |    RW |            |                 |
| APB_I2C_FIFO_READ_STATUS_INT_ENABLE |   1:1 |    RW |            |                 |
| APB_I2C_MESSAGE_AVAILABLE_INT_ENABLE |   0:0 |    RW |            |                 |

### I2CS_INTERRUPT_I2C_APB_WRITE_FLAGS_SELECT offset = 0x108

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| WRITE_FLAG_FULL |   7:7 |    RW |            |                 |
| WRITE_FLAG_1_SPACE_AVAIL |   6:6 |    RW |            |                 |
| WRITE_FLAG_2_3_SPACE_AVAIL |   5:5 |    RW |            |                 |
| WRITE_FLAG_4_7_SPACE_AVAIL |   4:4 |    RW |            |                 |
| WRITE_FLAG_8_31_SPACE_AVAIL |   3:3 |    RW |            |                 |
| WRITE_FLAG_32_63_SPACE_AVAIL |   2:2 |    RW |            |                 |
| WRITE_FLAG_64_127_SPACE_AVAIL |   1:1 |    RW |            |                 |
| WRITE_FLAG_128_SPACE_AVAIL |   0:0 |    RW |            |                 |

### I2CS_INTERRUPT_APB_I2C_READ_FLAGS_SELECT offset = 0x10C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| READ_FLAG_128_SPACE_AVAIL |   7:7 |    RW |            |                 |
| READ_FLAG_64_127_SPACE_AVAIL |   6:6 |    RW |            |                 |
| READ_FLAG_32_63_SPACE_AVAIL |   5:5 |    RW |            |                 |
| READ_FLAG_8_31_SPACE_AVAIL |   4:4 |    RW |            |                 |
| READ_FLAG_4_7_SPACE_AVAIL |   3:3 |    RW |            |                 |
| READ_FLAG_2_3_SPACE_AVAIL |   2:2 |    RW |            |                 |
| READ_FLAG_1_SPACE_AVAIL |   1:1 |    RW |            |                 |
| READ_FLAG_EMPTY |   0:0 |    RW |            |                 |

### I2CS_INTERRUPT_TO_APB_STATUS offset = 0x140

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |    RW |            |                 |
| APB_I2C_FIFO_WRITE_STATUS |   2:2 |    RW |            |                 |
| I2C_APB_FIFO_READ_STATUS |   1:1 |    RW |            |                 |
| NEW_I2C_APB_MSG_AVAIL |   0:0 |    RW |            |                 |

### I2CS_INTERRUPT_TO_APB_ENABLE offset = 0x144

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |   7:3 |    RW |            |                 |
| APB_I2C_FIFO_WRITE_STATUS_ENABLE |   2:2 |    RW |            |                 |
| I2C_APB_FIFO_READ_STATUS_ENABLE |   1:1 |    RW |            |                 |
| NEW_I2C_APB_MSG_AVAIL_ENABLE |   0:0 |    RW |            |                 |

### I2CS_INTERRUPT_APB_I2C_WRITE_FLAGS_SELECT offset = 0x148

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| WRITE_FLAG_FULL |   7:7 |    RW |            |                 |
| WRITE_FLAG_1_SPACE_AVAIL |   6:6 |    RW |            |                 |
| WRITE_FLAG_2_3_SPACE_AVAIL |   5:5 |    RW |            |                 |
| WRITE_FLAG_4_7_SPACE_AVAIL |   4:4 |    RW |            |                 |
| WRITE_FLAG_8_31_SPACE_AVAIL |   3:3 |    RW |            |                 |
| WRITE_FLAG_32_63_SPACE_AVAIL |   2:2 |    RW |            |                 |
| WRITE_FLAG_64_127_SPACE_AVAIL |   1:1 |    RW |            |                 |
| WRITE_FLAG_128_SPACE_AVAIL |   0:0 |    RW |            |                 |

### I2CS_INTERRUPT_I2C_APB_READ_FLAGS_SELECT offset = 0x14C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| READ_FLAG_128_SPACE_AVAIL |   7:7 |    RW |            |                 |
| READ_FLAG_64_127_SPACE_AVAIL |   6:6 |    RW |            |                 |
| READ_FLAG_32_63_SPACE_AVAIL |   5:5 |    RW |            |                 |
| READ_FLAG_8_31_SPACE_AVAIL |   4:4 |    RW |            |                 |
| READ_FLAG_4_7_SPACE_AVAIL |   3:3 |    RW |            |                 |
| READ_FLAG_2_3_SPACE_AVAIL |   2:2 |    RW |            |                 |
| READ_FLAG_1_SPACE_AVAIL |   1:1 |    RW |            |                 |
| READ_FLAG_EMPTY |   0:0 |    RW |            |                 |

