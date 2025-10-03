#include "vga.h"
#include "idt.h"
#include "pic.h"
#include "pit.h"

void kmain(void) {
    vga_init();
    vga_puts("hey ça marche.\n");

    idt_init();
    pic_init();
    pit_init(100);

    vga_puts("IDT/PIC/PIT ok. Type on keyboard...\n");
    for(;;) { __asm__ __volatile__("hlt"); }
}
