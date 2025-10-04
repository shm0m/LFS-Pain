#include "pit.h"
#include "isr.h"
#include "vga.h"
#include <stdint.h>
#include "irq.h"

static volatile uint64_t ticks = 0;

static inline void outb(uint16_t p, uint8_t v){ __asm__ volatile("outb %0,%1"::"a"(v),"Nd"(p)); }
static void irq0_handler(void);

uint64_t pit_ticks(void){ return ticks; }

void pit_init(uint32_t hz){
  irq_install_handler(0, irq0_handler);
  uint32_t div = 1193182 / hz;
  outb(0x43, 0x36);
  outb(0x40, div & 0xFF);
  outb(0x40, div >> 8);
}

static void irq0_handler(void){
  ticks++;
  if((ticks % 100)==0) vga_puts(".");
}
