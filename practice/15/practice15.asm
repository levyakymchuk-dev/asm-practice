BITS 32
GLOBAL _start

SECTION .data
newline db 10

SECTION .bss
input resb 32
buf resb 32

nval  resd 1
calls resd 1

SECTION .text

_start:
    ; I/O
    mov eax,3
    mov ebx,0
    mov ecx,input
    mov edx,32
    int 0x80

    ; parse
    mov esi,input
    call atoi

    mov [nval],eax
    mov dword [calls],0

    ; logic
    mov eax,[nval]
    call fact

    ; print factorial
    call print_int
    call print_nl

    ; print calls
    mov eax,[calls]
    call print_int
    call print_nl

    ; exit
    mov eax,1
    xor ebx,ebx
    int 0x80


; recursion
fact:
    push ebp
    mov ebp,esp

    push ebx

    inc dword [calls]

    cmp eax,1
    jbe fact_base

    mov ebx,eax

    dec eax
    call fact

    imul eax,ebx
    jmp fact_done

fact_base:
    mov eax,1

fact_done:
    pop ebx

    mov esp,ebp
    pop ebp
    ret


; parse
atoi:
    xor eax,eax

atoi_loop:
    movzx ebx,byte [esi]

    cmp bl,10
    je atoi_done

    cmp bl,13
    je atoi_done

    cmp bl,0
    je atoi_done

    cmp bl,'0'
    jb atoi_done

    cmp bl,'9'
    ja atoi_done

    sub ebx,'0'

    imul eax,eax,10
    add eax,ebx

    inc esi
    jmp atoi_loop

atoi_done:
    ret


; I/O
print_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi,buf+32

    cmp eax,0
    jne pi_loop

    dec esi
    mov byte [esi],'0'
    jmp pi_out

pi_loop:
    mov ebx,10

pi_digits:
    xor edx,edx
    div ebx

    add dl,'0'

    dec esi
    mov [esi],dl

    test eax,eax
    jnz pi_digits

pi_out:
    mov eax,4
    mov ebx,1
    mov ecx,esi

    mov edx,buf+32
    sub edx,esi

    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


print_nl:
    mov eax,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    int 0x80
    ret