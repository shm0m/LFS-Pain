#include "mmu.h"
#include <stdint.h>

static uint32_t __attribute__((aligned(4096))) page_dir[1024];
static uint32_t __attribute__((aligned(4096))) first_table[1024];

void paging_init(void){
  for(int i=0;i<1024;i++){
    first_table[i] = (i*0x1000) | 3; 
    page_dir[i] = 0x00000002;      
  }
  page_dir[0] = ((uint32_t)first_table) | 3;

  __asm__ volatile("mov %0, %%cr3"::"r"(page_dir));
  uint32_t cr0; __asm__ volatile("mov %%cr0,%0":"=r"(cr0));
  cr0 |= 0x80000000;
  __asm__ volatile("mov %0, %%cr0"::"r"(cr0));
}
