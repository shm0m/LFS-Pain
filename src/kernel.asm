BITS 32
GLOBAL _start

SECTION .multiboot
align 4
    dd 0x1BADB002           
    dd 0                    
    dd -(0x1BADB002 + 0)    

SECTION .text
_start:
    mov esp, stack_top
    mov edi, 0xB8000      
    mov esi, msg
.write_loop:
    lodsb                   
    cmp al, 0
    je .done
    mov ah, 0x0F            
    stosw
    jmp .write_loop

.done:
.halt:
    hlt
    jmp .halt

SECTION .rodata
msg: db "salut salut",0

SECTION .bss
align 16
stack_bottom:
    resb 4096
stack_top:
