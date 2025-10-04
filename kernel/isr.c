#include "isr.h"
#include "vga.h"

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
    } else {
        vga_puts("Unknown interrupt\n");
    }

    for (;;) {
        __asm__ __volatile__("hlt");
    }
}
