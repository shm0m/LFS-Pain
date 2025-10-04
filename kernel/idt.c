#include "idt.h"

#include <stddef.h>
#include <stdint.h>

#define KERNEL_CODE_SELECTOR 0x08
#define IDT_FLAG_PRESENT     0x80
#define IDT_FLAG_RING0       0x00
#define IDT_FLAG_INTERRUPT   0x0E

static idt_entry_t idt[IDT_MAX_ENTRIES];
static idt_ptr_t idt_descriptor;

extern void *isr_stub_table[];
extern void idt_load(const idt_ptr_t *descriptor);

void idt_set_gate(uint8_t vector, uint32_t base, uint16_t selector, uint8_t type_attr) {
    idt[vector].base_low  = (uint16_t)(base & 0xFFFFu);
    idt[vector].base_high = (uint16_t)((base >> 16) & 0xFFFFu);
    idt[vector].selector  = selector;
    idt[vector].zero      = 0;
    idt[vector].type_attr = type_attr;
}

static void idt_clear(void) {
    for (size_t i = 0; i < IDT_MAX_ENTRIES; ++i) {
        idt[i].base_low = idt[i].base_high = 0;
        idt[i].selector = 0;
        idt[i].zero = 0;
        idt[i].type_attr = 0;
    }
}

void idt_init(void) {
    idt_clear();

    idt_descriptor.limit = sizeof(idt) - 1;
    idt_descriptor.base  = (uint32_t)idt;

    const uint8_t type = IDT_FLAG_PRESENT | IDT_FLAG_RING0 | IDT_FLAG_INTERRUPT;
    for (uint8_t i = 0; i < 32; ++i) {
        idt_set_gate(i, (uint32_t)isr_stub_table[i], KERNEL_CODE_SELECTOR, type);
    }

    idt_load(&idt_descriptor);
}
