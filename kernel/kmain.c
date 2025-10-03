#include "vga.h"
#include "idt.h"
#include "pic.h"
#include "pit.h"

#include "shell.h"

void kmain(void) {
    vga_init();
    vga_puts("hey Ca marche.\n");
    vga_puts("IDT/PIC/PIT ok. Tape sur le clavier...\n");

    idt_init();
    pic_init();
    pit_init(100);

    shell_init();

    for (;;) {
        __asm__ __volatile__("hlt");
    }
}

