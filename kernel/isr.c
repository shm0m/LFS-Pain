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

static const char* names[32] = {
  "DE","DB","NMI","BP","OF","BR","UD","NM","DF","CSO",
  "TS","NP","SS","GP","PF","RES","MF","AC","MC","XF",
  "RES","RES","RES","RES","RES","RES","RES","RES","RES","RES","RES","RES"
};

void isr_handler(isr_frame_t* f){
    vga_puts("\n[EXC] #");
    int n=f->int_no; if(n<32){ 
        char s[4]; s[0]='0'+(n/10); s[1]='0'+(n%10); s[2]=' '; s[3]=0; 
        if(n<10){ s[0]='0'; s[1]='0'+n; }
        vga_puts(s);
        vga_puts(names[n]);
    } else { vga_puts("??"); }
    for(;;)__asm__ __volatile__("cli; hlt");
}