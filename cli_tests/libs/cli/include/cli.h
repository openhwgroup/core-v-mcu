/*==========================================================
 * Copyright 2020 QuickLogic Corporation
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

#if !defined(CLI_H)
#define CLI_H

#include "stdio.h"
#include "setjmp.h"
#include "stdint.h"
#include "stdarg.h"

#define _IN_CLI_H_

#include "cli/cli_structs.h"
#include "cli/cli_getkey.h"
#include "cli/cli_hw.h"
#include "cli/cli_misc.h"
#include "cli/cli_time.h"
#include "cli/cli_args.h"
#include "cli/cli_print.h"
#include "cli/cli_filesystem.h"

#undef _IN_CLI_H_

#define CLI_TASK_STACKSIZE  256
#define CLI_TASK_PRIORITY   3

/**
* @brief Create a CLI task, to process commands, use provided main menu
*/
void CLI_start_task(const struct cli_cmd_entry *pMainMenu);

/**
* @brief Handle keys as they are typed.
*
* This is called by the CLI_task to process keys. see CLI_start_task() for detals.
*/
void CLI_rx_byte(int keypressed);

/**
* @brief Dispatch the next command in the "path" list.
*
* Assumptions:
*    There are more parameters to be processed.
*    And the "top" of the cmd path stack has a pointer to a list of commands.
*/
void CLI_dispatch_command( void );

/* a few standard menu items */
extern const struct cli_cmd_entry cli_file_menu[];
extern const struct cli_cmd_entry cli_std_menu[];

#endif

