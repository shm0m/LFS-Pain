#include <stdint.h>
#include "keyboard.h"
#include "isr.h"
#include "vga.h"
#include "shell.h"
#include "irq.h"


#define CP437_E_ACUTE  ((char)0x82)
#define CP437_E_GRAVE  ((char)0x8A)
#define CP437_C_CEDILLA ((char)0x87)
#define CP437_A_GRAVE  ((char)0x85)
#define CP437_U_GRAVE  ((char)0x97)

static const char azerty_map[128] = {
  0, 27, '&', CP437_E_ACUTE, '"', '\'', '(', '-', CP437_E_GRAVE, '_', CP437_C_CEDILLA, CP437_A_GRAVE, ')', '=', '\b',
  '\t','a','z','e','r','t','y','u','i','o','p','^','$','\n',0,
  'q','s','d','f','g','h','j','k','l','m',CP437_U_GRAVE,'`',0,'*',
  'w','x','c','v','b','n',',',';',';',':','!',0,'*',0,' ',
};

static inline uint8_t inb(uint16_t p) {
    uint8_t v;
    __asm__ volatile("inb %1,%0" : "=a"(v) : "Nd"(p));
    return v;
}

static void irq1_handler(void);

void keyboard_init(void) {
    irq_install_handler(1, irq1_handler);
}

static void irq1_handler(void) {
    uint8_t scancode = inb(0x60);
    if (scancode < 128) {
        char c = azerty_map[scancode];
        if (c) {
            shell_on_char(c);
        }
    }
}
