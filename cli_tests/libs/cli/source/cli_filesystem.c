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


#if FEATURE_CLI_FILESYSTEM

#include "cli.h"
#include "string.h"
#include "stdio.h"
#include "stdlib.h"
#include "ql_time.h"
#include "ql_fs.h" /* fix me: Move to Indra's solution */

/* simple DIR command */
static void do_dir( const struct cli_cmd_entry *pEntry )
{
    char *pattern;
    struct QLFS_file_find_info find_info;

    QLFS_FindFirst_Init( &find_info, QLFS_DEFAULT_FILESYTEM );
    
    /* get search pattern */
    if( !CLI_is_more_args() ){
        /* tool is goofy, "*.*" does not work like you think */
        pattern = "*";
    } else {
        CLI_string_ptr_required( "pattern", &pattern );
    }
    
    /* make output parsable by script */
    CLI_printf("dir-begin: %s\n", pattern);
    QLFS_FindFirst( &find_info, pattern );
    
    while( !find_info.eof ){
        /* my date time format is simple enough */
        struct tm tm;
        ql_localtime_r( &find_info.dir_entry.unix_time_filetime, &tm );
        CLI_printf("%04d/%02d/%02d %02d:%02d:%02d ",
                   tm.tm_year + 1900,
                   tm.tm_mon + 1,
                   tm.tm_mday,
                   tm.tm_hour,
                   tm.tm_min,
                   tm.tm_sec );
        CLI_printf( "   <%c%c%c%c> ",
                   (find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_DIRECTORY ? 'd' : ' '),
                   (find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_HIDDEN    ? 'h' : ' '),
                   (find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_SYSTEM    ? 's' : ' '),
                   (find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_RDONLY    ? 'r' : ' '),
                   (find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_ARCHIVE   ? 'a' : ' ') );
        
        /* dirs have no size (actually they do, but we don't show it */
        if( find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_DIRECTORY ){
            CLI_printf("          ");
        } else {
            CLI_printf("%10d", (int)(find_info.dir_entry.filesize_bytes) );
        }
        
        CLI_printf("   %s\n", find_info.dir_entry.filename );
        
        QLFS_FindNext( &find_info );
    }
    QLFS_FindEnd( &find_info );
    CLI_printf("dir-end:\n");
    
    CLI_printf("\n");
}

/* ERASE a file */
static void do_erase( const struct cli_cmd_entry *pEntry )
{
    char *name;
    int success;
    
    CLI_string_ptr_required( "filename", &name );
    /* FUTURE_TODO: support wild card? */
    
    CLI_printf("delete: %s\n", name );
    success = QLFS_RmFile( QLFS_DEFAULT_FILESYTEM, name );
    if( success == 0 ){
        CLI_printf("delete-result: 0 # success\n");
    } else {
        CLI_printf("delete-result: fail\n");
    }
}

/* print or cat the specified file */
static void common_dump( int is_hex )
{
    char *name;
    int actual;
    QLFILE_Handle *pFile;
    int x;
    intptr_t addr;
    struct QLFS_file_find_info find_info;
    /* static so it is not on the stack */
    static  uint8_t buf[ 128 ];
    
    CLI_string_ptr_required("filename", &name);
    
    
    if( strpbrk( name, "?*" ) != NULL ){
        CLI_error("cannot cat/dump wildcards: %s\n", name );
    }
    
    /* get file details */
    QLFS_stat( name, &find_info, QLFS_DEFAULT_FILESYTEM );
    if( find_info.eof ){
        CLI_error("no-such-file: %s\n", name );
    }
    
    if( find_info.dir_entry.msdos_attr & QLFS_FILE_ATTR_DIRECTORY ){
        CLI_error("cannot cat/dump directories: %s\n", name );
    }

    /* open the file */
    pFile = QLFS_fopen( QLFS_DEFAULT_FILESYTEM, name, "rb" );
    if( pFile == NULL ){
        CLI_error("cannot open: %s\n", name );
    }
    
    /* start parsable output incase CLI is used with test scripts */
    CLI_printf( "start-%s: %d %s\n", 
               is_hex ? "hex-dump" : "cat-file", 
               find_info.dir_entry.filesize_bytes, name );
    
    addr = 0;
    for(;;){
        actual = QLFS_fread( QLFS_DEFAULT_FILESYTEM, pFile, &buf, sizeof(buf), 1 );
        if( actual == 0 ){
            break;
        }
        if( is_hex ){
            CLI_hexdump( addr, buf, actual );
            addr += actual;
        } else {
            for( x = 0 ; x < actual ; x++ ){
                CLI_putc( buf[x] );
            }
        }
        addr += actual;
    }

    QLFS_fclose( QLFS_DEFAULT_FILESYTEM, pFile );
    pFile = NULL;
    /* end parsable */
    if( CLI_common.col_num != 0 ){
        CLI_putc('\n');
    }
    /* end parsable for test scripts */
    CLI_printf( "end-%s: %d %s\n", 
               is_hex ? "hex-dump" : "cat-file", 
               find_info.dir_entry.filesize_bytes, name );
}

/* handler for hexdump command */
static void do_hexdump( const struct cli_cmd_entry *pEntry )
{
    common_dump(1);
}

/* handler for cat command */
static void do_cat( const struct cli_cmd_entry *pEntry )
{
    common_dump(0);
}

/* show current mount state */
static void do_mount_show( const struct cli_cmd_entry *pEntry )
{
    CLI_printf("sd-card-is-mounted: %d\n", (QLFS_DEFAULT_FILESYTEM != NULL) );
}

/* unmount filesystem */
static void do_umount(const struct cli_cmd_entry *pEntry )
{
    (void)(pEntry);
    QLFS_mount_as_default( FREERTOS_NONE_MOUNTED );
    CLI_printf("Unmounted\n");
}

/* mount filesystem */
static void do_mount( const struct cli_cmd_entry *pEntry )
{
    QLFS_mount_as_default( FREERTOS_NONE_MOUNTED );
    QLFS_mount_as_default( FREERTOS_SPI_SD );
    CLI_printf("sd-card-mount: %s\n", QLFS_DEFAULT_FILESYTEM != NULL  ? "success" : "fail" );
    if(QLFS_DEFAULT_FILESYTEM){
        CLI_printf("Location: %s\n", QLFS_DEFAULT_FILESYTEM->mountVolume );
    }
}


/* menu for file activity */
const struct cli_cmd_entry mount_menu[] = 
{
    CLI_CMD_SIMPLE("show", do_mount_show, "show mount status"),
    CLI_CMD_SIMPLE("mount", do_mount, "mount/remount sd card"),
    CLI_CMD_SIMPLE("umount", do_umount, "unmount sd card"),
    CLI_CMD_TERMINATE()
};



const struct cli_cmd_entry cli_file_menu[] =
{
    CLI_CMD_SIMPLE( "dir", do_dir, "directory listing" ),
    CLI_CMD_SIMPLE( "rm" , do_erase, "erase a file" ),
    CLI_CMD_SIMPLE( "erase", do_erase, "erase a file" ),
    CLI_CMD_SIMPLE( "del", do_erase, "erase a file"),
    CLI_CMD_SIMPLE( "dump", do_hexdump, "hexdump a file" ),
    CLI_CMD_SIMPLE( "cat", do_cat, "print/cat a file" ),
    CLI_CMD_SUBMENU( "mount", mount_menu, "remount filesystem" ),
    CLI_CMD_TERMINATE()
};


#endif
