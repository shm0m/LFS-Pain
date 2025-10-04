#include "vga.h"
#include "idt.h"
#include "pic.h"
#include "pit.h"
#include "keyboard.h"
#include "shell.h"
#include "irq.h"

void kmain(void) {
    vga_init();
    vga_puts("hey Ca marche.\n");
    vga_puts("IDT/PIC/PIT ok. Tape sur le clavier...\n");

    idt_init();
    pic_init();
    irq_init();
    pit_init(100);
    keyboard_init();
    shell_init();

    __asm__ __volatile__("sti");

    for (;;) {
        __asm__ __volatile__("hlt");
    }
}

