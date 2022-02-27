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

#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"
#include "libs/cli/include/cli.h"
#include "string.h"

/*
 * This is the primary CLI task.
 * It basically is a loop waiting for keys to come from the human.
 */


/* get top most stack element */
const struct cli_cmd_entry *CLI_cmd_stack_peek(void)
{
    return CLI_common.cmd_stack[ CLI_common.cmd_stack_idx-1 ].selected_cmd;
}

/* replace top most command stack with *THIS* command */
void CLI_cmd_stack_replace(const struct cli_cmd_entry *pCmd)
{
    CLI_common.cmd_stack[ CLI_common.cmd_stack_idx-1 ].selected_cmd = pCmd;
}

/* remove an entry from the command stack */
void CLI_cmd_stack_pop(void)
{
    CLI_common.cmd_stack_idx--;
    if( CLI_common.cmd_stack_idx < 0 ){
        CLI_cmd_stack_clear();
        CLI_error("CMD stack underflow?\n");
    }
    
    CLI_common.cmd_stack[CLI_common.cmd_stack_idx].list_top = NULL;
    CLI_common.cmd_stack[CLI_common.cmd_stack_idx].selected_cmd = NULL;
    
    if(CLI_common.cmd_stack_idx==0){
        CLI_cmd_stack_push(CLI_common.pMainMenu);
    }
}

/* wack/clear the command stack returning to the top most set of commands */
void CLI_cmd_stack_clear(void)
{
    CLI_common.cmd_stack_idx = 0;
    memset( (void *)(&(CLI_common.cmd_stack[0])), 0, sizeof(CLI_common.cmd_stack) );
    CLI_cmd_stack_push( CLI_common.pMainMenu );
}

/* push this set of commands on to the stack */
void CLI_cmd_stack_push( const struct cli_cmd_entry *pNewItem )
{
    if( CLI_common.cmd_stack_idx >= CLI_MAX_CMD_DEPTH ){
        CLI_cmd_stack_clear();
        CLI_error("too many nested commands\n");
    }
    
    CLI_common.cmd_stack[ CLI_common.cmd_stack_idx ].list_top     = pNewItem;
    CLI_common.cmd_stack[ CLI_common.cmd_stack_idx ].selected_cmd = pNewItem;
    CLI_common.cmd_stack_idx += 1;
}

/* power up init */
void CLI_init( const struct cli_cmd_entry *pMainMenu )
{
    memset( (void *)(&CLI_common), 0, sizeof(CLI_common) );
    CLI_common.pMainMenu = pMainMenu;
    CLI_cmd_stack_clear();
}

void CLI_print_prompt( void )
{
    int x;
    int n;
    n = CLI_common.cmd_stack_idx-1;
    
    CLI_printf("[%d] ", n );
    for( x = 0 ; x < n ; x++ ){
        CLI_printf("%s ", CLI_common.cmd_stack[x].selected_cmd->name );
    }
    CLI_printf("> ");
}


/* exit, or go up one in the nested command prompt */
static void handle_exit( const struct cli_cmd_entry *pEntry )
{
    (void)pEntry;
    
    if( CLI_common.cmd_stack_idx == 1 ){
        /* can't go up */
        CLI_printf("(at top)\n");
    } else {
        CLI_cmd_stack_pop();
    }
}


/* forward decl, 'help' needs to reference this */
static void handle_help( const struct cli_cmd_entry *pEntry );

/* list of built in standard commands */
static const struct cli_cmd_entry std_cmds[] = {
    CLI_CMD_SIMPLE( "exit", handle_exit, "exit/leave menu" ),
    CLI_CMD_SIMPLE( "help", handle_help, "show help" ),
    CLI_CMD_SIMPLE( "?"   , handle_help, "show help" ),
    CLI_CMD_TERMINATE()
};

static void handle_help( struct cli_cmd_entry const *pEntry)
{
    int x;
    const struct cli_cmd_entry *pCmd;
    const struct cli_cmd_entry *cmds[2];
    
    CLI_printf("help-path: ");
    if( CLI_common.cmd_stack_idx > 1  ){
        CLI_printf("%s", CLI_common.cmd_stack[0].selected_cmd->name );
        for( x = 1 ; x < CLI_common.cmd_stack_idx-1 ; x++ ){
            CLI_printf("-> %s", CLI_common.cmd_stack[x].selected_cmd->name );
        }
    } else {
        CLI_printf("(top)");
    }
    CLI_printf("\n");
    
    cmds[0] = CLI_common.cmd_stack[ CLI_common.cmd_stack_idx-1 ].list_top;
    cmds[1] = std_cmds;
    
    for( x = 0 ; x < 2 ; x++ ){
        pCmd = cmds[x];
        while( pCmd->name ){
            CLI_printf("%-15s", pCmd->name );
            if( pCmd->help ){
                CLI_printf("- %s", pCmd->help );
            }
            CLI_printf("\n");
            pCmd++;
        }
    }
    CLI_printf("help-end:\n");
}





/* look up the current cmd word in the current menu and call that handler */
void
CLI_dispatch_subcmd( void )
{
    int x;
    int found;
    const struct cli_cmd_entry *cmds[2];
    const struct cli_cmd_entry *pCmd;
    char *cmd;
    
    if( !CLI_is_more_args() ){
        return;
    }
    
    
    CLI_string_ptr_get_subcmd( &cmd );
    
    cmds[0] = CLI_common.cmd_stack[ CLI_common.cmd_stack_idx-1 ].list_top;
    cmds[1] = std_cmds;
    
    found = 0;
    for( x = 0 ; (!found) && (x < 2) ; x++ ){
        pCmd = cmds[x];
        while( pCmd->name && !found ){
            if( 0 == strcmp( cmd, pCmd->name ) ){
                found = 1;
                break;
            }
            pCmd += 1;
        }
    }

    /* If user is PASTING code from NOTEPAD, they can't easily encode a ^C 
     * so - we quitely accept the command "^c" as if the user typed ControlC
     */
    if( 0 == strcmp( "^c", cmd ) ){
        CLI_printf("**simulated-^C**\n");
        CLI_cmd_stack_clear();
        return;
    }
    if( !found ){
        CLI_error("no such command: %s\n", cmd );
    }
    
    
    /* found */
    
    /* Setup the path command */
    CLI_cmd_stack_replace( pCmd );
    /* then call the handler */
    (*(pCmd->pHandler))( pCmd );
}



/* We have a command, parse the line into argc and argv */
static void CLI_parse_cmd(void)
{
    char *cp1;
    char *cp2;
    char *save;
    CLI_common.argc = 0;
    CLI_common.argx = 0;
    memset( (void *)(CLI_common.argv), 0, sizeof(CLI_common.argv) );
    
    memcpy( (void *)(CLI_common.chopped_cmdline),
           (void *)(CLI_common.cmdline),
           sizeof(CLI_common.cmdline));
    
    cp1 = CLI_common.chopped_cmdline;
    
    for(;;){
        /* TODO_FUTURE: add support for quoted strings */
        
        cp2 = strtok_r( cp1, " \t", &save );
        /* no more? */
        if( cp2 == NULL ){
            break;
        }
        
        /* is it a comment? */
        if( *cp2 == '#' ){
            /* comment ignore rest of line */
            break;
        }
        
        /* continue tokenizing line */
        cp1 = NULL;
        if( CLI_common.argc >= CLI_MAX_CMD_DEPTH ){
            CLI_error("Too many parameters, max: %d\n",CLI_MAX_CMD_DEPTH);
        }
        CLI_common.argv[ CLI_common.argc ] = cp2;
        CLI_common.argc += 1;
    }
}

/*
* Handle a submenu item
*/
void
CLI_submenu_handler( const struct cli_cmd_entry *pEntry )
{
    pEntry = (const struct cli_cmd_entry *)(pEntry->cookie);
    
    /* make this the top most command list */
    
    CLI_cmd_stack_push(pEntry);
    if( CLI_is_more_args() ){
        CLI_dispatch_subcmd();
        if( CLI_common.entered_sub_menu ){
            /* don't pop stack, user will use exit */
        } else {
            CLI_cmd_stack_pop();
        }
    } else {
        CLI_common.entered_sub_menu = 1;
    }
}


/* core workhorse for error */
void CLI_verror( const char *fmt, va_list ap )
{
    if( CLI_common.col_num != 0 ){
        CLI_putc('\n');
    }
    CLI_puts_no_nl("ERROR: ");
    CLI_common.error_count += 1;
    CLI_vprintf( fmt, ap );

    /* this does not return, we land back at the top of dispatch()
     * where we will cleanup the command stack.
     */
    longjmp( (unsigned long long*)&CLI_common.error_jump , 1);
    configASSERT(0);
}


void CLI_dispatch(void)
{
    int x;
    int old_stack;
    CLI_parse_cmd();
    if( CLI_common.argc == 0 ){
        return;
    }
    
    /*
    * Option 1
    *----------------------------
    * A command might be like:
    *       foo bar run dog 123
    *
    *  The top level command is "foo"
    *  With sub comands, bar, run and dog
    *  Put another way - 4 total levels.
    *
    * In this example, the terminal command is "dog" with a parameter 123
    * In that case, the user stays at he "root" level 0 (top) command.
    * 
    *----------------------------
    * Option 2, the user might type:
    *        foo <cr>  [they are now in the foo command]
    *        bar <cr>  [they are now in the bar command]
    *        run <cr>  [the run command]
    *        dog 123 <cr>  Execute the command.
    *        exit      Leave the run command
    *        exit      Leave the bar command
    *        exit      Leave the foo command
    *
    * And there maybe errors during process.
    * We handle this via setjmp.
    */
    
    
    /* Setup the long jump.
    *
    * Return value = 0 - initial call.
    * Return value = 1 - an error occured, we must "pop the cmd stack"
    */
    CLI_common.entered_sub_menu = 0;
    old_stack = CLI_common.cmd_stack_idx;
    x = setjmp( (unsigned long long*)&CLI_common.error_jump );
    if( x == 0 ){
        /* jump was set */
        CLI_dispatch_subcmd();
    } else {
        /* an error occurred, "long jump" cmd stack */
        CLI_common.entered_sub_menu = 1;
        CLI_common.cmd_stack_idx = old_stack;
        for( x = old_stack ; x < CLI_MAX_CMD_DEPTH ; x++ ){
            CLI_common.cmd_stack[x].list_top = NULL;
            CLI_common.cmd_stack[x].selected_cmd = NULL;
        }
        
        /* Discard entire user buffer they may have pasted
	 * 
	 * The problem statement is this:
	 *
	 * User has a long sequence of commands, say 10 commands.
	 * one of those commands, ie: Command #4 is wrong.
	 *
	 * We want to *STOP* processing all commands after command 4.
	 *
	 * TERA term is PASTING so it is typing fast...
	 * We can use a timeout (ie: 10mSecs, or 100 char periods)
	 * to detect when tera term is done pasting text.
	 */
        for(;;){
            /* using 10mSecs handles delays from pasting */
            /* and is not really noticeable by humans. */
            x = CLI_getkey( 10 );
            if( x == EOF ){
                break;
            } else {
                /* toss the key the pressed */
            }
        }
    }
}



/* handle each byte into the current command line */
void CLI_rx_byte( int c )
{
    static const char _backspace[] = "\b \b";
    int x;
    static int last_was_cr;
    
    /* handle CR/LF
    * and CR
    * and LF 
    * As a terminator
    */
    if( last_was_cr && (c =='\n') ){
        /* make CR/LF look like a single \n */
        last_was_cr = 0;
        return;
    }
    
    if( c == '\r' ){
        /* map to newline */
        c = '\n';
        last_was_cr = 1;
    } else {
        last_was_cr = 0;
    }
    
    /* we commonly need the len so get it always */
    /* todo: Future, would be nice to have up/dn arrow support cmd history */
    /* Todo: Would be nice if we had fancy editing of the command line */
    
    x = strlen( CLI_common.cmdline );
    switch( c ){
    case 0x03: /* Control-C */
        /* Acknowedge the key, also see the Simualted ^C in command dispatch  */
        CLI_printf(" **^C**\n");
        CLI_cmd_stack_clear();
        memset( (void *)(&(CLI_common.cmdline[0])), 0, sizeof(CLI_common.cmdline) );
        CLI_print_prompt();
        break;
    case 0x1b: /* ESCAPE key erases all bytes */
      /* note: this is different then ESC as a prefix to a CSI sequence (arrow key)
       * See arrow key decoding in CLI_getkey() code
       */
        if( x == 0 ){
            /* beep */
            CLI_beep();
            break;
        }
        /* back over */
        while( x ){
            CLI_puts_no_nl(_backspace);
            x--;
        }
        memset( CLI_common.cmdline, 0, sizeof(CLI_common.cmdline) );
        break;
    case '\b': /* backspace */
    case 0x7F: /* delete */
        if( x == 0 ){
            CLI_beep();
            break;
        }
        CLI_puts_no_nl(_backspace);
        x--;
        CLI_common.cmdline[x] = 0;
        break;
    case '\n':
        CLI_putc('\n');
	/* dispatch the command */
        CLI_dispatch();
	
	/* 
	 * NOTE: Above dispatch() call might not return!
	 * If an error occurs, the long jump will occur.
	 */
	
        /* clean up from last */  
        memset( (void *)(&CLI_common.cmdline[0]), 0, sizeof(CLI_common.cmdline) );
        /* print new prompt */
        CLI_print_prompt();
        break;
    case '\t':
        /* future: add command completion */
        /* treat as space */
        c = ' ';
        /* fallthrough */
    default:
        /* if NOT in ASCII range (function keys, arrow keys, etc)*/
        if( (c < 0x20) || (c >= 0x7f) ){
            CLI_beep();
            break;
        }
        if( x >= (sizeof(CLI_common.cmdline)-1) ){
	    /* too much */
	    CLI_beep();
        } else {
   	    /* Append */
            CLI_common.cmdline[x+0] = c;
            CLI_common.cmdline[x+1] = 0;
            /* echo */
            CLI_putc(c);
        }
        break;
    }

}


