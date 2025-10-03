#include "vga.h"
#define VGA ((volatile unsigned short*)0xB8000)
static int row, col;
static unsigned char attr = 0x0F;

void vga_init(){ row=col=0; for(int i=0;i<80*25;i++) VGA[i]=(attr<<8)|' '; }
static void putc(char c){
  if(c=='\n'){ col=0; if(++row==25){row=0;} return; }
  VGA[row*80+col]=(attr<<8)|c;
  if(++col==80){ col=0; if(++row==25) row=0; }
}

void vga_puts(const char*s){ while(*s) putc(*s++); }
