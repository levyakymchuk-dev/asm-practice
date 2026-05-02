BITS 32
GLOBAL _start

SECTION .data
newline db 10
space db ' '

SECTION .bss
input resb 16
arr resd 50
buf resb 16
n resd 1
minv resd 1
maxv resd 1
mini resd 1
maxi resd 1

SECTION .text

_start:
    ; I/O: read n
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 16
    int 0x80

    ; parse: atoi
    mov esi, input
    call atoi
    mov [n], eax

    ; memory: build array
    xor ecx, ecx
build_loop:
    cmp ecx, [n]
    jge build_done

    mov eax, ecx
    imul eax, ecx              ; i * i

    mov ebx, ecx
    lea ebx, [ebx + ebx*2 + 1] ; 3 * i + 1
    add eax, ebx

    mov [arr + ecx*4], eax
    inc ecx
    jmp build_loop

build_done:
    ; logic: init min/max
    mov eax, [arr]
    mov [minv], eax
    mov [maxv], eax
    mov dword [mini], 0
    mov dword [maxi], 0

    mov ecx, 1
find_loop:
    cmp ecx, [n]
    jge find_done

    mov eax, [arr + ecx*4]

    cmp eax, [minv]
    jge skip_min
    mov [minv], eax
    mov [mini], ecx
skip_min:

    cmp eax, [maxv]
    jle skip_max
    mov [maxv], eax
    mov [maxi], ecx
skip_max:

    inc ecx
    jmp find_loop

find_done:

    ; ===== FIXED PRINT ARRAY =====
    xor ecx, ecx
print_arr_loop:
    cmp ecx, [n]
    jge print_arr_done

    mov eax, [arr + ecx*4]
    push ecx
    call print_int
    pop ecx

    mov edx, [n]
    dec edx
    cmp ecx, edx
    je no_space

    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

no_space:
    inc ecx
    jmp print_arr_loop

print_arr_done:
    call print_newline

    ; I/O: print min and its index
    mov eax, [minv]
    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    mov eax, [mini]
    call print_int
    call print_newline

    ; I/O: print max and its index
    mov eax, [maxv]
    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    mov eax, [maxi]
    call print_int
    call print_newline

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80


; parse
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


; I/O
print_int:
    push ebx
    push ecx
    push edx
    push edi

    mov edi, buf + 16
    cmp eax, 0
    jne pi_loop

    dec edi
    mov byte [edi], '0'
    jmp pi_write

pi_loop:
    xor edx, edx
    mov ecx, 10
    div ecx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz pi_loop

pi_write:
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buf + 16
    sub edx, edi
    int 0x80

    pop edi
    pop edx
    pop ecx
    pop ebx
    ret


print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret