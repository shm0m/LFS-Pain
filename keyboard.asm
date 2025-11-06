[BITS 32]
GLOBAL read_key, update_cursor, show_cursor

SECTION .data
;------------------------------------------------------
; Flags pour touches spéciales
;------------------------------------------------------
shift_pressed: db 0
ctrl_pressed:  db 0
alt_pressed:   db 0
caps_lock_on:  db 0
ext_key:       db 0

; Position actuelle du curseur (en octets dans 0xB8000)
cursor_pos: dd 0

;------------------------------------------------------
; Tables scancode -> ASCII (QWERTY)
;------------------------------------------------------
scancode_table_lower:
    db 0, 27, '1','2','3','4','5','6','7','8','9','0','-','=', 8
    db 9,'q','w','e','r','t','y','u','i','o','p','[',']',10
    db 0,'a','s','d','f','g','h','j','k','l',';','''','`',0
    db '\\','z','x','c','v','b','n','m',',','.','/',0,'*',0,' '
scancode_table_upper:
    db 0, 27, '!','@','#','$','%','^','&','*','(',')','_','+',8
    db 9,'Q','W','E','R','T','Y','U','I','O','P','{','}',10
    db 0,'A','S','D','F','G','H','J','K','L',':','"','~',0
    db '|','Z','X','C','V','B','N','M','<','>','?',0,'*',0,' '
scancode_table_size equ $ - scancode_table_lower


;------------------------------------------------------
; Section code
;------------------------------------------------------
SECTION .text

;------------------------------------------------------
; Routine principale de lecture clavier
;------------------------------------------------------
read_key:
.wait_key:
    in al, 0x64              ; statut clavier
    test al, 1
    jz .wait_key

    in al, 0x60              ; lecture scancode
    cmp al, 0xE0
    je .ext_prefix           ; touche étendue (flèches, etc.)

    mov bl, al
    test bl, 0x80
    jnz .key_release         ; break code (touche relâchée)

.key_press:
    ; --- touches spéciales ---
    cmp bl, 0x2A             ; Shift gauche
    je .shift_down
    cmp bl, 0x36             ; Shift droite
    je .shift_down
    cmp bl, 0x1D             ; Ctrl gauche
    je .ctrl_down
    cmp bl, 0x38             ; Alt gauche
    je .alt_down
    cmp bl, 0x3A             ; Caps Lock
    je .caps_toggle
    cmp bl, 0x1C             ; Entrée
    je .newline
    jmp .print_char

.key_release:
    and bl, 0x7F
    cmp bl, 0x2A
    je .shift_up
    cmp bl, 0x36
    je .shift_up
    cmp bl, 0x1D
    je .ctrl_up
    cmp bl, 0x38
    je .alt_up
    jmp .wait_key

;------------------------------------------------------
; Gestion des flags de touches spéciales
;------------------------------------------------------
.shift_down:  mov byte [shift_pressed], 1  ; touche Shift appuyée
               jmp .wait_key
.shift_up:    mov byte [shift_pressed], 0
               jmp .wait_key
.ctrl_down:   mov byte [ctrl_pressed], 1
               jmp .wait_key
.ctrl_up:     mov byte [ctrl_pressed], 0
               jmp .wait_key
.alt_down:    mov byte [alt_pressed], 1
               jmp .wait_key
.alt_up:      mov byte [alt_pressed], 0
               jmp .wait_key
.caps_toggle: xor byte [caps_lock_on], 1
               jmp .wait_key

;------------------------------------------------------
; Retour à la ligne (début de la prochaine ligne)
;------------------------------------------------------
.newline:
    mov eax, [cursor_pos]
    mov edx, 160               ; taille d’une ligne (80*2)
    xor ecx, ecx
    div edx                    ; eax = ligne, edx = colonne
    inc eax                    ; ligne suivante
    cmp eax, 25                ; écran = 25 lignes
    jl .set_cursor
    mov eax, 0                 ; revenir en haut si fin d’écran
.set_cursor:
    imul eax, 160              ; nouvelle position = ligne * 160
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key


;------------------------------------------------------
; Touches étendues (flèches)
;------------------------------------------------------
.ext_prefix:
    in al, 0x60
    mov bl, al
    mov byte [ext_key], 0

    cmp bl, 0x48              ; ↑
    je .arrow_up
    cmp bl, 0x50              ; ↓
    je .arrow_down
    cmp bl, 0x4B              ; ←
    je .arrow_left
    cmp bl, 0x4D              ; →
    je .arrow_right
    jmp .wait_key

.arrow_up:
    sub dword [cursor_pos], 160
    cmp dword [cursor_pos], 0
    jge .after_up
    mov dword [cursor_pos], 0
.after_up:
    call update_cursor
    jmp .wait_key

.arrow_down:
    add dword [cursor_pos], 160
    cmp dword [cursor_pos], 80*25*2 - 2
    jle .after_down
    mov dword [cursor_pos], 80*25*2 - 2
.after_down:
    call update_cursor
    jmp .wait_key

.arrow_left:
    sub dword [cursor_pos], 2
    cmp dword [cursor_pos], 0
    jge .after_left
    mov dword [cursor_pos], 0
.after_left:
    call update_cursor
    jmp .wait_key

.arrow_right:
    add dword [cursor_pos], 2
    cmp dword [cursor_pos], 80*25*2 - 2
    jle .after_right
    mov dword [cursor_pos], 80*25*2 - 2
.after_right:
    call update_cursor
    jmp .wait_key


;------------------------------------------------------
; Affichage d’un caractère ASCII
;------------------------------------------------------
.print_char:
    cmp byte [ext_key], 1
    je .wait_key

    mov al, bl
    cmp al, scancode_table_size
    jae .wait_key

    movzx esi, bl
    mov al, [scancode_table_lower + esi]
    mov cl, [shift_pressed]
    mov ch, [caps_lock_on]
    or cl, ch
    test cl, 1
    jz .skip_upper
    mov al, [scancode_table_upper + esi]
.skip_upper:

    mov edi, 0xB8000
    add edi, [cursor_pos]
    mov ah, 0x0F
    stosw
    add dword [cursor_pos], 2
    cmp dword [cursor_pos], 80*25*2
    jb .continue
    mov dword [cursor_pos], 0
.continue:
    call update_cursor
    jmp .wait_key


;------------------------------------------------------
; Met à jour le curseur matériel VGA
;------------------------------------------------------
update_cursor:
    push eax
    push dx

    mov eax, [cursor_pos]
    shr eax, 1                 ; /2 = position en caractères
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    inc dx
    mov al, al
    out dx, al

    dec dx
    mov al, 0x0E
    out dx, al
    inc dx
    mov al, ah
    out dx, al

    pop dx
    pop eax
    ret


;------------------------------------------------------
; Affiche le curseur (à appeler une fois au démarrage)
;------------------------------------------------------
show_cursor:
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al
    inc dx
    mov al, 0x0E
    out dx, al

    dec dx
    mov al, 0x0B
    out dx, al
    inc dx
    mov al, 0x0F
    out dx, al
    ret
