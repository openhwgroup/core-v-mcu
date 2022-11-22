# APB_GPIO

Memory address: GPIO_START_ADDR(0x1A101000)

The GPIO module supports S/W access to read and write the values on selected I/O,
and configuring selected I/O to generate interrupts.

Interrupts

Any GPIO can be configured for level type interrupts or edge triggered interrupts.
Levels based int


### SETGPIO offset = 0x00

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_num   |   7:0 |    WO |            | Set GPIO[gpio_num] = 1 |

### CLRGPIO offset = 0x04

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_num   |   7:0 |    WO |            | Set GPIO[gpio_num] = 0 |

### TOGGPIO offset = 0x08

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_num   |   7:0 |    WO |            | Invert the output of GPIO[gpio_num] |

### PIN0 offset = 0x10

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_value |  31:0 |    RO |            | gpio_value[31:0] = GPIO[31:0] |

### PIN1 offset = 0x14

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_value |  31:0 |    RO |            | gpio_value[31:0] = GPIO[63:32] |

### PIN2 offset = 0x18

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_value |  31:0 |    RO |            | gpio_value[31:0] = GPIO[95:64] |

### PIN3 offset = 0x1C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_value |  31:0 |    RO |            | gpio_value[31:0] = GPIO[127:96] |

### OUT0 offset = 0x20

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| value      |  31:0 |    WO |            | Drive value[31:0] onto GPIO[31:0] |

### OUT1 offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| value      |  31:0 |    WO |            | Drive value[31:0] onto GPIO[63:32] |

### OUT2 offset = 0x28

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| value      |  31:0 |    WO |            | Drive value[31:0] onto GPIO[95:64] |

### OUT3 offset = 0x2C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| value      |  31:0 |    WO |            | Drive value[31:0] onto GPIO[127:96] |

### SETSEL offset = 0x30

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| gpio_num   |   7:0 |    WO |        0x0 | Set gpio_num for use by RDSTAT |
|            |       |       |            | Note: SETGPIO, CLRGPIO, TOGGPIO and SETINT set gpio_num |

### RDSTAT offset = 0x34

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| mode       | 25:24 |    RO |        0x0 | Read the mode control for GPIO[gpio_num] (set gpio_num using SETSEL) |
|            |       |       |            | 0x0: Input only (output is tri-stated) |
|            |       |       |            | 0x1: Output active |
|            |       |       |            | 0x2: Open drain (value=0 drives 0, when value=1 tristated) |
|            |       |       |            | 0x3: Open drain (value=0 drives 0, when value=1 tristated) |
| INTTYPE    | 19:17 |    RO |        0x0 | Type of interrupt for GPIO[gpio_num] |
|            |       |       |            | 0x0: active low, level type interrupt |
|            |       |       |            | 0x1: rising edge type interupt |
|            |       |       |            | 0x2: falling edge type interrupt |
|            |       |       |            | 0x3: no interrupt |
|            |       |       |            | 0x4: active high, level type interrupt |
|            |       |       |            | 0x5 to 0x7: no interrupt |
| INTEN      | 16:16 |    RW |            | Enable interrupt for GPIO[gpio_num] |
| INPUT      | 12:12 |    RO |            | Input value reported by GPIO[gpio_num] |
| OUTPUT     |   8:8 |    RO |            | Output value that is set on GPIO[gpio_num] |
| gpio_sel   |   7:0 |    RO |            | Selected gpio   |

### SETMODE offset = 0x38

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| mode       | 25:24 |    WO |        0x0 | mode control for GPIO[gpio_num} |
|            |       |       |            | 0x0: Input only (output is tri-stated) |
|            |       |       |            | 0x1: Output active |
|            |       |       |            | 0x2: Open drain (value=0 drives 0, when value=1 tristated) |
|            |       |       |            | 0x3: Open drain (value=0 drives 0, when value=1 tristated) |
| gpio_num   |   7:0 |    WO |        0x0 | Address of GPIO to set mode for |

### SETINT offset = 0x3C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| INTTYPE    | 19:17 |    WO |        0x0 | Type of interrupt for GPIO[gpio_num] |
|            |       |       |            | 0x0: active low, level type interrupt |
|            |       |       |            | 0x1: rising edge type interupt |
|            |       |       |            | 0x2: falling edge type interrupt |
|            |       |       |            | 0x3: no interrupt |
|            |       |       |            | 0x4: active high, level type interrupt |
|            |       |       |            | 0x5 to 0x7: no interrupt |
| INTENABLE  | 16:16 |    WO |        0x0 | Enable interrupt on GPIO[GPIO_ADDDR] |
| gpio_num   |   7:0 |    WO |        0x0 | Address of GPIO to set interrupt type and enable for |

### INTACK offset = 0x40

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| RESERVED   |  31:8 |    RW |            | Enable interrupt for GPIO[gpio_num] |
| gpio_num   |   7:0 |    RW |            | Input value reported by GPIO[gpio_num] |

