#include <stdint.h>
#include "irq.h"
#include "idt.h"
#include "pic.h"
#include "vga.h"

// Table des stubs IRQ (32..47) exposée par isr_stubs.asm
extern uint32_t irq_stub_table[];

// callbacks installés par les drivers (PIT=0, KBD=1, ...)
static irq_handler_t handlers[16] = {0};

void irq_install_handler(int irq, irq_handler_t h) {
    if (irq >= 0 && irq < 16) handlers[irq] = h;
}

void irq_uninstall_handler(int irq) {
    if (irq >= 0 && irq < 16) handlers[irq] = 0;
}

void irq_common_handler(uint32_t int_no) {
    int irq = (int)int_no - 32;           // mappe 0x20..0x2F -> 0..15

    // (debug) affiche quelle IRQ est arrivée
    if (irq >= 0 && irq < 16) {
        char s[] = "[IRQ 00]\n";
        s[5] = '0' + (irq / 10);
        s[6] = '0' + (irq % 10);
        vga_puts(s);

        // appelle le handler enregistré (si présent)
        if (handlers[irq]) handlers[irq]();
        // très important : fin d’interruption
        pic_eoi(irq);
    } else {
        // IRQ hors range -> EOI global par sécurité (maître)
        pic_eoi(0);
    }
}

void irq_init(void) {
    // installe les 16 entrées IRQ dans l’IDT (vecteurs 0x20..0x2F)
    for (int i = 0; i < 16; i++) {
        uint32_t stub = irq_stub_table[i];
        idt_set_gate(32 + i, stub, 0x08, 0x8E);
    }
    vga_puts("[irq: idt set]\n");
}
