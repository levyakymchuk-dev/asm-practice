BITS 32
GLOBAL _start

SECTION .data
newline db 10

SECTION .bss
input resb 16
buf resb 16

SECTION .text
_start:

    ; I/O: read input
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 16
    int 0x80

    ; parse: atoi
    mov esi, input
    xor eax, eax

atoi_loop:
    mov bl, [esi]
    cmp bl, 10
    je atoi_done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:

    ; logic: copy x
    mov ebx, eax

    xor ecx, ecx      ; sumDigits
    xor edi, edi      ; len

process_loop:
    cmp ebx, 0
    je process_done

    ; math: div 10
    mov eax, ebx
    xor edx, edx
    mov esi, 10
    div esi

    add ecx, edx      ; sum += remainder
    inc edi           ; len++

    mov ebx, eax
    jmp process_loop

process_done:

    ; ===== print sumDigits =====
    mov eax, ecx
    call itoa

    ; ===== print newline =====
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; ===== print len =====
    mov eax, edi
    call itoa

    ; ===== print newline =====
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80


; ===== itoa =====
itoa:
    mov edi, buf + 16

itoa_loop:
    xor edx, edx
    mov ecx, 10
    div ecx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz itoa_loop

    ; write
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buf + 16
    sub edx, edi
    int 0x80

    ret