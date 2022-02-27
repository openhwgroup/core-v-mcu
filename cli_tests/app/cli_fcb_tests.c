/*==========================================================
 * Copyright 2021 QuickLogic Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *==========================================================*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "target/core-v-mcu/include/core-v-mcu-config.h"
#include "libs/cli/include/cli.h"
#include "libs/utils/include/dbg_uart.h"
#include "include/programFPGA.h"

static void program_fpga(const struct cli_cmd_entry *pEntry);
static void read_fcb_reg(const struct cli_cmd_entry *pEntry);
static void write_fcb_reg(const struct cli_cmd_entry *pEntry);
// EFPGA menu
const struct cli_cmd_entry fcb_cli_tests[] =
{
  CLI_CMD_SIMPLE( "pgm", program_fpga, "Program FPGA" ),
  CLI_CMD_SIMPLE( "read", read_fcb_reg, "Read FCB register" ),
  CLI_CMD_SIMPLE( "write", write_fcb_reg, "Write FCB register" ),
  CLI_CMD_TERMINATE()
};

static void program_fpga(const struct cli_cmd_entry *pEntry)
{
	programFPGA();
    (void)pEntry;
    dbg_str("Pgm FPGA <<DONE>>\r\n");
}

static void read_fcb_reg(const struct cli_cmd_entry *pEntry)
{
	uint32_t regNum = 0;
	uint32_t xValue = 0;
	uint32_t *lPtr = 0;
    (void)pEntry;
    CLI_uint32_required( "regNum", &regNum );

    lPtr = (uint32_t *) (EFPGA_CONFIG_START_ADDR + (4* regNum) );
    xValue = *lPtr;
	CLI_printf("value 0x%08x\n", xValue);
	dbg_str("<<DONE>>\r\n");
}

static void write_fcb_reg(const struct cli_cmd_entry *pEntry)
{
    (void)pEntry;
    uint32_t regNum = 0;
	uint32_t xValue = 0;
	uint32_t *lPtr = 0;

    CLI_uint32_required( "regNum", &regNum );
    CLI_uint32_required( "value", &xValue);

    lPtr = (uint32_t *) (EFPGA_CONFIG_START_ADDR + (4* regNum));

    *lPtr = xValue;
	dbg_str("<<DONE>>\r\n");
}
