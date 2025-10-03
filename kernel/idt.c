#include "idt.h"
extern void isr_stub_table();
static idt_entry_t idt[256];
static idt_ptr_t   idtp;

void idt_set_gate(int n, uint32_t base, uint16_t sel, uint8_t flags){
  idt[n].base_lo = base & 0xFFFF;
  idt[n].sel = sel;
  idt[n].always0 = 0;
  idt[n].flags = flags;
  idt[n].base_hi = (base >> 16) & 0xFFFF;
}

void idt_load(void*);

void idt_init(void){
  idtp.limit = sizeof(idt)-1;
  idtp.base  = (uint32_t)&idt[0];
  for(int i=0;i<256;i++) idt_set_gate(i, 0, 0x08, 0x8E);

  extern uint32_t isr_stubs[];
  for(int i=0;i<32;i++)
    idt_set_gate(i, isr_stubs[i], 0x08, 0x8E);

  idt_load(&idtp);
}
