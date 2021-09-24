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
