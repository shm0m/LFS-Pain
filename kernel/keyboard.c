#include <stdint.h>
#include "keyboard.h"
#include "pic.h"
#include "vga.h"
#include "shell.h"


static const char azerty_map[128] = {
  0, 27, '&', 'é', '"', '\'', '(', '-', 'è', '_', 'ç', 'à', ')', '=', '\b',
  '\t','a','z','e','r','t','y','u','i','o','p','^','$','\n',0,
  'q','s','d','f','g','h','j','k','l','m','ù','`',0,'*',
  'w','x','c','v','b','n',',',';',';',':','!',0,'*',0,' ',
};

static inline uint8_t inb(uint16_t p) {
    uint8_t v;
    __asm__ volatile("inb %1,%0" : "=a"(v) : "Nd"(p));
    return v;
}

void irq1_handler(void) {
    uint8_t scancode = inb(0x60);
    if (scancode < 128) {
        char c = azerty_map[scancode];
        if (c) {
            shell_on_char(c);
        }
    }
    pic_eoi(1);
}
