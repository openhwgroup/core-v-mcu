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


#include "libs/cli/include/cli.h"
#include "string.h"
#include "stdio.h"
#include "stdlib.h"
//#include "ql_time.h"
#include "FreeRTOS.h"
#include "task.h"

/* this is generally a list of functions used to test the CLI argument api
 * but also provides access to some standard commands, ie: FILESYSTEM menu and a WAIT command 
 */

/* TEST CODE */
static int bool_value;
static unsigned unsigned_value;
static int int_value;
static uint8_t uint8_value;
static uint16_t uint16_value;
static uint32_t uint32_value;
static uint64_t uint64_value;
static int8_t int8_value;
static int16_t int16_value;
static int32_t int32_value;
static int64_t int64_value;
static float float_value  = 3.14159;

static char str_lc_buf[20];
static char str_buf[20];

static void test_bool( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_bool_getshow( "test_bool", &bool_value ) ){
        CLI_printf("new value was given\n");
    }
}


static void test_unsigned( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_unsigned_getshow( "test_unsigned", &unsigned_value ) ){
        CLI_printf("new value was given\n");
    }
}

static void test_uint8( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_uint8_getshow( "test_uint8", &uint8_value ) ){
        CLI_printf("new value was given\n");
    }
}


static void test_uint16( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_uint16_getshow( "test_uint16", &uint16_value ) ){
        CLI_printf("new value was given\n");
    }
}


static void test_uint32( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_uint32_getshow( "test_uint32", &uint32_value ) ){
        CLI_printf("new value was given\n");
    }
}



static void test_uint64( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_uint64_getshow( "test_uint64", &uint64_value ) ){
        CLI_printf("new value was given\n");
    }
}


static void test_i_common( const struct cli_cmd_entry *pEntry )
{
    int eof;
    
    switch( pEntry->cookie ){
    case 'I':
        eof = CLI_int_getshow( "test_int", &int_value );
        break;
    case 8:
        eof = CLI_int8_getshow( "test_int8", &int8_value );
        break;
    case 16:
        eof = CLI_int16_getshow( "test_int16", &int16_value );
        break;
    case 32:
        eof = CLI_int32_getshow( "test_int32", &int32_value );
        break;
    case 64:
        eof = CLI_int64_getshow( "test_int64", &int64_value );
        break;
    default:
        CLI_error("unknown cookie?\n");
        break;
    }
    if( eof == EOF ){
        CLI_printf("no new value was given\n");
    } else {
        CLI_printf("a new value was provided\n");
    }
}


static void test_float( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_float_getshow( "test_float", &float_value ) ){
        CLI_printf("new value was given\n");
    }
}

static void test_str_buf( const struct cli_cmd_entry*pEntry )
{
    if( EOF != CLI_string_buf_getshow( "str_buf", str_buf, sizeof(str_buf) ) ){
        CLI_printf("new value was given\n");
    }
}

static void test_str_lc_buf( const struct cli_cmd_entry *pEntry )
{
    if( EOF != CLI_string_buf_lc_getshow( "str_lc_buf", str_lc_buf, sizeof(str_lc_buf) ) ){
        CLI_printf("new value was given\n");
    }
}


static void test_str_ptr( const struct cli_cmd_entry *pEntry )
{
    char *strptr;
    
    strptr = "My STR PTR VALUE";
    if( EOF != CLI_string_ptr_getshow( "str_ptr", &strptr ) ){
        CLI_printf("new value was given: %s\n", strptr );
    }
}

static void test_str_lc_ptr( const struct cli_cmd_entry *pEntry )
{
    char *strptr;
    
    strptr = "My lower case str ptr value";
    if( EOF != CLI_string_ptr_lc_getshow( "str_lc_ptr", &strptr ) ){
        CLI_printf("new value was given: %s\n", strptr );
    }
}


/*
* NOTE: the menu is structured like this (multi-level) on purpose.
* so that it can also be used to test the 'submenu' feature.
*/



static const struct cli_cmd_entry u_menu[] =
{
    CLI_CMD_SIMPLE( "unsigned", test_unsigned, "test unsigned integer" ),
    CLI_CMD_SIMPLE( "uint8", test_uint8  , "test uint8" ),
    CLI_CMD_SIMPLE( "uint16", test_uint16, "test uint16"  ),
    CLI_CMD_SIMPLE( "uint32", test_uint32, "test uint32"  ),
    CLI_CMD_SIMPLE( "uint64", test_uint64, "test uint64"  ),
    
    CLI_CMD_TERMINATE()
};

static const struct cli_cmd_entry i_menu[] =
{
    /* this is structured this way to test the "cookie" feature of the entry
    * this lets you use a common function instead of dedicated functions
    */
    { .name = "integer", .pHandler = test_i_common, .cookie = 'I', .help = "integer-help" },
    { .name = "int8",    .pHandler = test_i_common, .cookie = 8, .help = "integer8-help" },
    { .name = "int16",    .pHandler = test_i_common, .cookie = 16, .help = "integer16-help" },
    { .name = "int32",    .pHandler = test_i_common, .cookie = 32, .help = "integer32-help" },
    { .name = "int64",    .pHandler = test_i_common, .cookie = 64, .help = "integer64-help" },
    
    CLI_CMD_TERMINATE()
};

static const struct cli_cmd_entry str_menu[] =
{
    { .name = "str_buf", .pHandler = test_str_buf, .cookie = 0, .help = NULL },
    { .name = "str_lc_buf", .pHandler = test_str_lc_buf, .cookie = 0, .help = NULL },
    { .name = "str_ptr", .pHandler = test_str_ptr, .cookie = 0, .help = NULL },
    { .name = "str_lc_ptr", .pHandler = test_str_lc_ptr, .cookie = 0, .help = NULL },
    
    CLI_CMD_TERMINATE()
};

static const struct cli_cmd_entry cli_test_menu[] =
{
    CLI_CMD_SIMPLE( "bool", test_bool, "test bools" ),
    CLI_CMD_SUBMENU( "string", str_menu , "string tests"),
    CLI_CMD_SUBMENU( "integer", i_menu, "integer tests" ),
    CLI_CMD_SUBMENU( "unsigned", u_menu , "unsigned tests"),
    CLI_CMD_SIMPLE( "float", test_float , "float tests"),
    CLI_CMD_TERMINATE()
};


static void cmd_error( const struct cli_cmd_entry *pEntry )
{
    CLI_int_getshow( "newvalue", &CLI_common.error_count );
}

/* lets the user insert a wait into a command sequence pasted in teraterm */
static void cli_cmd_wait( const struct cli_cmd_entry *pEntry  )
{
    int v;
    int tmp;
    intptr_t token;
    int ticktock;
    v = 0;
    CLI_int_required( "period-mSecs", &v );
    
    token = ql_lw_timer_start();
    /* print something every 500mSecs */
    tmp = ql_lw_timer_remain( token, v );
    ticktock = 0;
    while( tmp > 0 ){
        if( tmp > 500 ){
            tmp = 500;
        }
        vTaskDelay( tmp );
        tmp = ql_lw_timer_remain( token, v );
        CLI_printf( "\r%s: %8d ", ticktock ? "Wait...." : "....Wait", tmp );
        ticktock = !ticktock;
    }
    /* force new line */
    CLI_printf("\n");
}
                



const struct cli_cmd_entry cli_std_menu[] =
{
    CLI_CMD_SIMPLE( "error", cmd_error, "set/clear error flag" ),
    CLI_CMD_SUBMENU( "test", cli_test_menu, "self tests"),
#if (FEATURE_CLI_FILESYSTEM & (!QAI_CHILKAT))
    CLI_CMD_SUBMENU( "file", cli_file_menu, "file commands" ),
#endif
    CLI_CMD_SIMPLE( "wait", cli_cmd_wait, "wait N mSecs" ),
    CLI_CMD_TERMINATE()
};
