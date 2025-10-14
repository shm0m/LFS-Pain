BITS 32
GLOBAL _start
EXTERN init_idt
EXTERN read_key

SECTION .text
align 4
multiboot_header:
    dd 0x1BADB002       ; magic number
    dd 0                 ; flags
    dd -(0x1BADB002 + 0)

_start:
    mov esp, stack_top       ; Init stack

    call init_idt            ; Init IDT

    ; Affichage message sous le texte de GRUB (ligne 6)
    mov edi, 0xB8000 + 80*5  ; ligne 6
    mov esi, msg
.write_loop:
    lodsb
    cmp al, 0
    je .after_msg
    mov ah, 0x0F            ; Gris clair sur noir
    stosw
    jmp .write_loop

.after_msg:
    call read_key            ; Boucle clavier simple

.halt:
    hlt
    jmp .halt

SECTION .bss
stack_top: resb 4096

SECTION .data
msg db 'Hello PainOS',0
isr_msg db 'Divide by zero!',0
