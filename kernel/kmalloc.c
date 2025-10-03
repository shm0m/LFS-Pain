#include "kmalloc.h"

static unsigned long heap = 0x01000000; 

void* kmalloc(unsigned long sz){
  void* p = (void*)heap; heap += (sz+15)&~15UL; return p;
}

void  kfree(void* p){ (void)p;}
