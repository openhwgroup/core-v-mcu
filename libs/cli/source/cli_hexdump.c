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
#include "stdio.h"

/* dump as hex, this data on the CLI console */
void CLI_hexdump( uint32_t addr, const void *pData, size_t nBytes )
{
    int x;
    int c;
    const uint8_t *p8;
    
    p8 = (const uint8_t *)(pData);
    while( nBytes > 16 ){
        CLI_hexdump( addr, (void *)(p8), 16 );
        addr += 16;
        p8 += 16;
        nBytes -= 16;
    }
    
    if( nBytes == 0 ){
        return;
    }
    
    CLI_printf("%08x: ", addr );
    
    for( x = 0 ; x < 16 ; x++ ){
        if( x < nBytes ){
            CLI_printf("%02x", p8[x] );
        } else {
            CLI_putc(' ');
            CLI_putc(' ');
        }
        CLI_putc( (x == 7) ? '-' : ' ' );
    }
    CLI_putc( ' ' );
    CLI_putc( '|' );
    
    for( x = 0 ; x < 16 ; x++ ){
        if( x < nBytes ){
            c = p8[x];
            if( (c < 0x20) || (c > 0x7e) ){
                c = '.';
            }
        } else {
            c = ' ';
        }
        CLI_putc( c );
        if( x == 7 ){
            CLI_putc( '-' );
        }
    }
    CLI_putc( '|' );
    CLI_putc('\n');
}







