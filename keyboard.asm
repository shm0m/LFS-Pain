BITS 32
GLOBAL read_key

read_key:
    in al, 0x64
    test al, 1
    jz read_key
    in al, 0x60
    cmp al, 0x1E     ; 'A' QWERTY
    jne read_key

    mov edi, 0xB8000 + 80*4
    mov ah, 0x0F
    mov al, 'A'
    stosw
    jmp read_key
