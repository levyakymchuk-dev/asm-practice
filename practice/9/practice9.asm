BITS 32
GLOBAL _start

SECTION .data
newline db 10
colon db ':'
space db ' '
hash db '#'
seed dd 12345

SECTION .bss
input resb 32
freq resd 10
buf resb 32
n resd 1

SECTION .text

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 32
    int 0x80

    ; parse
    mov esi, input
    call atoi
    mov [n], eax

    ; memory
    xor edi, edi
zero_loop:
    cmp edi, 10
    jge generate

    mov dword [freq + edi*4], 0

    inc edi
    jmp zero_loop


generate:
    xor edi, edi

gen_loop:
    cmp edi, [n]
    jge print_hist

    ; LCG
    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 2147483647

    mov [seed], eax

    ; % 10
    xor edx, edx
    mov ebx, 10
    div ebx

    inc dword [freq + edx*4]

    inc edi
    jmp gen_loop


print_hist:
    xor edi, edi

line_loop:
    cmp edi, 10
    jge exit_program

    ; print digit
    mov eax, edi
    call print_int

    ; :
    mov eax, 4
    mov ebx, 1
    mov ecx, colon
    mov edx, 1
    int 0x80

    ; space
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    ; hashes
    mov esi, [freq + edi*4]

hash_loop:
    cmp esi, 0
    je print_count

    mov eax, 4
    mov ebx, 1
    mov ecx, hash
    mov edx, 1
    int 0x80

    dec esi
    jmp hash_loop


print_count:
    ; space
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    ; number
    mov eax, [freq + edi*4]
    call print_int
    call print_nl

    inc edi
    jmp line_loop


exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80


atoi:
    xor eax, eax

atoi_loop:
    movzx ebx, byte [esi]

    cmp bl, 10
    je atoi_done

    cmp bl, 13
    je atoi_done

    cmp bl, 0
    je atoi_done

    cmp bl, '0'
    jb atoi_done

    cmp bl, '9'
    ja atoi_done

    sub ebx, '0'

    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:
    ret


print_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, buf + 32

    cmp eax, 0
    jne pi_loop

    dec esi
    mov byte [esi], '0'
    jmp pi_out

pi_loop:
    mov ebx, 10

pi_digit:
    xor edx, edx
    div ebx

    add dl, '0'

    dec esi
    mov [esi], dl

    test eax, eax
    jnz pi_digit

pi_out:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi

    mov edx, buf + 32
    sub edx, esi

    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret


print_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret