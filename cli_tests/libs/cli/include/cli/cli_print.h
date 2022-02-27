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
 * These are various console IO functions that use the CLI uart
 */


/**
* @brief make the test console bell ring.
*/
void CLI_beep(void);


/**
* @brief printf to the test console.
*
* @param fmt - printf format
*/
void CLI_printf( const char *fmt, ... );

/**
* @brief workhorse for printf to the test console.
*
* @param fmt - printf format
* @param ap -  parameters for printf
*/
void CLI_vprintf( const char *fmt, va_list ap );

/**
* @brief Platform optional function, print null terminated string + newline.
*
* @param s - string to print.
*/
void CLI_puts( const char *s );

/**
* @brief Platform optional function, print null terminated string.
*
* @param s - string to print.
*/
void CLI_puts_no_nl( const char *s );


/**
* @brief Write a byte to the serial port with cr/lf mapping.
*
* @param c - the byte to write.
*/
void CLI_putc(int c);


/**
* @brief Print a newline, and the prompt
*
* used at startup to print the initial prompt
*/
void CLI_print_prompt(void);

/*
* @brief Traditional hex dump of memory.
* 
* @param addr - address to print
* @param pdata - pointer to data to dump
* @param nbytes - count of bytes to hex dump
*/
void CLI_hexdump( uint32_t addr, const void *pData, size_t nbytes );
