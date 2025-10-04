; ------------------------------
; Multiboot header (GRUB lit ça pour savoir que ton kernel est bootable)
; ------------------------------

section .multiboot
align 4
    dd 0x1BADB002               ; magic number pour GRUB
    dd 0x00                     ; flags (0 = pas de mémoire spéciale)
    dd -(0x1BADB002 + 0x00)     ; checksum (doit faire 0 avec les deux lignes du dessus)

; ------------------------------
; Code d’entrée kernel
; ------------------------------

section .text
align 4
BITS 32
global _start
extern kmain

_start:
    cli
    mov esp, stack_top          ; configure la stack
    call kmain                  ; saute dans le C

.hang:
    hlt                         ; met le CPU en pause
    jmp .hang                   

; ------------------------------
; Stack en BSS
; ------------------------------

section .bss
align 16
stack_bottom:
    resb 4096
stack_top:
