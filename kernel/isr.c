#include "isr.h"
#include "pic.h"
#include "vga.h"

static irq_handler_t irq_handlers[16] = { 0 };

void irq_install_handler(uint8_t irq, irq_handler_t handler) {
    if (irq < 16) {
        irq_handlers[irq] = handler;
    }
}

void irq_uninstall_handler(uint8_t irq) {
    if (irq < 16) {
        irq_handlers[irq] = 0;
    }
}

static const char *exception_names[32] = {
    "#DE Divide Error",
    "#DB Debug",
    "Non Maskable Interrupt",
    "#BP Breakpoint",
    "#OF Overflow",
    "#BR Bound Range",
    "#UD Invalid Opcode",
    "#NM Device Not Available",
    "#DF Double Fault",
    "Coprocessor Segment Overrun",
    "#TS Invalid TSS",
    "#NP Segment Not Present",
    "#SS Stack Fault",
    "#GP General Protection",
    "#PF Page Fault",
    "Reserved",
    "#MF x87 Floating-Point",
    "#AC Alignment Check",
    "#MC Machine Check",
    "#XF SIMD Floating-Point",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved"
};

void isr_handler(isr_frame_t *frame) {
    if (frame->int_no < 32) {
        vga_puts("CPU exception: ");
        vga_puts(exception_names[frame->int_no]);
        vga_puts("\nHalting.\n");
        for (;;) {
            __asm__ __volatile__("hlt");
        }
    } else if (frame->int_no >= 32 && frame->int_no < 48) {
        uint8_t irq = (uint8_t)(frame->int_no - 32);
        irq_handler_t handler = irq_handlers[irq];
        if (handler) {
            handler();
        }
        pic_eoi(irq);
    } else {
        vga_puts("Unknown interrupt\n");
        for (;;) {
            __asm__ __volatile__("hlt");
        }
    }
}
