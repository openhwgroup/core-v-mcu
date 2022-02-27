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

/*
 * This is a collection of misc functions that don't have another home
 */


/**
* @brief Initialize the test cli system.
* 
* @param pMainMenu - main menu of commands.
*/ 
void CLI_init( const struct cli_cmd_entry *pMainMenu );

/**
* @brief Stop processing commands and print an error.
*
* @param fmt - printf format
*/
void CLI_error( const char *fmt, ... );

/**
* Workhorse for CLI_error_xxxx() functions
*
* @param fmt - printf format
* @param ap - printf arguments.
*/
void CLI_verror( const char *fmt, va_list ap );

/**
* @brief Common function to handle missing parameter.
*
* @param name - the name of the missing parameter.
*/
void CLI_error_missing_parameter( const char *name );

/**
* @brief Common function to handle a non-numeric error.
*
* @param name - the name of the missing parameter.
*/
void CLI_error_not_a_number( const char *name, const char *value );

/**
* @brief replace the top of stack with this command entry.
*
* @param pCmd - new entry for top of stack.
*/
void CLI_cmd_stack_replace( const struct cli_cmd_entry *pCmd );

/**
* @brief return the top most (aka: the active) list of valid commands.
*
*/
const struct cli_cmd_entry *CLI_cmd_stack_peek(void);

/**
* @brief Clear the command stack.
*/
void CLI_cmd_stack_clear(void);

/**
* @brief Pop one item from the command stack.
*/
void CLI_cmd_stack_pop(void);

/**
* @breif Push one item onto the command stack.
*
* @param pEntry - the entry to push.
*/
void CLI_cmd_stack_push( const struct cli_cmd_entry *pEntry );
