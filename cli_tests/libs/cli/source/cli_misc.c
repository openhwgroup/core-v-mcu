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

/* 
 * Misc CLI functions dealing with errors, and arguments
 */

/* are there more parameters on the command line? */
int CLI_is_more_args( void )
{
    if( CLI_common.argx == CLI_common.argc ){
        return 0;
    } else {
        return 1;
    }
}

/* print an error and do not return */
void CLI_error( const char *fmt, ... )
{
    va_list ap;
    
    va_start(ap,fmt);
    CLI_verror( fmt, ap );
    /* this never happens */
    va_end(ap);
}

/* The required parameter is missing, print an error message */
void CLI_error_missing_parameter( const char *name )
{
    CLI_error("missing: %s\n" , name );
}

/* the parameter is not a number it should be, print error message */
void CLI_error_not_a_number( const char *name, const char *value )
{
    CLI_error("not-a-number: %s = %s\n", name,value );
}

/* verify there are no more parameters on the command line */
void CLI_no_more_args(void)
{
    if( CLI_common.argx == CLI_common.argc ){
        return;
    }
    
    CLI_error("extra parameters after: %s\n",
              CLI_common.argv[ CLI_common.argx -1 ] );
}

/* expect at least N more parameters */
void CLI_n_more_args( const char *name, int n )
{
    if( (CLI_common.argx+n) > CLI_common.argc ){
        return;
    }
    
    CLI_error("missing parameters after: %s, need %d more\n",
              CLI_common.argv[ CLI_common.argx -1 ],
              n);
}
