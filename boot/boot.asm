; ------------------------------
; multiboot Header obligatoire pour GRUB (c'est la seule solution que j'ai trouvée)
; ------------------------------
SECTION .multiboot
align 4
    dd 0x1BADB002          
    dd 0x0                 
    dd -(0x1BADB002 + 0x0) 

; ------------------------------
; code d'entrée kernel
; ------------------------------
BITS 32
GLOBAL _start
EXTERN kmain

SECTION .text
_start:
    mov esp, stack_top
    call kmain

.hang:
    hlt
    jmp .hang


SECTION .bss
align 16
stack_bottom:
    resb 4096  
stack_top:
