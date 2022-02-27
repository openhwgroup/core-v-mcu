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

#if !defined( _IN_CLI_H_ )
#error "Please include cli.h instead"
#endif

/* this file holds all of the data structures used by the CLI library. */

#include "setjmp.h"


/* forward */
struct cli_cmd_entry;

/**
* @brief Callback function for test cli
*
* Each test command calls this type of function to process the command.
*/
typedef void cli_function_t( const struct cli_cmd_entry *pEntry );


/**
* @brief An entry in a menu
*
* Note: This ends up being an array, with the "name = NULL" to terminate.
*/
struct cli_cmd_entry {
    
    /* the text */
    const char *name;
    /* helptext if present, otherwise null */
    const char *help;
    
    /* handler for this function */
    cli_function_t *pHandler;
    
    /* parameter for this function */
    intptr_t cookie;
    
};

/* This is the "handler function" when a submenu is used */
void CLI_submenu_handler( const struct cli_cmd_entry *pEntry );

/* Simple macros to help simplify creating menu tables */
#define CLI_CMD_SIMPLE( NAME, FUNCTION, HELPTEXT ) { .name = NAME, .pHandler = FUNCTION, .help = HELPTEXT, .cookie = 0 }
#define CLI_CMD_WITH_ARG( NAME, FUNCTION, ARG, HELPTEXT ) { .name = NAME, .pHandler = FUNCTION, .help = HELPTEXT, .cookie = ARG }
#define CLI_CMD_SUBMENU(  NAME,  LIST, HELPTEXT )  { .name = NAME, .pHandler = CLI_submenu_handler, .help = HELPTEXT,.cookie = ((intptr_t)(&LIST[0])) }
#define CLI_CMD_TERMINATE() { .name = NULL }

/**
* @brief - This is used to support nested commands.
*
* METHOD 1
* ---------------------
* (now at the top most commands)
* The user might type:
* prompt: [0] >
*    test <cr>
*       (now in the test sub menu) 
* prompt: [1] test >
*       string <cr>
*            (now in the 'test string' sub menu)
* prompt: [2] test string >
*            They can excute commands.
*                  for example the cmd: "foo"
*            or type "exit" to leave string menu
*        and return to the test menu
* prompt: [1] test >
*     And exit again
* And return to the main menu.
*
* METHOD 2
* ---------------------
* Or at the top menu they can type
* 
* type:  test string
* And end up at the TEST STRING menu see above)
*
* Then type: the command "foo"
* 
* METHOD 3
* ---------------------
* Or at the top type:
*
*   test string foo
*
* All varients are supported.
*/
struct cli_cmd_stack_entry {
    /* points to first item in the cmd list */
    const struct cli_cmd_entry *list_top;
    
    /* points to the actual item selected in cmd list */
    const struct cli_cmd_entry *selected_cmd;
};

/*
* This is all variables for the cli feature.
*/
struct cli {
    /* If enabled a millsec/sec timestamp appears in column 0 */
    int timestamps;
    
    /* how deep in nested menus are we? */
    int cmd_stack_idx;
    
    /* path into the menu system we are at */
#define CLI_MAX_CMD_DEPTH 20
    struct cli_cmd_stack_entry cmd_stack[ CLI_MAX_CMD_DEPTH ];
    
    int entered_sub_menu;
    
    /* raw command line */
#define CLI_MAX_CMDLINE 100
    char cmdline[CLI_MAX_CMDLINE];
    char chopped_cmdline[CLI_MAX_CMDLINE];
    
    /* chopped cmd argc/argv */
    int  argc;
    int  argx;
    char *argv[CLI_MAX_CMD_DEPTH];

    /* the unget buf is used to decode ansi sequences and key-unget  */
    /* YES these are 32bit numbers, see how arrow keys are encoded */
#define CLI_MAX_UNGET 10
    int32_t key_decode_buf[CLI_MAX_UNGET];
    
    /* What is the MAIN menu */
    const struct cli_cmd_entry *pMainMenu;
    
    /* set non zero if error */
    /* can use command to clear */
    int      error_count;
    
    /* output column */
    int col_num;
    
    /* jump buf for error handling */
    //jmp_buf   error_jump;
    /* IAR DEMANDS the "error_jump" be the last element in the structure
    * Why? I have no idea it should be able to be anywhere.
    */
    jmp_buf error_jump; // jmp_buf allocates no memory ==> crashes (size determined by stepping through setjmp)
};

/* one common "command structure */
extern struct cli CLI_common;
