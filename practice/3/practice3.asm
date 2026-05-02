; practice3.asm
; I/O: int 0x80
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
newline db 10

SECTION .bss
buf resb 6          ; memory (max 6 digits)

SECTION .text
_start:

    ; logic: number in AX (change if needed)
    mov ax, 54321

    ; parse: move to eax
    movzx eax, ax

    ; memory: pointer to end of buffer
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

    ; I/O: newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80