BITS 32
section .text

GLOBAL isr_stub_table
GLOBAL irq_stub_table
GLOBAL idt_load

EXTERN isr_handler
EXTERN irq_common_handler

; -----------------------------
; Table pointeurs ISRs (0..31)
; -----------------------------
isr_stub_table:
%assign i 0
%rep 32
    dd isr%+i
%assign i i+1
%endrep

; -----------------------------
; Macros ISRs
; -----------------------------
%macro ISR_NOERR 1
isr%1:
    push dword 0          ; faux errcode pour homogénéiser la stack
    push dword %1         ; int_no
    jmp isr_common
%endmacro

%macro ISR_ERR 1
isr%1:
    push dword %1         ; int_no (errcode déjà poussé par CPU)
    jmp isr_common
%endmacro

; -----------------------------
; Exceptions CPU 0..31
; -----------------------------
ISR_NOERR 0
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_ERR   8
ISR_NOERR 9
ISR_ERR   10
ISR_ERR   11
ISR_ERR   12
ISR_ERR   13
ISR_ERR   14
ISR_NOERR 15
ISR_NOERR 16
ISR_ERR   17
ISR_NOERR 18
ISR_NOERR 19
ISR_NOERR 20
ISR_NOERR 21
ISR_NOERR 22
ISR_NOERR 23
ISR_NOERR 24
ISR_NOERR 25
ISR_NOERR 26
ISR_NOERR 27
ISR_NOERR 28
ISR_NOERR 29
ISR_NOERR 30
ISR_NOERR 31

; -----------------------------
; Routine commune ISR
; -----------------------------
isr_common:
    pusha
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov eax, esp
    push eax
    call isr_handler
    add esp, 4

    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8
    iretd

; -----------------------------
; IRQ 32..47 : table + stubs
; -----------------------------
irq_stub_table:
%assign i 0
%rep 16
    dd irq%+i
%assign i i+1
%endrep

%assign i 0
%rep 16
irq%+i:
    pusha
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push dword (32 + i)   ; int_no = 0x20 + i
    call irq_common_handler
    add esp, 4

    pop gs
    pop fs
    pop es
    pop ds
    popa
    iretd
%assign i i+1
%endrep

; -----------------------------
; lidt wrapper
; -----------------------------
idt_load:
    mov eax, [esp + 4]
    lidt [eax]
    ret

; Évite le warning “executable stack”
section .note.GNU-stack noalloc noexec nowrite
