

void dbg_ch_raw( int c )
{
    	udma_uart_writeraw(1, 1, &c);
}

void dbg_nl( void )
{
    dbg_ch_raw('\r');
    dbg_ch_raw('\n');
}

void dbg_ch( int ch )
{
    if( ch == '\n' ){
        dbg_nl();
    } else {
        dbg_ch_raw(ch);
    }
}

void dbg_str(const char *s)
{
    const char *cp;

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

void dbg_hex8( unsigned long u32 )
{
    dbg_hex4( (int)(u32 >> 4) );
    dbg_hex4( (int)(u32 >> 0) );
}

void dbg_hex16(unsigned long u32)
{
    dbg_hex8( u32 >> 8 );
    dbg_hex8( u32 >> 0 );
}

void dbg_hex32(unsigned long u32)
{
    dbg_hex16( u32 >> 16 );
    dbg_hex16( u32 >>  0 );
}
