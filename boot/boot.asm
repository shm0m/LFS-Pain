BITS 32
GLOBAL _start
EXTERN kmain

SECTION .text
_start:
    ; stack (simple)
    mov esp, stack_top

    ; passer en texte: déjà en 32 bits via GRUB (multiboot)
    call kmain
.hang: hlt
       jmp .hang

SECTION .bss
align 16
stack_bottom: resb 4096
stack_top:

