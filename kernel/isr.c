#include "vga.h"
#include <stdint.h>
static const char* exc[] = {
 "DE","DB","NMI","BP","OF","BR","UD","NM","DF","Co","TS","NP","SS","GP","PF","15","MF","AC","MC","XF"
};
void isr_handler(uint32_t int_no, uint32_t err){
    (void)err;
    if(int_no < 20){ vga_puts("EXC: "); vga_puts(exc[int_no]); vga_puts("\n"); }
}
