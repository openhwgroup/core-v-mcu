
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
.. _apb_soc_controller:

**APB SoC controller**
======================

**APB SoC Controller:-**

-  This APB peripheral primarily controls I/O configuration and I/O function connection. It also supports a few registers for miscellaneous functions.

**APB SoC CTRL CSRs**
---------------------

**INFO offset = 0x0000**

+----------------+-----------+----------+-------------+----------------------------------+
| **Field**      | **Bits**  | **Type** | **Default** | **Description**                  |
+================+===========+==========+=============+==================================+
|   N_CORES      |   31:16   |  RO      |             | Number of cores in design        |
+----------------+-----------+----------+-------------+----------------------------------+
|   N_CLUSTERS   |   15:0    |   RO     |             | Number of clusters in design     |
+----------------+-----------+----------+-------------+----------------------------------+

**BUILD_DATE offset = 0x000C**

+-------------+----------+----------+-------------+--------------------+
| **Field**   | **Bits** | **Type** | **Default** | **Description**    |
+=============+==========+==========+=============+====================+
|   YEAR      |  31:16   |   RO     |             |   Year in BCD      |
+-------------+----------+----------+-------------+--------------------+
|   MONTH     |   15:8   |   RO     |             |   Month in BCD     |
+-------------+----------+----------+-------------+--------------------+
|   DAY       |   7:0    |   RO     |             |   Day in BCD       |
+-------------+----------+----------+-------------+--------------------+

**BUILD_TIME offset = 0x0010**

+---------------+----------+----------+-------------+---------------------+
| **Field**     | **Bits** | **Type** | **Default** | **Description**     |
+===============+==========+==========+=============+=====================+
|   HOUR        |   23:16  |   RO     |             |   Hour in BCD       |
+---------------+----------+----------+-------------+---------------------+
|   MINUTES     |   15:8   |   RO     |             |   Minutes in BCD    |
+---------------+----------+----------+-------------+---------------------+
|   SECONDS     |   7:0    |   RO     |             |   Seconds in BCD    |
+---------------+----------+----------+-------------+---------------------+

**JTAGREG offset = 0x0074**

+-----------+----------+----------+-------------+--------------------------+
| **Field** | **Bits** | **Type** | **Default** | **Description**          |
+===========+==========+==========+=============+==========================+
|   TBD     |   31:0   |   R/W    |             |   To Be Determined       |
+-----------+----------+----------+-------------+--------------------------+

**BOOTSEL offset = 0x00C4**

+-------------+----------+-----------+-------------+----------------------------------------+
| **Field**   | **Bits** | **Types** | **Default** | **Description**                        |
+=============+==========+===========+=============+========================================+
|   BootDev   |   0:0    |           |             |   Selects Boot device 1=SPI, 0=Host    |
|             |          |           |             |   mode via I2Cs                        |
+-------------+----------+-----------+-------------+----------------------------------------+

**CLKSEL offset = 0x00C8**

+-----------+----------+----------+-------------+--------------------------------+
| **Field** | **Bits** | **Type** | **Default** | **Description**                |
+===========+==========+==========+=============+================================+
|   S       |   0:0    |   R/W    |             |   This register contains       |
|           |          |          |             |   whether the system clock     |
|           |          |          |             |   is coming from               |
|           |          |          |             |   the FLL or the FLL is        |
|           |          |          |             |   bypassed.                    |
|           |          |          |             |   It is a read-only            |
|           |          |          |             |   register by the core but it  |
|           |          |          |             |   can be written via JTAG.     |
+-----------+----------+----------+-------------+--------------------------------+

**WD_COUNT offset = 0x00D0**

+-----------+----------+-----------+-------------+-------------------------------------+
| **Field** | **Bits** | **Types** | **Default** | **Description**                     |
+===========+==========+===========+=============+=====================================+
|   COUNT   |   3:0    |   R/W     |   0x8000    |   Only writable before Watchdog is  |
|           |          |           |             |   enabled                           |
+-----------+----------+-----------+-------------+-------------------------------------+

**WD_CONTROL offset = 0x00D4**

+-----------------+----------+----------+-----------+----------------------------------------+
| **Field**       | **Bits** | **Type** |**Default**| **Description**                        |
+=================+==========+==========+===========+========================================+
|  ENABLE_STATUS  |   31:31  |   RO     |           |   1=Watchdog Enabled,                  |
|                 |          |          |           |   0=Watchdog not enabled.              |
|                 |          |          |           |   Note: once enabled, cannot be        |
|                 |          |          |           |   disabled                             |
+-----------------+----------+----------+-----------+----------------------------------------+
|  WD_VALUE       |   15:0   |   WO     |   NA      |  Set to 0x6699 to reset watchdog when  |
|                 |          |          |           |  enabled, read current WD value        |
+-----------------+----------+----------+-----------+----------------------------------------+

**RESET_REASON offset = 0x00D8**

+-----------+----------+-----------+-------------+-------------------------------------+
| **Field** | **Bits** | **Types** | **Default** | **Description**                     |
+===========+==========+===========+=============+=====================================+
|   REASON  |   1:0    |   R/W     |             |   2'b01= reset pin, 2'b11=Watchdog  |
|           |          |           |             |   expired                           |
+-----------+----------+-----------+-------------+-------------------------------------+

**RTO_PERIPHERAL_ERROR offset = 0x00E0**

+-------------+----------+-----------+-------------+----------------------------------------+
| **Field**   | **Bits** | **Types** | **Default** | **Description**                        |
+=============+==========+===========+=============+========================================+
|   FCB_RTO   |   8:8    | R/W       | 0x0         | 1 indicates that the FCB interface     |
|             |          |           |             | caused a ready timeout                 |
+-------------+----------+-----------+-------------+----------------------------------------+
| TIMER_RTO   |   7:7    | R/W       | 0x0         | 1 indicates that the TIMER interface   |
|             |          |           |             | caused a ready timeout                 |
+-------------+----------+-----------+-------------+----------------------------------------+
| I2CS_RTO    |   6:6    | R/W       | 0x0         | 1 indicates that the I2CS interface    |
|             |          |           |             | caused a ready timeout                 |
+-------------+----------+-----------+-------------+----------------------------------------+
|EVENT_GEN_RTO|   5:5    | R/W       | 0x0         | 1 indicates that the EVENT GENERATOR   |
|             |          |           |             | interface caused a ready timeout       |
+-------------+----------+-----------+-------------+----------------------------------------+
|ADV_TIMER_RTO|   4:4    | R/W       | 0x0         | 1 indicates that the ADVANCED TIMER    |
|             |          |           |             | interface caused a ready timeout       |
+-------------+----------+-----------+-------------+----------------------------------------+
|SOC_CONTROL_R|   3:3    | R/W       | 0x0         | 1 indicates that the SOC CONTROL       |
|TO           |          |           |             | interface caused a ready timeout       |
+-------------+----------+-----------+-------------+----------------------------------------+
|UDMA_RTO     |   2:2    | R/W       | 0x0         | 1 indicates that the UDMA CONTROL      |
|             |          |           |             | interface caused a ready timeout       |
+-------------+----------+-----------+-------------+----------------------------------------+
|GPIO_RTO     |   1:1    | R/W       | 0x0         | 1 indicates that the GPIO interface    |
|             |          |           |             | caused a ready timeout                 |
+-------------+----------+-----------+-------------+----------------------------------------+
|FLL_RTO      |   0:0    | R/W       | 0x0         | 1 indicates that the FLL interface     |
|             |          |           |             | caused a ready timeout                 |
+-------------+----------+-----------+-------------+----------------------------------------+

**READY_TIMEOUT_COUNT offset = 0x00E4**

+-------------+----------+-----------+-------------+----------------------------------------+
| **Field**   | **Bits** | **Types** | **Default** | **Description**                        |
+=============+==========+===========+=============+========================================+
| COUNT       |  19:0    | R/W       | 0xFF        | Number of APB clocks before a ready    |
|             |          |           |             | timeout occurs                         |
+-------------+----------+-----------+-------------+----------------------------------------+

**RESET_TYPE1_EFPGA offset = 0x00E8**

+-------------+----------+-----------+-------------+-----------------------------------+
| **Field**   | **Bits** | **Types** | **Default** | **Description**                   |
+=============+==========+===========+=============+===================================+
| RESET_LB    |   3:3    | R/W       | 0x0         | Reset eFPGA Left Bottom Quadrant  |
+-------------+----------+-----------+-------------+-----------------------------------+
| RESET_RB    |   2:2    | R/W       | 0x0         | Reset eFPGA Right Bottom Quadrant |
+-------------+----------+-----------+-------------+-----------------------------------+
| RESET_RT    |   1:1    | R/W       | 0x0         | Reset eFPGA Right Top Quadrant    |
+-------------+----------+-----------+-------------+-----------------------------------+
| RESET_LT    |   0:0    | R/W       | 0x0         | Reset eFPGA Left Top Quadrant     |
+-------------+----------+-----------+-------------+-----------------------------------+

**ENABLE_IN_OUT_EFPGA offset = 0x00EC**

+--------------+----------+-----------+-------------+----------------------------------------+
| **Field**    | **Bits** | **Types** | **Default** | **Description**                        |
+==============+==========+===========+=============+========================================+
|ENABLE_EVENTS |   5:5    | R/W       | 0x0         | Enable events from efpga to SOC caused |
|              |          |           |             | a ready timeout                        |
+--------------+----------+-----------+-------------+----------------------------------------+
|ENABLE_SOC_ACC|   4:4    | R/W       | 0x0         | Enable SOC memory mapped access to     |
|ESS           |          |           |             | EFPGA                                  |
+--------------+----------+-----------+-------------+----------------------------------------+
|ENABLE_TCDM_P3|   3:3    | R/W       | 0x0         | Enable EFPGA access via TCDM port 3    |
+--------------+----------+-----------+-------------+----------------------------------------+
|ENABLE_TCDM_P2|   2:2    | R/W       | 0x0         | Enable EFPGA access via TCDM port 2    |
+--------------+----------+-----------+-------------+----------------------------------------+
|ENABLE_TCDM_P1|   1:1    | R/W       | 0x0         | Enable EFPGA access via TCDM port 1    |
+--------------+----------+-----------+-------------+----------------------------------------+
|ENABLE_TCDM_P0|   0:0    | R/W       | 0x0         | Enable EFPGA access via TCDM port 0    |
+--------------+----------+-----------+-------------+----------------------------------------+

**EFPGA_CONTROL_IN offset = 0x00F0**

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
|EFPGA_CONTROL_IN |   31:0   | R/W        | 0x00        | EFPGA control bits use per eFPGA |
|                 |          |            |             | design                           |
+-----------------+----------+------------+-------------+----------------------------------+

**EFPGA_STATUS_OUT offset = 0x00F4**

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
|EFPGA_CONTROL_OUT|   31:0   | RO         |             | Status from eFPGA                |
+-----------------+----------+------------+-------------+----------------------------------+

**EFPGA_VERSION offset = 0x00F8**

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
|EFPGA_VERSION    |    7:0   | RO         |             | EFPGA version info               |
+-----------------+----------+------------+-------------+----------------------------------+

**SOFT_RESET offset = 0x00FC**

+-----------------+----------+------------+-------------+----------------------------------+
| **Field**       | **Bits** | **Access** | **Default** | **Description**                  |
+=================+==========+============+=============+==================================+
| SOFT_RESET      |    1:1   | WO         |             | Write only strobe to reset all   |
|                 |          |            |             | APB clients                      |
+-----------------+----------+------------+-------------+----------------------------------+

**IO_CTRL offset = 0x0400**

I/O control supports two functions:

-  I/O configuration

-  I/O function selection

I/O configuration (CFG) is a series of bits that may be used to
control I/O PAD characteristics, such as drive strength and slew rate.
These driver control characteristics are implementation technology
dependent and are TBD. I/O selection (MUX) controls the select field of
a mux that connects the I/O to different signals in the device.

Each port is individually addressable at offset + IO_PORT * 4. For
example, the IO_CTRL CSR for IO_PORT 8 is at offset 0x0420.

+-------------+----------+-----------+-------------+-------------------------+
| **Field**   | **Bits** | **Types** | **Default** | **Description**         |
+=============+==========+===========+=============+=========================+
| CFG         |   13:8   | RW        | 0x00        | Pad configuration (TBD) |
+-------------+----------+-----------+-------------+-------------------------+
| MUX         |   1:0    | RW        | 0x00        | Mux select              |
+-------------+----------+-----------+-------------+-------------------------+

**Theory of Operation:-**

-  **Ports:-**

   -    input logic HCLK,  

   -    input logic HRESETn,  

   -    input ref_clk_i,  

   -    input rstpin_ni,  

   -    input logic [APB_ADDR_WIDTH-1:0] PADDR,  

   -    input logic [ 31:0] PWDATA,  

   -    input logic PWRITE,  

   -    input logic PSEL,  

   -    input logic PENABLE,  

   -    output logic [ 31:0] PRDATA,  

   -    output logic PREADY,  

   -    output logic PSLVERR,  

   -  

   -    input logic sel_fll_clk_i,  

   -    input logic bootsel_i,  

   -    input [31:0] status_out,  

   -    input [ 7:0] version,  

   -    input stoptimer_i,  

   -    input dmactive_i,  

   -    output logic wd_expired_o,  

   -    output logic [31:0] control_in,  

   -  

   -  

   -    output logic [N_IO-1:0][NBIT_PADCFG-1:0] pad_cfg_o,  

   -    output logic [N_IO-1:0][NBIT_PADMUX-1:0] pad_mux_o,  

   -  

   -    input logic [JTAG_REG_SIZE-1:0] soc_jtag_reg_i,  

   -    output logic [JTAG_REG_SIZE-1:0] soc_jtag_reg_o,  

   -  

   -    output logic [31:0] fc_bootaddr_o,  

   -  

   -    // eFPGA connections  

   -  

   -    output logic clk_gating_dc_fifo_o,  

   -    output logic [3:0] reset_type1_efpga_o,  

   -    output logic enable_udma_efpga_o,  

   -    output logic enable_events_efpga_o,  

   -    output logic enable_apb_efpga_o,  

   -    output logic enable_tcdm3_efpga_o,  

   -    output logic enable_tcdm2_efpga_o,  

   -    output logic enable_tcdm1_efpga_o,  

   -    output logic enable_tcdm0_efpga_o,  

   -    output logic fc_fetchen_o,  

   -    output logic rto_o,  

   -    input logic start_rto_i,  

   -    input logic [NB_MASTER-1:0] peripheral_rto_i,  

   -    output logic soft_reset_o  



-  In reset mode that is when HRESETn is made low,register is set to the default values.The watchdog timer is disabled, watchdog counter is set to default value 32768,state if the module is set to IDLE.Assign fc_bootaddr_o to 32'h1A000080; fc_fetchen_o, pad_cfg_o,clk_gating_dc_fifo set to 1. READY_TIMEOUT_COUNT is set to 20’h000ff.Remaining all the outputs are low.

-  At every positive edge of the clock HCLKn,

   -    If the watchdog timer is in reset mode,in this clock edge the reset mode is turned off.  

   -    If start_rto_i is high then the ready_timeout_count will be decrementing ,else if start_rto_i is low, then the ready_timeout_count is set to the default value in register READY_TIMEOUT_COUNT .  

   -    Whenever ready_timeout_count reaches zero then rto_o is made high.  

   -    Based on the input peripheral_rto_i,The register RTO_PERIPHERAL_ERROR is updated .  

   -    The output soc_jtag_reg_o changes with right shift and current value of soc_jtag_reg_i will be inserted on MSB side.  

   -    If the module is in WAIT state then it is changed to IDLE state. If PADDR[11:0] is the address of RESET_REASON then the register value is set to default 0 meaning the reset clear has been commanded.  

   -    If the module is in IDLE state then if PSEL,PENABLE and PWRITE are high then it changes to WRITE state,else if PWRITE is low,then it is in READ state.  

   -    If the state is WRITE state,then PREADY is made high and state is changed to WAIT and operation based on PADDR[11:0] happens.  



        **If PADDR[11:0] is:-**

   		-  WD_COUNT offset = 0x00D0

   			-  The start count of the watchdog timer is changed if the watchdog is enabled otherwise not changed.( PWDATA[30:0]).

		-  WD_CONTROL offset = 0x00D4

   			-  If PWDATA[31] is high ,then watchdog is enabled and reset.

   			-  If the watchdog is already enabled and PWDATA[15:0]=16'h6699,then watchdog is reset.

		-  RTO_PERIPHERAL_ERROR offset = 0x00E0

   			-  The register RTO_PERIPHERAL_ERROR is set to 0.

		-  READY_TIMEOUT_COUNT offset = 0x00E4
        
   			-  The register READY_TIMEOUT_COUNT is set to {PWDATA[19:4],4'hf}.

		-  RESET_TYPE1_EFPGA offset = 0x00E8

   			-  The register RESET_TYPE1_EFPGA is set to PWDATA[3:0]

		-  ENABLE_IN_OUT_EFPGA offset = 0x00EC

   			-  The register ENABLE_IN_OUT_EFPGA is set to PWDATA[5:0]

		-  EFPGA_CONTROL_IN offset = 0x00F0

   			-  The register EFPGA_CONTROL_IN is set to PWDATA

		-  SOFT_RESET offset = 0x00FC

   			-  All the registers are set to default values.

		-  IO_CTRL CSRs offset = 0x04??

   			-  If PADDR[9:2] is less than the number of ports then, pad_cfg_o[PADDR[9:2]] <= PWDATA[8+:NBIT_PADCFG] and pad_mux_o[PADDR[9:2]]=PWDATA[0+:NBIT_PADMUX]

			-  The port number is also stored in a variable.

			-  Here NBIT_PADCFG is 6 and NBIT_PADMUX is 2.

	-  If the state is in READ mode,then

		-  Based on the PADDR[11:0] ,corresponding registers are read and sent on the PRDATA.

   		-  PREADY is made high and state is made to WAIT.

   		-  If PWDATA[11:0] is

      		-  INFO offset = 0x0000

         		-  INFO register is read

      		-  BUILD_DATE offset = 0x000C

         		-  BUILD_DATE Register is read into the PRDATA.

   		-  Like above all the registers are read based on the address provided.Here PRADATA is a 32 bit bus.So,if the register width is less than 32 bits,remaining bits till the MSB in PRDATA are filled with 0.

   		-  If PADDR[11:0] is not equal to any of the addresses of CSRs then PSLVERR is made high and PRDATA is written 32'h0095BEEF.

   		-  If the Address PADDR[11:10] == 2'b01 which means the address is like 12'h4?? ,this means we are accessing I/O port configs.

      		-  Then if PADDR[9:2](port number) is less than N_IO(number of I/O ports) ,then PRDATA[8+:NBIT_PADCFG] will store the configuration value of the port and PRDATA[0+:NBIT_PADMUX] will store the mux value of the port.

      		-  If PADDR[9:2] is greater than N_IO then PRDATA is 32'h0095BEEF.

-  **WORKING OF THE WATCHDOG TIMER**

   -  The watchdog timer is sensitive to , and rstpin_ni.

   -  When rstpin_ni is low,then it is set to default where the current wd timer value is set to 32768.

   -  In active mode ,at every positive edge of the ref_clk_i,if watchdog is in reset mode then it resets with current count to the register WD_COUNT value and the reset mode is turned off in the next HCLK positive edge.

   -  If it is not in reset mode and is in normal working mode,ifwatchdog is enabled and stoptimer_i is low,then current watchdog count is decremented by 1 .Now,If current count reaches 1 then wd_expired_o is made high.

-  **WORKING OF RESET_REASON register**

   -  If rstpin_ni is low then the register value is 1

   -  If wd_expired_o is high then register value is 2

   -  If the Reset reason is commanded to be cleared then the register value is made 0.

-  If HRESET_n is low then the register BOOTSEL value becomes equal to {dmactive_i, bootsel_i}.Otherwise at every positive clock edge it remains the same.