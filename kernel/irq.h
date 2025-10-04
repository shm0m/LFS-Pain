#pragma once
#include <stdint.h>

typedef void (*irq_handler_t)(void);

void irq_init(void);                         // installe les stubs IRQ (32..47) dans l’IDT
void irq_install_handler(int irq, irq_handler_t h);
void irq_uninstall_handler(int irq);
void irq_common_handler(uint32_t int_no);    // appelé par les stubs ASM
