/*
 * dbg_uart.c
 *
 *  Created on: Feb 27, 2021
 *      Author: qlblue
 */

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

#define DBG_UART_C
#include <SDKConfig.h>

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>

#include "libs/utils/include/dbg_uart.h"
#include "FreeRTOS.h"
#include "portmacro.h"

/*
 * FIXME: I want to include this:
 *    #include "core_m4.h"
 *
 * However, there is a compatibility problem
 * between GCC cmsis and IAR cmsis
 * so for now ... we do this here
 *
 */

/**
  \brief   Disable IRQ Interrupts
  \details Disables IRQ interrupts by setting the I-bit in the CPSR.
           Can only be executed in Privileged modes.
 */
#if 0 // defined ( __GNUC__ )
__attribute__((always_inline)) static inline void __disable_irq(void)
{
  __asm volatile ("cpsid i" : : : "memory");
}
#endif

volatile int __debug_fatal__ = 0;
uint8_t gDebugEnabledFlg = 1;
uint8_t gSimulatorEnabledFlg = 0;
uint8_t gFilterPrintMsgFlg = 0;
static void
__debug_lockup( void )
{
    /* We set this, and spin on this variable.
     * By doing this, the compiler creates a proper stack frame.
     * And the debugger is able to "climb the callstack"
     *
     * Without this, the compiler does not create a callstack
     * that the debugger can actually use :-(
     * and you cannot step out with the debugger
     * to see what happened or how you got here.
     */

    __disable_interrupt();
    __debug_fatal__ = 1;
    while( __debug_fatal__ )
        ;
}



int _dbg_uart_id = DEBUG_UART;      // From FW_global_config.h
int _semihost_handle = -1;
#ifndef SIZEOF_DBGBUFFER
#define SIZEOF_DBGBUFFER 1
#endif
uint8_t     acDbgBuffer[SIZEOF_DBGBUFFER];
uint8_t*    pcDbgBuffer = acDbgBuffer;
uint8_t*    pcDbgBufferLim = &acDbgBuffer[SIZEOF_DBGBUFFER];
bool        fSkipSemi = false;          // Used to speed strings

//extern uint32_t __semihost_call( uint32_t r0, uint32_t r1 );
//
//void _semihost_write( const char *buf, size_t n )
//{
//    int handle;
//
//
//    static const char _colon_tt[] = ":tt";
//    uint32_t v[3];
//    if( _semihost_handle == -2 ){
//        return;
//    }
//
//    /* open the terminal */
//    if( _semihost_handle == -1 ){
//        v[0] = (uint32_t)(_colon_tt); /* string */
//        v[1] = 4; /* mode = write */
//        v[2] = 3; /* length of string */
//        handle = __semihost_call( 1, (uint32_t )v );
//        if( handle >= 0 ){
//            _semihost_handle = handle;
//        } else {
//            _semihost_handle = -2;
//            return;
//        }
//    }
//    v[0] = (uint32_t)(_semihost_handle);
//    v[1] = (uint32_t)(buf);
//    v[2] = (uint32_t)(n);
//    __semihost_call( 5, (uint32_t )v );
//}

void dbg_ch_raw( int c )
{
    char buf[1];
    if( gDebugEnabledFlg == 1 )
	{
		switch(_dbg_uart_id) {
		case UART_ID_BUFFER:
			*pcDbgBuffer++ = c;
			if (pcDbgBuffer == pcDbgBufferLim) {
				pcDbgBuffer = acDbgBuffer;
			}
			break;
		default:
			udma_uart_writeraw(_dbg_uart_id, 1, &c);
		}
	}
}

void dbg_nl( void )
{
    dbg_ch_raw('\r');
    dbg_ch_raw('\n');
}

void dbg_ch( int ch )
{
	if( gDebugEnabledFlg == 1 )
	{
		if( ch == '\n' ){
			dbg_nl();
		} else {
			dbg_ch_raw(ch);
		}
	}
}
uint8_t checkIfFailedStringIsPresent(char *aBuf);
static char gsDbgStrTmpBuf[100] = {0};
void dbg_str(const char *s)
{
    const char *cp;
    memcpy(gsDbgStrTmpBuf, s, (strlen(s) + 1));
    if( gFilterPrintMsgFlg == 1 )
	{
		if( checkIfFailedStringIsPresent(gsDbgStrTmpBuf) == 0 )	//If failed string is not present, no need to print it on UART
		{
			return;
		}
	}
	while(*s){
		dbg_ch( *s );
		s++;
	}
}

static void dbg_hex4( int v )
{
    v = v & 0x0f;
    v = v + '0';
    if( v > '9' ){
        v = v - ('9'+1) + 'a';
    }
    dbg_ch( v );
}

void dbg_hex8( uint32_t u32 )
{
    dbg_hex4( (int)(u32 >> 4) );
    dbg_hex4( (int)(u32 >> 0) );
}

void dbg_hex16(uint32_t u32)
{
    dbg_hex8( u32 >> 8 );
    dbg_hex8( u32 >> 0 );
}

void dbg_hex32(uint32_t u32)
{
    dbg_hex16( u32 >> 16 );
    dbg_hex16( u32 >>  0 );
}


static void _dbg_str_xxx(const char *s)
{
    dbg_str(s);
    dbg_ch( ':' );
    dbg_ch( ' ' );
}

static void dbg_str_hexXX( const char *s, uint32_t v, void (*func)(uint32_t) )
{
    _dbg_str_xxx( s );
    dbg_ch('0');
    dbg_ch('x');
    (*func)(v);
    dbg_nl();
}


static void _dbg_int( int v )
{
    char tmp = (char)(v % 10);
    v = v / 10;
    if (v > 0) {
        _dbg_int(v);
    }
    dbg_hex4(tmp);
}

static int divmodch( int v, int dval, int z )
{
    v = v / dval;
    v = v % 10;
    dbg_ch('0'+v);
    return (v ? '0' : z);
}

void _dbg_str_now(uint32_t tnow)
{
	uint32_t z;

    /* effectively: printf( "%5d.%03d", sec, msec ) */
    z = divmodch( tnow,10000000, ' ');
    z = divmodch( tnow, 1000000, z);
    z = divmodch( tnow,  100000, z);
    z = divmodch( tnow,   10000, z);
    z = divmodch( tnow,    1000, '0');
    dbg_ch('.');
    divmodch( tnow,   100, '0');
    divmodch( tnow,   10, '0');
    divmodch( tnow,   1, '0');
    dbg_ch(' ');
    dbg_ch('|');
    dbg_ch(' ');

}


void dbg_int( int v )
{
    if( v < 0 ){
        dbg_ch('-');
        v = -v;
    }
    if( v == 0 ){
        dbg_ch('0');
        return;
    }
    _dbg_int( v );
}



void dbg_str_str( const char *s, const char *s2 )
{
    _dbg_str_xxx(s);
    dbg_str(s2);
    dbg_nl();
}

void dbg_str_str_nonl( const char *s, const char *s2 )
{
    _dbg_str_xxx(s);
    dbg_str(s2);
}

void dbg_str_int( const char *s, int v )
{
    _dbg_str_xxx( s );
    dbg_int( v );
    dbg_nl();
}

void dbg_str_int_noln( const char *s, int v )
{
    _dbg_str_xxx( s );
    dbg_int( v );
}

/* print string followed by decimal fraction */
void dbg_str_fraction( const char *s, int numerator, int denominator )
{
    int64_t w,f;
    _dbg_str_xxx(s);

    /* output value with 3 digits after decimal */
    if( numerator < 0 ){
        dbg_ch('-');
        numerator = -numerator;
    }

    w = numerator;

    /* scale up */
    w = w * 10000;
    /* round up last digit */
    w = w + (denominator/2);
    w = w / 10;

    /* get whole and fraction */
    w = w / ((int64_t)(denominator));

    /* fraction */
    f = w % 1000;

    /* whole */
    w = w / 1000;

    dbg_int( (int)(w) );
    dbg_ch('.');
    /* leading zeros */
    if( f < 100 ){
        dbg_ch('0');
    }
    if( f < 10 ){
        dbg_ch('0');
    }
    dbg_int( ((int)(f)));
    dbg_nl();
}

void dbg_str_hex8( const char *s, uint32_t v )
{
    dbg_str_hexXX( s,v, dbg_hex8 );
}

void dbg_str_hex16( const char *s, uint32_t v )
{
    dbg_str_hexXX( s,v, dbg_hex16 );
}

void dbg_str_hex32( const char *s, uint32_t v )
{
    dbg_str_hexXX( s,v, dbg_hex32 );
}



void dbg_str_ptr( const char *s, const void *vp )
{
    /* fixme: other machines it is 64bit */
    dbg_str_hex32( s, (uint32_t)(vp) );
}

void dbg_fatal_error( const char *msg )
{
    dbg_str( msg );
    dbg_nl();
    __debug_lockup();
}

void dbg_fatal_error_hex32(const char *s, uint32_t v )
{
    dbg_str_hex32( s,v );
    __debug_lockup();
}

void dbg_fatal_error_int(const char *s, int v )
{
    dbg_str_int( s,v );
    __debug_lockup();
}

void dbg_fatal_error_ptr( const char *msg, intptr_t value )
{
    dbg_str_ptr( msg, (void *)value );
    __debug_lockup();
}


struct dbg_memdump_vars {
    intptr_t addr;
    union {
        const void *pV;
        const uint8_t *p8;
        const uint16_t *p16;
        const uint32_t *p32;
    } u;
    int w;
    size_t n_todo;
    size_t n_this;
};

static void dbg_memdumpx( struct dbg_memdump_vars *pV )
{
    size_t x;
    int ch;
    size_t step;
    pV->n_this = pV->n_todo;
    if(pV->n_this > 16){
        pV->n_this = 16;
    }

    dbg_hex32(pV->addr);
    dbg_ch(':');
    dbg_ch(' ');
    step = pV->w / 8;
    for( x = 0 ; x < 16 ; x += step ){
        if( x < pV->n_todo ){
            if( step == 4 ){
                dbg_hex32( pV->u.p32[x/4] );
            } else if( step == 2 ){
                dbg_hex16( pV->u.p16[x/2] );
            } else {
                dbg_hex8( pV->u.p8[x/1] );
            }
        } else {
            for( size_t i = 0 ; i < step ; i++ ){
                dbg_ch(' ');
            }
        }
        if( (x+step) == 8 ){
            dbg_ch('-');
        } else {
            dbg_ch(' ');
        }
    }
    dbg_ch(' ');
    dbg_ch('|');
    for( x = 0 ; x < 16 ; x++ ){
        if( x < pV->n_this ){
            ch = pV->u.p8[x];
        } else {
            ch = ' ';
        }
        if( (ch >= 0x20) && (ch <= 0x7f) ){
            /* ascii */
        } else {
            /* not ascii */
            ch = '.';
        }
        dbg_ch(ch);
        if( x == 7 ){
            dbg_ch('-');
        }
    }
    dbg_ch('|');
    dbg_nl();
    pV->addr += 16;
    pV->u.p8 += 16;
    pV->n_todo -= pV->n_this;
}

void dbg_memdump8(intptr_t addr, const void *pData, size_t n )
{
    struct dbg_memdump_vars v;

    v.addr = addr;
    v.u.pV = pData;
    v.n_todo = n;
    v.w = 8;

    while( v.n_todo ){
        dbg_memdumpx(&v);
    }
}

void dbg_memdump32( intptr_t addr, const void *pData, size_t n )
{
    struct dbg_memdump_vars v;

    v.addr = addr;
    v.u.pV = pData;
    v.n_todo = n;
    v.w = 32;

    while( v.n_todo ){
        dbg_memdumpx(&v);
    }
}

void dbg_assert( const char *filename, int lineno, const char *msg )
{
    portDISABLE_INTERRUPTS();
    dbg_nl();
    dbg_str("***assert**\n");
    dbg_str_str("file", filename);
    dbg_str_int("line", lineno );
    dbg_fatal_error(msg);
}

