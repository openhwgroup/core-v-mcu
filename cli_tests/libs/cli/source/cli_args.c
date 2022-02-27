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

#include "SDKConfig.h"

#include "libs/cli/include/cli.h"
#include "string.h"
#include "stdio.h"
#include "stdlib.h"

/* peek next arg, return NULL if there are no more args */
const char *CLI_peek_next_arg( void )
{
    const char *s;
    if( CLI_common.argx < CLI_common.argc ){
        s = CLI_common.argv[ CLI_common.argx ];
    } else {
        s = NULL;
    }
    return s;
}

/* fetch next string and if required force it to lower case */
static void do_str_fetch( char **puthere, int is_lc )
{
    char *s;
    int x,c;
    
    s = CLI_common.argv[ CLI_common.argx ];
    *puthere = s;
    if( is_lc ){
        /* in line strlower() not all platform have this function */
        
        for( x = 0 ; (c=s[x]) != 0 ; x++ ){
            if( (c >= 'A') && (c <= 'Z') ){
                c = c + 0x20;
                s[x] = c;
            }
        }
    }
    CLI_common.argx += 1;
}


/* see cli_args.h */
int CLI_string_ptr_lc_getshow( const char *name, char **puthere )
{
    return CLI_string_ptr_xx_getshow( name, puthere, 1 );
}

/* see cli_args.h */
int CLI_string_buf_lc_getshow( const char *name, char *puthere, size_t buflen )
{
    return CLI_string_buf_xx_getshow(name,puthere,buflen,1);
}

/* see cli_args.h */
int CLI_string_ptr_getshow( const char *name, char **puthere)
{
    return CLI_string_ptr_xx_getshow( name, puthere, 0);
}

/* see cli_args.h */
int CLI_string_buf_getshow( const char *name, char *puthere, size_t buflen )
{
    return CLI_string_buf_xx_getshow(name,puthere,buflen,0);
}


/* see cli_args.h */
int CLI_string_ptr_xx_getshow( const char *name, char **puthere, int is_lc )
{
    int eof;
    
    eof = EOF;
    if( CLI_is_more_args() ){
        eof = 0;
        do_str_fetch( puthere, is_lc );
    }
    CLI_printf("%s = %s\n", name, *puthere );
    return eof;
}

/* see cli_args.h */
int CLI_string_buf_xx_getshow( const char *name, char *puthere, size_t buflen, int is_lc )
{
    int eof;
    char *cp;
    size_t actual;
    
    eof = EOF;
    if( CLI_is_more_args() ){
        eof = 0;
        do_str_fetch( &cp, is_lc );
        
        /* will it fit? */
        actual = strlen(cp);
        /* account for null */
        buflen -= 1;
        if( actual > buflen ){
            CLI_error("too long, len: %d, max: %d)\n", (int)(actual),(int)(buflen));
        }
        memset( (void *)(puthere), 0, buflen+1 );
        /* above memset() put a null byte at the end for us */
        memcpy( (void *)(puthere), (void *)(cp), actual );
    }
    CLI_printf("%s = %s\n", name, puthere );
    return eof;
}


/* see cli_args.h */
void CLI_string_ptr_lc_required(const char *name, char **puthere )
{
    CLI_string_ptr_xx_required(name, puthere, 1 );
}

/* see cli_args.h */
void CLI_string_buf_lc_required(const char *name, char *puthere, size_t buflen )
{
    CLI_string_buf_xx_required(name, puthere, buflen, 1 );
}

/* see cli_args.h */
void CLI_string_ptr_required(const char *name, char **puthere )
{
    CLI_string_ptr_xx_required(name, puthere, 0 );
}

/* see cli_args.h */
void CLI_string_buf_required(const char *name, char *puthere, size_t buflen )
{
    CLI_string_buf_xx_required(name, puthere, buflen, 0 );
}

/* see cli_args.h */
void CLI_string_ptr_get_subcmd( char **puthere )
{
    if( !CLI_is_more_args() ){
        CLI_error_missing_parameter("sub-command");
    }
    do_str_fetch( puthere, 1 );
}


/* see cli_args.h */
void CLI_string_ptr_xx_required(const char *name, char **puthere, int is_lc  )
{
    if( !CLI_is_more_args() ){
        CLI_error_missing_parameter(name);
    }
    
    CLI_string_ptr_xx_getshow( name, puthere, is_lc );
}

/* see cli_args.h */
void CLI_string_buf_xx_required(const char *name, char *puthere, size_t buflen, int is_lc  )
{
    if( !CLI_is_more_args() ){
        CLI_error_missing_parameter(name);
    }
    
    CLI_string_buf_xx_getshow( name, puthere, buflen, is_lc );
}


/* see cli_args.h */
int CLI_float_getshow( const char *name, float *puthere )
{
    char *s;
    char *ep;
    int r;
    
    r = EOF;
    if( CLI_is_more_args() ){
        r = 0;
        do_str_fetch( &s, 0 );
        *puthere = strtof( s, &ep );
        if( (s==ep) || (*ep !=0 ) ){
            CLI_error_not_a_number( name, s );
        }
    }
    
    CLI_printf("%s = %f\n", name, *puthere );
    return r;
}


/* see cli_args.h */
int CLI_bool_getshow( const char *name, int *puthere )
{
    int r;
    int eof;
    char *s;
    
    eof = EOF;
    if( CLI_is_more_args() ){
        eof = 0;
        do_str_fetch( &s, 1 );
        r = -1;
	/* a list of possible "true" strings */
        if( 0 == strcmp( "enable", s )){
            r = 1;
        }
        if( 0 == strcmp( "y", s ) ){
            r = 1;
        }
        if( 0 == strcmp( "yes", s ) ){
            r = 1;
        }
        if( 0 == strcmp( "t", s ) ){
            r = 1;
        }
        if( 0 == strcmp( "true", s ) ){
            r = 1;
        }
        if( 0 == strcmp( "1", s ) ){
            r = 1;
        }
        
	/* a list of possible "false" strings */
        if( 0 == strcmp( "disable", s )){
            r = 1;
        }
        if( 0 == strcmp( "n", s ) ){
            r = 0;
        }
        if( 0 == strcmp( "no", s ) ){
            r = 0;
        }
        if( 0 == strcmp( "f", s ) ){
            r = 0;
        }
        if( 0 == strcmp( "false", s ) ){
            r = 0;
        }
        if( 0 == strcmp( "0", s ) ){
            r = 0;
        }
        
        if( r < 0 ){
            CLI_error("not-boolean: %s\n", s );
        }
        *puthere = r;
    }
    CLI_printf("%s = %s\n", name, *puthere ? "true" : "false" );
    return eof;
}

/* fetch an numeric like value */
static void i_fetch( uint64_t *pValue, void *puthere, int width )
{
    /* if width is negative, it is a signed value */
    switch( width ){
    case 8:
        *((uint64_t *)(pValue)) = *((uint8_t *)(puthere));
        break;
    case -8:
        *((int64_t *)(pValue)) = *((int8_t *)(puthere));
        break;
    case 16:
        *((uint64_t *)(pValue)) = *((uint16_t *)(puthere));
        break;
    case -16:
        *((int64_t *)(pValue)) = *((int16_t *)(puthere));
        break;
    case 32:
        *((uint64_t *)(pValue)) = *((uint32_t *)(puthere));
        break;
    case -32:
        *((int64_t *)(pValue)) = *((int32_t *)(puthere));
        break;
    case 64:
        *((uint64_t *)(pValue)) = *((uint64_t *)(puthere));
        break;
    case -64:
        *((int64_t *)(pValue)) = *((int64_t *)(puthere));
        break;
    case 'I':
        *((uint64_t *)(pValue)) = *((int *)(puthere));
        break;
    case -'I':
        *((int64_t *)(pValue)) = *((unsigned *)(puthere));
        break;
    }
}

/* save an integer like value */
static void i_store( uint64_t *pValue, void *puthere, int width )
{
    /* if width is negative, it is a signed value */
    switch( width ){
    case 8:
        *((uint8_t *)(puthere)) = *((uint64_t *)(pValue));
        break;
    case -8:
        *((int8_t *)(puthere)) = *((int64_t *)(pValue));
        break;
    case 16:
        *((uint16_t *)(puthere)) =*((uint64_t *)(pValue)) ;
        break;
    case -16:
        *((int16_t *)(puthere)) = *((int64_t *)(pValue));
        break;
    case 32:
        *((uint32_t *)(puthere)) = *((uint64_t *)(pValue));
        break;
    case -32:
        *((int32_t *)(puthere)) = *((int64_t *)(pValue));
        break;
    case 64:
        *((uint64_t *)(puthere)) = *((uint64_t *)(pValue));
        break;
    case -64:
        *((int64_t *)(puthere)) = *((int64_t *)(pValue));
        break;
    case -'I':
        *((int *)(puthere)) = *((uint64_t *)(pValue));
        break;
    case 'I':
        *((unsigned *)(puthere)) = *((uint64_t *)(pValue));
        break;
    }
}

/* see cli_args.h */
int CLI_numX_getshow_X( const char *name, void *puthere, int width, int flags )
{
    union {
        uint64_t u64;
        int64_t i64;
    } u;
    char *s;
    char *ep;
    int r;
    
    r = 0;
    if( !CLI_is_more_args() ){
        r = EOF;
        if( flags & CLI_NUMX_GETSHOW_FLAG_required ){
            CLI_error_missing_parameter(name);
        }
    }
    
    if( r != EOF ){
        do_str_fetch( &s, 0 );
        
        if( width < 0 ){
            /* signed */
            u.i64 = strtoll( s, &ep, 0 );
        } else {
            /* unsigned */
            u.u64 = strtoull( s, &ep, 0 );
        }
        
        if( (s==ep) || (*ep != 0) ){
            CLI_error_not_a_number( name, s );
        }
        i_store( &u.u64, puthere, width );
    }
    
    /* fetch value so we can print current value */
    i_fetch( &u.u64, puthere, width );
    if( flags & CLI_NUMX_GETSHOW_FLAG_hex ){
        if( width < 0 ){
            width = -width;
        }
        width = width / 4;
        //CLI_printf("%s = 0x%0*llx\n", name, width, u.u64 );
        CLI_printf("%s = 0x%0*lx\n", name, width, (uint32_t)u.u64 );
    } else {
        /* we print as decimal, signed */
        if( (width < 0) || (width=='I') ){
            //CLI_printf("%s = %lld\n", name, u.i64 );
			CLI_printf("%s = %ld\n", name, (int)u.i64 );
        } else {
            /* unsigned */
            //CLI_printf("%s = %llu\n", name, u.u64 );
			CLI_printf("%s = %lu\n", name, (int)u.u64 );
        }
    }
    return r;
} 

/* see cli_args.h */
int CLI_unsigned_getshow( const char *name, unsigned *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, 'I', CLI_NUMX_GETSHOW_FLAG_none );
}


/* see cli_args.h */
int CLI_int_getshow( const char *name, int *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, -'I', CLI_NUMX_GETSHOW_FLAG_none );
}

/* see cli_args.h */
int CLI_int8_getshow( const char *name, int8_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, -8, CLI_NUMX_GETSHOW_FLAG_none);
}


/* see cli_args.h */
int CLI_int16_getshow( const char *name, int16_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, -16, CLI_NUMX_GETSHOW_FLAG_none );
}

/* see cli_args.h */
int CLI_int32_getshow( const char *name, int32_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, -32, CLI_NUMX_GETSHOW_FLAG_none );
}

/* see cli_args.h */
int CLI_int64_getshow( const char *name, int64_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, -64, CLI_NUMX_GETSHOW_FLAG_none );
}

/* see cli_args.h */
int CLI_uint8_getshow( const char *name, uint8_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, 8, CLI_NUMX_GETSHOW_FLAG_none );
}


/* see cli_args.h */
int CLI_uint16_getshow( const char *name, uint16_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, 16, CLI_NUMX_GETSHOW_FLAG_none);
}

/* see cli_args.h */
int CLI_uint32_getshow( const char *name, uint32_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, 32, CLI_NUMX_GETSHOW_FLAG_none );
}

/* see cli_args.h */
int CLI_uint64_getshow( const char *name, uint64_t *puthere )
{
    return CLI_numX_getshow_X( name, (void *)puthere, 64, CLI_NUMX_GETSHOW_FLAG_hex );
}

/* see cli_args.h */
void CLI_unsigned_required( const char *name, unsigned *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, 'I', CLI_NUMX_GETSHOW_FLAG_required );
}


/* see cli_args.h */
void CLI_int_required( const char *name, int *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, -'I',CLI_NUMX_GETSHOW_FLAG_required);
}

/* see cli_args.h */
void CLI_int8_required( const char *name, int8_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, -8, CLI_NUMX_GETSHOW_FLAG_required );
}


/* see cli_args.h */
void CLI_int16_required( const char *name, int16_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, -16, CLI_NUMX_GETSHOW_FLAG_required);
}

/* see cli_args.h */
void CLI_int32_required( const char *name, int32_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, -32, CLI_NUMX_GETSHOW_FLAG_required );
}

/* see cli_args.h */
void CLI_int64_required( const char *name, int64_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, -64, CLI_NUMX_GETSHOW_FLAG_required );
}

/* see cli_args.h */
void CLI_uint8_required( const char *name, uint8_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, 8, 
                       CLI_NUMX_GETSHOW_FLAG_required+
                           CLI_NUMX_GETSHOW_FLAG_hex  );
}


/* see cli_args.h */
void CLI_uint16_required( const char *name, uint16_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, 16, 
                       CLI_NUMX_GETSHOW_FLAG_required+
                           CLI_NUMX_GETSHOW_FLAG_hex  );
}

/* see cli_args.h */
void CLI_uint32_required( const char *name, uint32_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, 32, 
                       CLI_NUMX_GETSHOW_FLAG_required+
                           CLI_NUMX_GETSHOW_FLAG_hex  );
}

/* see cli_args.h */
void CLI_uint64_required( const char *name, uint64_t *puthere )
{
    CLI_numX_getshow_X( name, (void *)puthere, 64, 
                       CLI_NUMX_GETSHOW_FLAG_required+
                           CLI_NUMX_GETSHOW_FLAG_hex  );
}
