# APB_GPIO

Memory address: GPIO_START_ADDR(`GPIO_START_ADDR)

The GPIO module supports S/W access to read and write the values on selected I/O,
and configuring selected I/O to generate interrupts.

Interrupts

Any GPIO can be configured for level type interrupts or edge triggered interrupts.
Levels based int

Offset/Field
SETGPIO
gpio_num
CLRGPIO
gpio_num
TOGGPIO
gpio_num

PIN0
gpio_value
PIN1
gpio_value
PIN2
gpio_value
PIN3
gpio_value

OUT0
value
OUT1
value
OUT2
value
OUT3
value

SETSEL
gpio_num

RDSTAT
mode




INTTYPE






INPUT
OUTPUT
gpio_num

SETMODE
mode




gpio_num


SETINT
INTTYPE






INTENABLE
gpio_num

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
