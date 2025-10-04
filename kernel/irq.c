#include "irq.h"
#include "idt.h"
#include "pic.h"

extern uint32_t irq_stub_table[];            // défini dans boot/isr_stubs.asm

static irq_handler_t handlers[16] = {0};

void irq_install_handler(int irq, irq_handler_t h) {
    if (irq >= 0 && irq < 16) handlers[irq] = h;
}

void irq_uninstall_handler(int irq) {
    if (irq >= 0 && irq < 16) handlers[irq] = 0;
}

void irq_common_handler(uint32_t int_no) {
    int irq = (int)int_no - 32;              // 0..15
    if (irq >= 0 && irq < 16 && handlers[irq]) handlers[irq]();
    pic_eoi(irq);
}

void irq_init(void) {
    for (int i = 0; i < 16; i++) {
        uint32_t stub = irq_stub_table[i];
        idt_set_gate(32 + i, stub, 0x08, 0x8E);
    }
}
