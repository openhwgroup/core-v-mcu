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


#include <libs/cli/include/cli.h>
#include "stdio.h"
#include "string.h"

uint8_t checkIfFailedStringIsPresent(char *aBuf);
extern uint8_t gFilterPrintMsgFlg;
/* make 1 to help debug key sequence decode */
#define DEBUG_KEYS 0

/* ignore/invalidate NULL bytes */
static int get_key_ignore_null( int timeout )
{
    int result;
    result = CLI_getkey_raw(timeout);
    if( result == EOF ){
        return result;
    }
    
    /* don't allow null */
    if( result == 0 ){
        return 0xdeadbeef;
    } else {
#if DEBUG_KEYS
        CLI_printf("rx=%02x\n", result );
#endif
    }
    return result;
}

/*
 * When a function key is pressed, or other keys are pressed
 * they often include numbers in the string.
 *
 * This parses a number field, from something like: <ESC>[13A 
 * or  <ESC>[5;4;3;2;1X
 *
 * Numbers are always positive
 * return negative if no number, or the number is not valid
 * Update idx
 */
static int my_atoi( const int32_t *ip, int *idx )
{
    int v;
    int ch;
    int n;
    
    v = 0;
    n = 0;
    for(;;){
        ch = (int)(ip[*idx]);
        if( (ch >= '0') && (ch <= '9') ){
            n++;
            v = v * 10;
            v = v + ch - '0';
            *idx = *idx + 1;
            n++;
            continue;
        } else {
            break;
        }
    }
    
    /* no number */
    if( n == 0 ){
        return -1;
    }
    /* number */
    return v;
}

/* decode an CSI (Control Sequence Introducer) sequence */
static void decode_sequence(void)
{
    /* we have a properly formatted sequence */
    
    int n;
    int idx;
    int tmp;
    int result;
    
    /* must start with <ESC>[ */
    if( CLI_common.key_decode_buf[0] != 0x1b ){
        return;
    }
    
    /* vt100 pf1 to pf4 */
    if( CLI_common.key_decode_buf[1] == 'O' ){
        if( (CLI_common.key_decode_buf[2] >= 'P') && (CLI_common.key_decode_buf[2] <= 'S') ){
            result = _KEYCODE32( 'P', 'F', CLI_common.key_decode_buf[1],CLI_common.key_decode_buf[2] );
            goto done;
        }
    }
    
    if( CLI_common.key_decode_buf[1] != '[' ){
        // all others are CSI keys */
        return;
    }
    
    result = '[';
    /* start after the open [ */
    idx = 2;
    /* n counts the fields */
    for(n = 0 ; n < 3 ; /* below */ ){
        if( idx >= (CLI_MAX_UNGET-1)){
            /* BAD - bail */
            return;
        }
        
        /* extract number */
        tmp = my_atoi( &(CLI_common.key_decode_buf[0]), &idx );
        if( tmp < 0 ){
            break;
        }
        
        /* we have a number */
        n = n + 1;
        
        /* add the number to our result */
        result = result * 256;
        result = result + tmp;
        
        /* if number ends with a ; then there are more */
        if( CLI_common.key_decode_buf[idx]== ';'){
            continue;
        } else {
            /* done with numbers */
            break;
        }
    }
    result = result * 256;
    result = result + CLI_common.key_decode_buf[idx];
    if( n > 1 ){
        /* invalid only support 2 number groups */
        return;
    }
done:
    memset( (void *)&(CLI_common.key_decode_buf), 0, sizeof(CLI_common.key_decode_buf) );
    CLI_common.key_decode_buf[0] = result;
}      


/* append key to the decode buffer */
static void append_key(int k)
{
    int x;
    for( x = 0 ; x < (CLI_MAX_UNGET-1) ; x++ ){
        if( CLI_common.key_decode_buf[x] == 0 ){
	  CLI_common.key_decode_buf[x]=k;
            break;
        }
    }
    /* overflow... drop it*/
    /* but always terminate key sequence */
    CLI_common.key_decode_buf[CLI_MAX_UNGET-1] = 0;
}

void CLI_ungetkey( int key )
{
  /* much like "man 3 fungetc()" */
    if( key == 0 ){
        /* ignore */
        return;
    }
    if( key == EOF ){
        /* ignore */
        return;
    }
    append_key(key);
}


/* for debugging & testing key decoding 
* Assumes VT100 emulation, example: TeraTerm
*/
#if DEBUG_KEYS
static void debug_print_keys(void)
{
    int x;
    
    /* multi bye sequenc decode fail */
    if( CLI_common.key_decode_buf[1] ){
        CLI_printf("supports VT100 only\n");
        CLI_printf("decode fail: ");
        for( x = 0 ; CLI_common.key_decode_buf[x] ; x++ ){
            CLI_printf(" %02x", CLI_common.key_decode_buf[x] );
        }
        CLI_printf("\n");
        return;
    }
    
    if( CLI_common.key_decode_buf[0] < 0x100 ){
        CLI_printf("single key: 0x%02x\n", 
                   CLI_common.key_decode_buf[0] );
        return;
    }
    const char *cp;
#define _k(NAME)  case NAME : cp = #NAME ; break
    
    cp = NULL;
    switch( CLI_common.key_decode_buf[0] ){
        _k(KEY_UARROW);
        _k(KEY_DARROW);     
        _k(KEY_RARROW);      
        _k(KEY_LARROW);      
        _k(KEY_INSERT);
        
        _k(KEY_F1);		
        _k(KEY_F2);		
        _k(KEY_F3);		
        _k(KEY_F4);		
        _k(KEY_F5);		
        
        _k(KEY_F6);		
        _k(KEY_F7);		
        _k(KEY_F8);		
        _k(KEY_F9);		
        _k(KEY_F10);		
        _k(KEY_F11);		
        _k(KEY_F12);		
        _k(KEY_HOME);        
        _k(KEY_END);         
        _k(KEY_PAGE_UP);      
        _k(KEY_PAGE_DN);      
        _k(KEY_PF1);         
        _k(KEY_PF2);         
        _k(KEY_PF3);         
        _k(KEY_PF4);         
    default:
        cp = NULL;
        break;
    }
    if( cp ){
        CLI_printf("key: 0x%08x -> %s\n", CLI_common.key_decode_buf[0] , cp );
    } else {
        CLI_printf("key: 0x%08x -> UNKNOWN KEY\n", CLI_common.key_decode_buf[0] );
    }
}
#endif


/* peek into the keyboard and see if a key has come,
 * also UP/DN/LF/RT arrow like key decode
 */
int CLI_getkey_peek( int mSec_delay )
{
    int result;
    
    /* do we have a byte now? - then we are done */
    do {
        result = CLI_common.key_decode_buf[0];
        if( result ){
            break;
        }
        
        /* get initial key */
        result = get_key_ignore_null(mSec_delay);
        if( result == EOF ){
            return EOF;
        }
        CLI_common.key_decode_buf[0] = result;
        CLI_common.key_decode_buf[1] = 0;

	/* All fancy keys start with ESCAPE */
        if( result != 0x1b ){
	  /* if we did not get one - we are done */
	  return result;
        }
        
        /* SEE: https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_sequences */
        /* found the escape */
        
        /* if it is a sequence it should come quickly
	 * There should be very little delay between keys.
	 *
	 * thus we use a 50mSec timeout
	 *
	 * In contrast, if a human hit the ESCape key
	 * There would be a long pause (more then 50mSecs) before the next key.
	 *
	 * This of course fails if we have a "superman/woman" typing keys 
	 * at a blinding speed, but that is not a real problem we face
	 */

        
        /* prefix state */
        result = get_key_ignore_null(50);
        if( result == EOF ){
            break;
        }
        append_key(result);
        
        if( result == 'O' ){
            /* VT100keys */
            result = get_key_ignore_null(50);
            if( result != EOF ){
                goto decode;
            }
            break;
        }
        
        
        if( result != '[' ){
            break;
        }
        
        /* parameter state */
        result = get_key_ignore_null(50);
        
        while( (result >= 0x30) && (result <= 0x3f) ){
            append_key(result);
            result = get_key_ignore_null(50);
        }
        
        /* intermediate state */
        while( (result >= 0x20) && (result < 0x2f) ){
            append_key(result);
            result = get_key_ignore_null(50);
        }
        
        if( result == EOF ){
            break;
        }
        
        /* terminal state, single byte in the range of 0x40 to 0x7e */
        if( (result >= 0x40) && (result <= 0x7e) ){
        decode:
            append_key(result);
            decode_sequence();
#if DEBUG_KEYS
            debug_print_keys();
#endif
            break;
        } else {
            /* invalid terminal */
            break;
        }
    } while(0)
        ;
    return CLI_common.key_decode_buf[0];
}

/* get key from CLI console */
int CLI_getkey(int nMsec_delay )
{
    int r;
    int x;
    r = CLI_getkey_peek(nMsec_delay);
    if( r == EOF ){
        return EOF;
    }
    
    /* pop first key off front of list */  
    r = CLI_common.key_decode_buf[0];
    /* shift */
    for( x = 0 ; x < (CLI_MAX_UNGET-1) ; x++ ){
        CLI_common.key_decode_buf[x+0] = CLI_common.key_decode_buf[x+1];
    }
    /* terminate */
    CLI_common.key_decode_buf[ CLI_MAX_UNGET -1 ] = 0;
    return r;
}

/* output a string, ie: fputs() without newline */
void CLI_puts_no_nl( const char *s )
{
    while( *s ){
        CLI_putc( *s );
        s++;
    }
}

/* output a string with newline, ie: fputs() */
void CLI_puts( const char *s )
{
    CLI_puts_no_nl(s);
    CLI_putc( '\n' );
}

/* prints time now in column 0 */
void CLI_col0_timestamp(void)
{
    uint32_t now;
    int zero = ' ';
    uint32_t divisor;
    uint32_t dividend;
    
    
    if( !CLI_common.timestamps ){
        return;
    }
    
    now = CLI_time_now();
    
    /* 5 digits, plus 3 digits = 8 digits */
    /*         12345678 */
    divisor = 100000000;
    
    /* don't sprintf() (stackspace) */
    while( divisor ){
        if( divisor == 1000 ){
            zero = '0';
        }
        if( divisor == 100 ){
            CLI_putc_raw('.');
        }
        dividend = now / divisor;
        if( dividend == 0 ){
            CLI_putc_raw(zero);
        } else {
            CLI_putc_raw('0'+dividend);
            zero = '0';
        }
        now = now - (dividend * divisor);
        divisor /= 10;
    }
    CLI_putc_raw(' ');
    CLI_putc_raw('|');
    CLI_putc_raw(' ');
}


/* tab expansion, etc, and insert time in column 0 if needed */
void CLI_putc( int c )
{
    if( c == '\t' ){
        /* expand tabs at 4 */
        do {
            CLI_putc( ' ' );
        } while( CLI_common.col_num & 3 )
            ;
        return;
    }  
    if( CLI_common.col_num == 0 ){
        CLI_col0_timestamp();
    }
    if( c == '\n' ){
        CLI_putc_raw('\r');
        CLI_common.col_num = 0;
    } else {
        CLI_common.col_num += 1;
    }
    CLI_putc_raw(c);
}

/* printf for test purposes */
void CLI_printf( const char *fmt, ... )
{
    va_list ap;
    
    va_start(ap,fmt);
    CLI_vprintf( fmt, ap );
    va_end(ap);
}

static char outbuf[100] = {0};
static char gsTmpBuf[100] = {0};

/* workhorse for printf() */
void CLI_vprintf( const char *fmt, va_list ap )
{
    vsnprintf( outbuf, sizeof(outbuf)-1, fmt, ap );
    outbuf[ sizeof(outbuf) - 1 ] = 0;
    memcpy(gsTmpBuf, outbuf, sizeof(outbuf));
    if( gFilterPrintMsgFlg == 1 )
    {
    	if( checkIfFailedStringIsPresent(gsTmpBuf) == 0 )	//If failed string is not present, no need to print it on UART
    	{
    		return;
    	}
    }

    CLI_puts_no_nl( outbuf );
}


uint8_t checkIfFailedStringIsPresent(char *aBuf)
{
	uint8_t isFailedStringPresent = 0;
	const char s[3] = "<<";
	char *token;

	/* get the first token */
	token = strtok(aBuf, s);

	/* walk through other tokens */
	while( token != NULL ) {
		if(strncmp(token, "FAILED", 5) == 0 )
		{
			isFailedStringPresent = 1;
		}
		token = strtok(NULL, s);
	}
	return isFailedStringPresent;
}

