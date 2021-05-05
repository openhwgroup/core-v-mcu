# eFPGA Template

Memory address:  EFPGA_ASYNC_APB_START_ADD(` EFPGA_ASYNC_APB_START_ADD)

The eFPGA Template instantiates all the user accessible IO in the eFPGA and makes it available
for logic validation .

The eFPGA provide the following interfaces and resources
1. Asynchronous CPU read/write bus. With 32-bit data, byte enables and 20-bits Address
2. Four TCDM interfaces for eFPGA high speed access to read/write main L2 RAM
3. 32-bits of fpga IO which connects the fpga to the device pins via the pin mux
4. 16-bits of event generation that can interrupt the CPU.
5. 2 Math units each mathunit contains 2 32-bit multipliers that can be fractured 
into  2-16-bit, 4-8-bit or 8-4-bit multiply with accumulators and 3 4Kbyte
Simple dual port RAMS.




### TCDM_CTL_P0 offset = 0x00

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wen_p0 | 31:31 |    RW |        0x0 |  1 = read on TCDM 0, 0 = write on TCDM 0 |
| tcdm_be_p0 | 23:20 |    RW |        0x0 | Set the bye enables for TCDM 0 |
| tcdm_addr_p0 |  19:0 |    RW |        0x0 | Sets the address to be used on TCDM 0 |

### TCDM_CTL_P1 offset = 0x04

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wen_p1 | 31:31 |    RW |        0x0 |  1 = read on TCDM 1, 0 = write on TCDM 1 |
| tcdm_be_p1 | 23:20 |    RW |        0x0 | Set the bye enables for TCDM 1 |
| tcdm_addr_p1 |  19:0 |    RW |        0x0 | Sets the address to be used on TCDM 1 |

### TCDM_CTL_P2 offset = 0x08

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wen_p2 | 31:31 |    RW |        0x0 |  1 = read on TCDM 2, 0 = write on TCDM 2 |
| tcdm_be_p2 | 23:20 |    RW |        0x0 | Set the bye enables for TCDM 2 |
| tcdm_addr_p2 |  19:0 |    RW |        0x0 | Sets the address to be used on TCDM 2 |

### TCDM_CTL_P3 offset = 0x0C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wen_p3 | 31:31 |    RW |        0x0 |  1 = read on TCDM 3, 0 = write on TCDM 3 |
| tcdm_be_p3 | 23:20 |    RW |        0x0 | Set the bye enables for TCDM 3 |
| tcdm_addr_p3 |  19:0 |    RW |        0x0 | Sets the address to be used on TCDM 3 |

### M0_M0_CONTROL offset = 0x10

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| m0_m0_reset | 31:31 |    RW |        0x0 | Math Unit 0, Multiplier 0 reset accumulator |
| m0_m0_sat  | 18:18 |    RW |        0x0 | Math Unit 0, Multiplier 0 select saturation |
| m0_m0_clr  | 17:17 |    RW |        0x0 | Math Unit 0, Multiplier 0 clear accumulator |
| m0_m0_rnd  | 16:16 |    RW |        0x0 | Math Unit 0, Multiplier 0 select rounding |
| m0_m0_csel | 15:15 |    RW |        0x0 | Math Unit 0, Multiplier 0 coefficient selection |
| m0_m0_osel | 14:14 |    RW |        0x0 | Math Unit 0, Multiplier 0 operand slection |
| m0_m0_mode | 13:12 |    RW |        0x0 | Math Unit 0, Multiplier 0 mode. 00 = 32-bit, 01 = 16-bit, 10= 8-bit, 11 = 4-bit |
| m0_m0_outsel |   5:0 |    RW |        0x0 | Math Unit 0, Mutliplier 0 output select |

### M0_M1_CONTROL offset = 0x14

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| m0_m1_reset | 31:31 |    RW |        0x0 | Math Unit 0, Multiplier 1 reset accumulator |
| m0_m1_sat  | 18:18 |    RW |        0x0 | Math Unit 0, Multiplier 1 select saturation |
| m0_m1_clr  | 17:17 |    RW |        0x0 | Math Unit 0, Multiplier 1 clear accumulator |
| m0_m1_rnd  | 16:16 |    RW |        0x0 | Math Unit 0, Multiplier 1 select rounding |
| m0_m1_csel | 15:15 |    RW |        0x0 | Math Unit 0, Multiplier 1 coefficient selection |
| m0_m1_osel | 14:14 |    RW |        0x0 | Math Unit 0, Multiplier 1 operand slection |
| m0_m1_mode | 13:12 |    RW |        0x0 | Math Unit 0, Multiplier 1 mode. 00 = 32-bit, 01 = 16-bit, 10= 8-bit, 11 = 4-bit |
| m0_m1_outsel |   5:0 |    RW |        0x0 | Math Unit 0, Mutliplier 1 output select |

### M1_M0_CONTROL offset = 0x18

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| m1_m0_reset | 31:31 |    RW |        0x0 | Math Unit 1, Multiplier 0 reset accumulator |
| m1_m1_sat  | 18:18 |    RW |        0x0 | Math Unit 1, Multiplier 0 select saturation |
| m1_m0_clr  | 17:17 |    RW |        0x0 | Math Unit 1, Multiplier 0 clear accumulator |
| m1_m0_rnd  | 16:16 |    RW |        0x0 | Math Unit 1, Multiplier 0 select rounding |
| m1_m0_csel | 15:15 |    RW |        0x0 | Math Unit 1, Multiplier 0 coefficient selection |
| m1_m0_osel | 14:14 |    RW |        0x0 | Math Unit 1, Multiplier 0 operand slection |
| m1_m0_mode | 13:12 |    RW |        0x0 | Math Unit 1, Multiplier 0 mode.
00 = 32-bit, 01 = 16-bit, 10= 8-bit, 11 = 4-bit |
| m1_m0_outsel |   5:0 |    RW |        0x0 | Math Unit 1, Mutliplier 0 output select |

### M1_M1_CONTROL offset = 0x1C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| m1_m1_reset | 31:31 |    RW |        0x0 | Math Unit 1, Multiplier 1 reset accumulator |
| m1_m1_sat  | 18:18 |    RW |        0x0 | Math Unit 1, Multiplier 1 select saturation |
| m1_m1_clr  | 17:17 |    RW |        0x0 | Math Unit 1, Multiplier 1 clear accumulator |
| m1_m1_rnd  | 16:16 |    RW |        0x0 | Math Unit 1, Multiplier 1 select rounding |
| m1_m1_csel | 15:15 |    RW |        0x0 | Math Unit 1, Multiplier 1 coefficient selection |
| m1_m1_osel | 14:14 |    RW |        0x0 | Math Unit 1, Multiplier 1 operand slection |
| m1_m1_mode | 13:12 |    RW |        0x0 | Math Unit 1, Multiplier 1 mode.
00 = 32-bit, 01 = 16-bit, 10= 8-bit, 11 = 4-bit |
| m1_m1_outsel |   5:0 |    RW |        0x0 | Math Unit 1, Mutliplier 1 output select |

### M0_RAM_CONTROL offset = 0x20

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| m0_coef_wdsel | 14:14 |    RW |        0x0 | Math Unit 0 coefficient RAM write data select |
| m0_oper1_wdsel | 13:13 |    RW |        0x0 | Math Unit 0 Operand 0 RAM write data select |
| m0_oper0_wdsel | 12:12 |    RW |        0x0 | Math Unit 0 Operand 1 RAM write data select |
| m0_coef_wmode | 11:10 |    RW |        0x0 | Math Unit 0 coefficient RAM write mode |
| m0_coef_rmode |   9:8 |    RW |        0x0 | Math Unit 0 coefficient RAM read mode |
| m0_oper1_wmode |   7:6 |    RW |        0x0 | Math Unit 0 operand 0 RAM write mode |
| m0_oper1_rmode |   5:4 |    RW |        0x0 | Math Unit 0 operand 0 RAM read mode |
| m0_oper0_wmode |   3:2 |    RW |        0x0 | Math Unit 0 operand 1 RAM write mode |
| m0_oper0_rmode |   1:0 |    RW |        0x0 | Math Unit 0 operand 1 RAM read mode |

### M1_RAM_CONTROL offset = 0x24

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| m1_coef_wdsel | 14:14 |    RW |        0x0 | Math Unit 1 coefficient RAM write data select |
| m1_oper1_wdsel | 13:13 |    RW |        0x0 | Math Unit 1 Operand 0 RAM write data select |
| m1_oper0_wdsel | 12:12 |    RW |        0x0 | Math Unit 1 Operand 1 RAM write data select |
| m1_coef_wmode | 11:10 |    RW |        0x0 | Math Unit 1 coefficient RAM write mode |
| m1_coef_rmode |   9:8 |    RW |        0x0 | Math Unit 1 coefficient RAM read mode |
| m1_oper1_wmode |   7:6 |    RW |        0x0 | Math Unit 1 operand 0 RAM write mode |
| m1_oper1_rmode |   5:4 |    RW |        0x0 | Math Unit 1 operand 0 RAM read mode |
| m1_oper0_wmode |   3:2 |    RW |        0x0 | Math Unit 1 operand 1 RAM write mode |
| m1_oper0_rmode |   1:0 |    RW |        0x0 | Math Unit 1 operand 1 RAM read mode |

### FPGAIO_OUT31_00 offset = 0x40

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_o_31 | 31:31 |    RW |        0x0 | Sets the fpgio output bit 31 |
| …          |   .:. |       |            |                 |
| fpgaio_o_00 |   0:0 |    RW |        0x0 | Sets the fpgio ouptut bit 00 |

### FPGAIO_OUT63_32 offset = 0x44

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_o_63 | 31:31 |    RW |        0x0 | Sets the fpgio output bit 63 |
| …          |   .:. |       |            |                 |
| fpgaio_o_32 |   0:0 |    RW |        0x0 | Sets the fpgio ouptut bit 32 |

### FPGAIO_OUT79_64 offset = 0x48

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_o_79 | 16:16 |    RW |        0x0 | Sets the fpgio output bit 79 |
| …          |   .:. |       |            |                 |
| fpgaio_o_64 |   0:0 |    RW |        0x0 | Sets the fpgio ouptut bit 64 |

### FPGAIO_OE31_00 offset = 0x50

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_oe_31 | 31:31 |    RW |        0x0 | Sets the fpgio output enable for bit 31 |
| …          |   .:. |       |            |                 |
| fpgaio_oe_00 |   0:0 |    RW |        0x0 | Sets the fpgio ouptut enable for bit 00 |

### FPGAIO_OE63_32 offset = 0x54

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_oe_63 | 31:31 |    RW |        0x0 | Sets the fpgio output enable for bit 63 |
| …          |   .:. |       |            |                 |
| fpgaio_oe_32 |   0:0 |    RW |        0x0 | Sets the fpgio ouptut enable for bit 32 |

### FPGAIO_OE79_64 offset = 0x58

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_oe_79 | 16:16 |    RW |        0x0 | Sets the fpgio output enable for bit 79 |
| …          |   .:. |       |            |                 |
| fpgaio_oe_64 |   0:0 |    RW |        0x0 | Sets the fpgio ouptut enable for bit 64 |

### FPGAIO_I31_00 offset = 0x60

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_i_31 | 31:31 |    RO |            | Reads the fpgaio input value for bit 31 |
| …          |   .:. |       |            |                 |
| fpgaio_i_00 |   0:0 |    RO |            | Reads the fpgaio input value for bit 00 |

### FPGAIO_I63_32 offset = 0x64

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_i_63 | 31:31 |    RO |            | Reads the fpgaio input value for bit 63 |
| …          |   .:. |       |            |                 |
| fpgaio_i_32 |   0:0 |    RO |            | Reads the fpgaio input value for bit 32 |

### FPGAIO_I79_64 offset = 0x68

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| fpgaio_i_79 | 16:16 |    RO |            | Reads the fpgaio input value for bit 79 |
| …          |   .:. |       |            |                 |
| fpgaio_i_764 |   0:0 |    RO |            | Reads the fpgaio input value for bit 65 |

### FPGA_EVENT15_00 offset = 0x6C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| Event_16   | 16:16 |    RW |            | sets event 16 to the event unit |
| …          |   .:. |       |            |                 |
| Event_00   |   0:0 |    RW |            | sets event 00 to the event unit |

### TCDM_RUN_P0 offset = 0x80

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wdata_p0 |  31:0 |     W |            | Runs a TCDM operation on P0 with TCDM_CTL_P0 Attributes |

### TCDM_RUN_P1 offset = 0x84

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wdata_p0 |  31:0 |     W |            | Runs a TCDM operation on P1 with TCDM_CTL_P0 Attributes |

### TCDM_RUN_P2 offset = 0x88

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wdata_p0 |  31:0 |     W |            | Runs a TCDM operation on P2 with TCDM_CTL_P0 Attributes |

### TCDM_RUN_P3 offset = 0x8C

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| tcdm_wdata_p0 |  31:0 |     W |            | Runs a TCDM operation on P3 with TCDM_CTL_P0 Attributes |

### M0_M0_ODATA offset = 0x90

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| odata      |  31:0 |    RW |            | Sets the operand data for math unit 0 multiplier 0 |

### M0_M1_ODATA offset = 0x94

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| odata      |  31:0 |    RW |            | Sets the operand data for math unit 0 multiplier 1 |

### M0_M0_CDATA offset = 0x98

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| cdata      |  31:0 |    RW |            | Sets the coeficient data for math unit 0 multiplier 0 |

### M0_M1_CDATA offset = 0x98

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| cdata      |  31:0 |    RW |            | Sets the coeficient data for math unit 0 multiplier 1 |

### M1_M0_ODATA offset = 0xA0

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| odata      |  31:0 |    RW |            | Sets the operand data for math unit 1 multiplier 0 |

### M1_M1_ODATA offset = 0xA4

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| odata      |  31:0 |    RW |            | Sets the operand data for math unit 0 multiplier 1 |

### M1_M0_CDATA offset = 0xA8

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| cdata      |  31:0 |    RW |            | Sets the coeficient data for math unit 1 multiplier 0 |

### M1_M1_CDATA offset = 0xA8

| Field      |  Bits |  Type |    Default | Description     |
| --------------------- |   --- |   --- |        --- | ------------------------- |
| cdata      |  31:0 |    RW |            | Sets the coeficient data for math unit 1 multiplier 1 |

### M0_OPER0[0x400] offset = 0x3000


### M0_OPER1[0x400] offset = 0x4000


### M0_COEF[0x400] offset = 0x5000


### M1_OPER0[0x400] offset = 0x6000


### M1_OPER1[0x400] offset = 0x7000


### M1_COEF[0x400] offset = 0x8000


### Notes:

| Access type | Description |
| ----------- | ----------- |
| RW          | Read & Write |
| RO          | Read Only    |
| RC          | Read & Clear after read |
| WO          | Write Only |
| WC          | Write Clears (value ignored; always writes a 0) |
| WS          | Write Sets (value ignored; always writes a 1) |
| RW1S        | Read & on Write bits with 1 get set, bits with 0 left unchanged |
| RW1C        | Read & on Write bits with 1 get cleared, bits with 0 left unchanged |
| RW0C        | Read & on Write bits with 0 get cleared, bits with 1 left unchanged |