[BITS 32]
GLOBAL read_key, update_cursor, scroll_screen, show_cursor

SECTION .data
; Flags touches spéciales
shift_pressed: db 0
ctrl_pressed:  db 0
alt_pressed:   db 0
caps_lock_on:  db 0
ext_key:       db 0

; Position du curseur (en octets depuis 0xB8000)
cursor_pos: dd 0

video_mem    equ 0xB8000
LINE_BYTES   equ 160          ; 80 cols * 2 octets
SCREEN_LINES equ 25
SCREEN_BYTES equ LINE_BYTES * SCREEN_LINES
MAX_POS      equ SCREEN_BYTES - 2
CHARS_PER_LINE equ 80

; Tables scancode -> ASCII (QWERTY)
SECTION .data
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

SECTION .text

;------------------------------------------------------
; Boucle principale de lecture clavier
;------------------------------------------------------
read_key:
.wait_key:
    in al, 0x64              ; statut clavier
    test al, 1
    jz .wait_key

    in al, 0x60              ; scancode
    cmp al, 0xE0
    je .ext_prefix           ; préfixe étendu (flèches...)

    mov bl, al
    test bl, 0x80
    jnz .key_release         ; break code (relâchement)

.key_press:
    ; touches spéciales
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

.shift_down:
    mov byte [shift_pressed], 1
    jmp .wait_key
.shift_up:
    mov byte [shift_pressed], 0
    jmp .wait_key
.ctrl_down:
    mov byte [ctrl_pressed], 1
    jmp .wait_key
.ctrl_up:
    mov byte [ctrl_pressed], 0
    jmp .wait_key
.alt_down:
    mov byte [alt_pressed], 1
    jmp .wait_key
.alt_up:
    mov byte [alt_pressed], 0
    jmp .wait_key
.caps_toggle:
    xor byte [caps_lock_on], 1
    jmp .wait_key

;------------------------------------------------------
; Retour à la ligne → colonne 0 de la ligne suivante
; (scroll si besoin)
;------------------------------------------------------
.newline:
    ; obtenir ligne et colonne (EDX = colonne offset en octets)
    mov eax, [cursor_pos]
    xor edx, edx
    mov ecx, LINE_BYTES
    div ecx                  ; eax = ligne, edx = colonne (octets)
    inc eax                  ; passer à la ligne suivante
    cmp eax, SCREEN_LINES
    jb .set_cursor_noscroll

    ; si dépassement, scroll l'écran d'une ligne
    call scroll_screen
    ; placer curseur au début de la dernière ligne
    mov eax, (SCREEN_LINES - 1)    ; numéro de ligne = 24
    imul eax, LINE_BYTES
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

.set_cursor_noscroll:
    imul eax, LINE_BYTES
    ; colonne (edx) doit être conservée => position = line*LINE_BYTES + edx
    add eax, edx
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

;------------------------------------------------------
; Préfixe étendu : lire scancode étendu et gérer flèches
;------------------------------------------------------
.ext_prefix:
    in al, 0x60
    mov bl, al
    ; extended break codes: if high bit set -> release; ignore releases
    test bl, 0x80
    jnz .wait_key

    ; flèches (E0 48/50/4B/4D)
    cmp bl, 0x48              ; ↑
    je .arrow_up
    cmp bl, 0x50              ; ↓
    je .arrow_down
    cmp bl, 0x4B              ; ←
    je .arrow_left
    cmp bl, 0x4D              ; →
    je .arrow_right
    jmp .wait_key

;------------------------------------------------------
; Flèche haut : décrémente la ligne (même colonne)
;------------------------------------------------------
.arrow_up:
    mov eax, [cursor_pos]
    xor edx, edx
    mov ecx, LINE_BYTES
    div ecx                  ; eax = ligne, edx = colonne (octets)
    cmp eax, 0
    je .wait_key
    dec eax
    imul eax, LINE_BYTES
    add eax, edx
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

;------------------------------------------------------
; Flèche bas : incrémente la ligne (même colonne), scroll si nécessaire
;------------------------------------------------------
.arrow_down:
    mov eax, [cursor_pos]
    xor edx, edx
    mov ecx, LINE_BYTES
    div ecx                  ; eax = ligne, edx = colonne (octets)
    cmp eax, SCREEN_LINES - 1
    jb .down_move
    ; si déjà dernière ligne => scroll et garder colonne
    call scroll_screen
    ; positionner au début de la dernière ligne + colonne
    mov eax, SCREEN_LINES - 1
    imul eax, LINE_BYTES
    add eax, edx
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

.down_move:
    inc eax
    imul eax, LINE_BYTES
    add eax, edx
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

;------------------------------------------------------
; Flèche gauche : recule d'un caractère (2 octets)
;------------------------------------------------------
.arrow_left:
    mov eax, [cursor_pos]
    cmp eax, 0
    jle .wait_key
    sub eax, 2
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

;------------------------------------------------------
; Flèche droite : avance d'un caractère (2 octets)
;------------------------------------------------------
.arrow_right:
    mov eax, [cursor_pos]
    add eax, 2
    cmp eax, MAX_POS
    jae .wait_key
    mov [cursor_pos], eax
    call update_cursor
    jmp .wait_key

;------------------------------------------------------
; Affichage d'un caractère ASCII
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

    mov edi, video_mem
    add edi, [cursor_pos]
    mov ah, 0x0F
    stosw
    ; avancer d'un caractère
    add dword [cursor_pos], 2
    ; si dépassement physique de la mémoire vidéo -> scroll et mettre début
    mov eax, [cursor_pos]
    cmp eax, SCREEN_BYTES
    jb .after_put
    ; on a dépassé -> scroll et mettre sur dernière ligne
    call scroll_screen
    mov eax, (SCREEN_LINES - 1)
    imul eax, LINE_BYTES
    mov [cursor_pos], eax
.after_put:
    call update_cursor
    jmp .wait_key

;------------------------------------------------------
; Scroll_screen :
;    déplace l'écran d'une ligne vers le haut et vide la dernière ligne
;------------------------------------------------------
scroll_screen:
    pushad
    cld                         ; sens avant pour les reps

    ; source = video_mem + LINE_BYTES
    mov esi, video_mem
    add esi, LINE_BYTES
    mov edi, video_mem

    ; nombre de mots (16-bit) à déplacer = CHARS_PER_LINE * (SCREEN_LINES - 1)
    mov ecx, CHARS_PER_LINE
    imul ecx, SCREEN_LINES - 1  ; ecx = 80 * 24 = 1920
    ; on utilise rep movsw (word copies) -> ECX = nombre de words
    ; mais rep movsw uses ECX ; ensure ECX fits 32-bit
    rep movsw

    ; clear last line (80 characters)
    mov ax, 0x0720              ; 0x07 attr, ' ' = 0x20 -> ax = attr<<8 | char
    mov ecx, CHARS_PER_LINE
    ; edi should point to video_mem + (LINE_BYTES * (SCREEN_LINES-1))
    mov edi, video_mem
    mov eax, LINE_BYTES
    imul eax, SCREEN_LINES - 1
    add edi, eax
    rep stosw

    popad
    ret

;------------------------------------------------------
; Met à jour le curseur matériel VGA (position en [cursor_pos])
;------------------------------------------------------
update_cursor:
    pushad
    mov eax, [cursor_pos]
    shr eax, 1                  ; convertir octets -> caractères (pos char)
    ; copier bas/haut dans BX
    mov bx, ax                  ; BX = low 16 bits (pos)
    mov dx, 0x3D4

    mov al, 0x0F
    out dx, al
    inc dx
    mov al, bl                  ; low byte
    out dx, al

    dec dx
    mov al, 0x0E
    out dx, al
    inc dx
    mov al, bh                  ; high byte
    out dx, al

    popad
    ret

;------------------------------------------------------
; Affiche le curseur (optionnel, appeler au boot)
;------------------------------------------------------
show_cursor:
    pushad
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
    popad
    ret
