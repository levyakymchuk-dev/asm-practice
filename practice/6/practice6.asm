BITS 32
GLOBAL _start

SECTION .data
newline db 10

msg_signed db "SIGNED: ",0
msg_unsigned db "UNSIGNED: ",0

lt db "a < b",10
eq db "a = b",10
gt db "a > b",10

SECTION .bss
input resb 32
buf resb 16

SECTION .text

_start:

    ; I/O: read input
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 32
    int 0x80

    ; parse: atoi first number
    mov esi, input
    call atoi
    mov ebx, eax   ; a

    ; skip space
skip_space:
    mov al, [esi]
    cmp al, ' '
    jne parse_b
    inc esi
    jmp skip_space

parse_b:
    call atoi
    mov ecx, eax   ; b

    ; ===== SIGNED =====
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_signed
    mov edx, 8
    int 0x80

    mov eax, ebx
    cmp eax, ecx
    jl s_lt
    jg s_gt
    je s_eq

s_lt:
    mov ecx, lt
    jmp print_s

s_gt:
    mov ecx, gt
    jmp print_s

s_eq:
    mov ecx, eq

print_s:
    mov eax, 4
    mov ebx, 1
    mov edx, 6
    int 0x80

    ; ===== UNSIGNED =====
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_unsigned
    mov edx, 10
    int 0x80

    mov eax, ebx
    cmp eax, ecx
    jb u_lt
    ja u_gt
    je u_eq

u_lt:
    mov ecx, lt
    jmp print_u

u_gt:
    mov ecx, gt
    jmp print_u

u_eq:
    mov ecx, eq

print_u:
    mov eax, 4
    mov ebx, 1
    mov edx, 6
    int 0x80

    ; ===== max_signed =====
    mov eax, ebx
    cmp eax, ecx
    jg max_s_done
    mov eax, ecx

max_s_done:
    call itoa

    ; newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; ===== max_unsigned =====
    mov eax, ebx
    cmp eax, ecx
    ja max_u_done
    mov eax, ecx

max_u_done:
    call itoa

    ; newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80


; ===== atoi =====
atoi:
    xor eax, eax

atoi_loop:
    mov bl, [esi]
    cmp bl, 10
    je atoi_done
    cmp bl, ' '
    je atoi_done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:
    ret


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

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buf + 16
    sub edx, edi
    int 0x80

    ret