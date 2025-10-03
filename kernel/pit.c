#include "pit.h"
#include "pic.h"
#include "vga.h"
#include <stdint.h>

static volatile uint64_t ticks = 0;

static inline void outb(uint16_t p, uint8_t v){ __asm__ volatile("outb %0,%1"::"a"(v),"Nd"(p)); }
uint64_t pit_ticks(void){ return ticks; }

void pit_init(uint32_t hz){
  uint32_t div = 1193182 / hz;
  outb(0x43, 0x36);
  outb(0x40, div & 0xFF);
  outb(0x40, div >> 8);
}

void irq0_handler(void){
  ticks++;
  if((ticks % 100)==0) vga_puts(".");
  pic_eoi(0);
}
