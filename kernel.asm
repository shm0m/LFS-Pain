BITS 32
GLOBAL _start, isr_divide_by_zero

;----------------------------------------
; Header Multiboot
;----------------------------------------
SECTION .text
align 4
multiboot_header:
    dd 0x1BADB002       ; magic number
    dd 0                 ; flags
    dd -(0x1BADB002 + 0) ; checksum

;----------------------------------------
; Code principal
;----------------------------------------
_start:
    mov esp, stack_top       ; Initialisation de la pile

    ; Charger l'IDT minimale pour l'ISR
    call init_idt

    ; Affichage du message principal
    mov edi, 0xB8000        ; Mémoire vidéo
    mov esi, msg
.write_loop:
    lodsb
    cmp al, 0
    je .after_msg
    mov ah, 0x0F            ; Gris clair sur noir
    stosw
    jmp .write_loop

.after_msg:
    ; Déclenche division par zéro pour tester l'ISR
    mov eax, 1
    xor edx, edx
    div edx                 ; déclenche ISR

.halt:
    hlt
    jmp .halt               ; boucle infinie

;----------------------------------------
; ISR division par zéro
;----------------------------------------
isr_divide_by_zero:
    pusha

    ; Affichage message ISR sur la 2ème ligne
    mov edi, 0xB8000 + 80*2
    mov esi, isr_msg
.isr_loop:
    lodsb
    cmp al, 0
    je .isr_done
    mov ah, 0x4F            ; Rouge sur noir
    stosw
    jmp .isr_loop
.isr_done:
    popa
    iret

;----------------------------------------
; Initialisation IDT minimale
;----------------------------------

