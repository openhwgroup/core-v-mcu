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

#ifndef LIBS_UTILS_INCLUDE_DBG_UART_H_
#define LIBS_UTILS_INCLUDE_DBG_UART_H_


#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include "stdint.h"
#include "FreeRTOS.h"
/**
 * @brief Low stack usage debug dump functions.
 *
 * other methods require lots of stack and other library funcs.
 * This is suitable for use in a crash handler to print details
 * like registers and a stack dump
 *
 * @{
 */

#define UART_ID_BUFFER	-1	// Use this to save all data the buffer

#if !defined(FEATURE_DBG_UART)
#define FEATURE_DBG_UART 1
#endif
extern int _dbg_uart_id;

extern uint32_t __semihost_call( uint32_t r0, uint32_t r1 );
extern int _semihost_handle;
void _semihost_write( const char *buf, size_t n );

/*
 * Fatal error messages should never removed by macros.
 * the should end up at some log function, and either
 * a hang in a while(1) with interrupts disabled
 * or force a device reset after logging the message
 */
void dbg_fatal_error( const char *msg );
void dbg_fatal_error_hex32( const char *msg, uint32_t value);
void dbg_fatal_error_int( const char *msg, int value);
/* usable from an assert */
void dbg_assert( const char *filename, int lineno, const char *msg );

/* start task to print message buffer periodically */

void dbg_startbufferedprinttask(UBaseType_t priority);

#if !defined( FEATURE_DBG_UART )
#define FEATURE_DBG_UART 1
#endif

#if ((FEATURE_DBG_UART) & (~1))
#error FEATURE_DBG_UART must be exactly 0 or 1.
#endif

#if FEATURE_DBG_UART || defined(DBG_UART_C)

/* output raw byte, do not map \n -> \r\n */
void dbg_ch_raw(int ch);

/* output a ch, maps \n -> \r\n */
void dbg_ch(int ch);
#define dbg_putc dbg_ch

/* output a \r\n */
void dbg_nl(void);

/* print integer */
void dbg_int(int v);

/* print string, maps \n -> \r\n */
void dbg_str(const char *s);

/* print 8bit value as hex */
void dbg_hex8(uint32_t u32);

/* print 16bit value as hex */
void dbg_hex16(uint32_t u32);

/* print 32bit value as hex */
void dbg_hex32(uint32_t u32);

/*
 * equal to: printf("%s: %d\n", s, v );
 */
void dbg_str_int( const char *s, int v);

/*
 * Equal to:
 *     value = (float)numerator / (float)denominator
 * The print the result as float with 3 digits after decimal point.
 *
 * Example:    n = 123456;  d = 3333;
 * would produce:   "370.739"
 */
void dbg_str_fraction( const char *s, int numerator, int denominator );

/*
 * equal to: printf("%s: %s\n", s, s2 );
 */
void dbg_str_str( const char *s, const char *s2);

/*
 * equal to: printf("%s: %s", s, s2 );
 */
void dbg_str_str_nonl( const char *s, const char *s2 );


void dbg_str_int_noln( const char *s, int v );

/*
 * equal to: printf("%s: 0x%04x\n", s, v );
 */
void dbg_str_hex16( const char *s, uint32_t v );

/*
 * equal to: printf("%s: 0x%02x\n", s, v );
 */
void dbg_str_hex8( const char *s, uint32_t v );

/* print string, ": ", and hex32 bit value, and newline
 *
 * simular to: printf("%s: %08x\n", s, u32 );
 * But with zero overhead from the std library.
 */
void dbg_str_hex32( const char *s, uint32_t v32 );

void dbg_str_ptr( const char *s, const void *vp );

/* print now as a timestamp */
void _dbg_str_now(uint32_t tnow);
#define dbg_str_now() _dbg_str_now( xTaskGetTickCount() )

/**
 * @brief print hex dump of memory as 32bit values
 *
 * for example to print a stack dump in a crash handler.
 */
void dbg_memdump32( intptr_t addr, const void *pData, size_t n );

/**
 * @brief print hex dump of memory as 8bit values
 *
 * for example to print a stack dump in a crash handler.
 */
void dbg_memdump8( intptr_t addr, const void *pData, size_t n );

#else

/* NOTE:
 *      dbg_fatal_error()
 * and  dbg_fatal_error_hex32()
 *
 * Are *never* disabled by macros.
 */

#define dbg_ch(CH)
#define dbg_putc(CH)
#define dbg_int(VALUE)
#define dbg_str(VALUE)
#define dbg_hex8(VALUE)
#define dbg_hex16(VALUE)
#define dbg_hex32(VALUE)
#define dbg_str_int( PTR, VALUE )
#define dbg_str_str( PTR, VALUE )
#define dbg_str_hex16( PTR, VALUE )
#define dbg_str_hex8( PTR, VALUE )
#define dbg_str_hex32( PTR, VALUE )
#define dbg_str_ptr( PTR, VP )
#define dbg_str_now()

#define dbg_memdump32( ADDR, DATA, COUNT )
#define dbgmemdump8( ADDR,  DATA, COUNT )

#endif /* feature debug uart */

#ifdef __cplusplus
}
#endif


#endif /* LIBS_UTILS_INCLUDE_DBG_UART_H_ */
