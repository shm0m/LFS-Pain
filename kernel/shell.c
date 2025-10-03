#include "vga.h"
#include "pit.h"
#include <stdbool.h>
static char buf[64]; static int len=0;

static void prompt(){ vga_puts("\nmyOS> "); }
static void exec(){
  buf[len]=0;
  if(!len){ return; }
  if(!__builtin_strcmp(buf,"help")) vga_puts("\ncmds: help, ticks");
  else if(!__builtin_strcmp(buf,"ticks")){ char s[32]; // mini itoa
    unsigned long t=(unsigned long)pit_ticks(); int i=0; char tmp[20];
    if(!t) tmp[i++]='0'; while(t){ tmp[i++]= '0'+(t%10); t/=10; }
    for(int j=i-1;j>=0;j--){ char ch[2]={tmp[j],0}; vga_puts(ch); }
  } else vga_puts("\nunknown");
  len=0;
}

void shell_on_char(char c){
  if(c=='\n'){ exec(); prompt(); }
  else if(c=='\b'){ if(len){ len--; vga_puts("\b"); } }
  else if(len<63){ buf[len++]=c; char s[2]={c,0}; vga_puts(s); }
}
