BITS 32
GLOBAL _start

SECTION .data
newline db 10

SECTION .bss
input resb 16
buf resb 6

SECTION .text
_start:

    ; I/O: read input
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 16
    int 0x80

    ; parse: string -> number (AX)
    mov esi, input
    xor eax, eax

parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je parse_done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:

    ; logic: move to AX
    mov ax, ax

    ; memory: pointer to end
    mov edi, buf + 6

convert_loop:
    ; math
    mov edx, 0
    mov ecx, 10
    div ecx

    add dl, '0'
    dec edi
    mov [edi], dl

    ; loops
    test eax, eax
    jnz convert_loop

    ; I/O: write result
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buf + 6
    sub edx, edi
    int 0x80

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