BITS 32
GLOBAL isr_stubs
GLOBAL idt_load
EXTERN isr_handler

isr_stubs:
%assign i 0
%rep 32
    extern isr%+i
%assign i i+1
%endrep

%assign i 0
%rep 32
isr%+i:
    push dword i
    push dword 0
    jmp isr_common
%assign i i+1
%endrep

isr_common:
    pusha
    call isr_handler
    popa
    add esp, 8
    iretd

idt_load:
    mov eax, [esp+4]
    lidt [eax]
    ret
