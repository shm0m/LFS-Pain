#include "shell.h"
#include "vga.h"
#include "pit.h"
#include <stdbool.h>

static char buffer[128];
static int len = 0;

void shell_init(void) {
    vga_puts("\nPain-OS> ");
}

static void execute_cmd() {
    buffer[len] = 0;

    if (len == 0) return;

    if (!__builtin_strcmp(buffer, "help")) {
        vga_puts("\nCommandes dispo: help, ticks");
    } else if (!__builtin_strcmp(buffer, "ticks")) {
        unsigned long t = (unsigned long)pit_ticks();
        char tmp[32];
        int i = 0;
        if (t == 0) tmp[i++] = '0';
        while (t > 0) {
            tmp[i++] = '0' + (t % 10);
            t /= 10;
        }
        for (int j = i - 1; j >= 0; j--) {
            char s[2] = { tmp[j], 0 };
            vga_puts(s);
        }
    } else {
        vga_puts("\nCommande inconnue");
    }

    len = 0;
    vga_puts("\nPain-OS> ");
}

void shell_on_char(char c) {
    if (c == '\n') {
        execute_cmd();
    } else if (c == '\b') {
        if (len > 0) {
            len--;
            vga_puts("\b");
        }
    } else if (len < (int)(sizeof(buffer) - 1)) {
        buffer[len++] = c;
        char s[2] = { c, 0 };
        vga_puts(s);
    }
}
