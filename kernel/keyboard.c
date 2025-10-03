#include "keyboard.h"
#include "pic.h"
#include "vga.h"

static const char map[128] = {
  0,27,'1','2','3','4','5','6','7','8','9','0','-','=','\b',
  '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',0,
  'a','s','d','f','g','h','j','k','l',';','\'','`',0,'\\',
  'z','x','c','v','b','n','m',',','.','/',0,'*',0,' ', /*...*/
};

static inline uint8_t inb(uint16_t p){ uint8_t v; __asm__ volatile("inb %1,%0":"=a"(v):"Nd"(p)); return v; }

void irq1_handler(void){
  uint8_t sc = inb(0x60);
  if(sc < 128){
    char c = map[sc];
    if(c) { char s[2]={c,0}; vga_puts(s); }
  }
  pic_eoi(1);
}
