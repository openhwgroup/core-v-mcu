// DPI-C helpers for interactive UART terminal in Verilator simulation.
//   uart_terminal_init()    – put stdin in raw/no-echo mode (call once at start)
//   get_terminal_char()     – non-blocking poll; returns char 0-255, or -1 if none
//   uart_terminal_cleanup() – restore terminal settings (also auto-called via atexit)

#include <cstdlib>
#include <termios.h>
#include <unistd.h>
#include <sys/select.h>
#include "svdpi.h"

static struct termios s_saved;
static bool           s_raw = false;

static void restore_terminal() {
    if (s_raw) {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &s_saved);
        s_raw = false;
        // ensure the shell prompt lands on a fresh line after raw mode
        (void)write(STDOUT_FILENO, "\r\n", 2);
    }
}

extern "C" {

void uart_terminal_init() {
    if (!isatty(STDIN_FILENO)) return;   // piped/redirected stdin: skip raw mode
    if (tcgetattr(STDIN_FILENO, &s_saved) < 0) return;
    atexit(restore_terminal);

    struct termios raw = s_saved;
    // Disable echo and canonical (line-buffered) mode.
    // ISIG is kept enabled so Ctrl+C still delivers SIGINT.
    raw.c_lflag &= ~(tcflag_t)(ECHO | ECHOE | ECHOK | ECHONL | ICANON | IEXTEN);
    // Disable input byte transformations (CR→LF, flow control, etc.)
    raw.c_iflag &= ~(tcflag_t)(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    // 8-bit characters, no parity
    raw.c_cflag |= CS8;
    // Non-blocking: return immediately even with no input ready
    raw.c_cc[VMIN]  = 0;
    raw.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
    s_raw = true;
}

int get_terminal_char() {
    fd_set rfds;
    struct timeval tv = {0, 0};
    FD_ZERO(&rfds);
    FD_SET(STDIN_FILENO, &rfds);
    if (select(STDIN_FILENO + 1, &rfds, NULL, NULL, &tv) > 0) {
        unsigned char c;
        if (read(STDIN_FILENO, &c, 1) == 1) return (int)c;
    }
    return -1;
}

void uart_terminal_cleanup() {
    restore_terminal();
}

} // extern "C"
