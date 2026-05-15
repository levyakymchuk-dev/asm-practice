BITS 32
GLOBAL _start

SECTION .data
newline db 10
space db ' '

SECTION .bss
input resb 4096
buf resb 32

arr resd 100

nval resd 1
ptrv resd 1

SECTION .text

_start:
    ; I/O
    mov eax,3
    mov ebx,0
    mov ecx,input
    mov edx,4096
    int 0x80

    mov dword [ptrv], input

    ; parse
    call atoi
    mov [nval], eax

    ; memory
    xor edi, edi

read_loop:
    cmp edi, [nval]
    jge print_original

    call atoi
    mov [arr + edi*4], eax

    inc edi
    jmp read_loop


print_original:
    xor edi, edi

po_loop:
    cmp edi, [nval]
    jge sort_start

    mov eax, [arr + edi*4]
    call print_int
    call print_space

    inc edi
    jmp po_loop


sort_start:
    call print_nl

    xor edi, edi

outer_loop:
    mov eax, [nval]
    dec eax

    cmp edi, eax
    jge print_sorted

    mov esi, edi

    mov ebx, edi
    inc ebx

inner_loop:
    cmp ebx, [nval]
    jge do_swap

    mov eax, [arr + ebx*4]
    mov edx, [arr + esi*4]

    cmp eax, edx
    jge next_inner

    mov esi, ebx

next_inner:
    inc ebx
    jmp inner_loop


do_swap:
    cmp esi, edi
    je next_outer

    mov eax, [arr + edi*4]
    mov edx, [arr + esi*4]

    mov [arr + edi*4], edx
    mov [arr + esi*4], eax

next_outer:
    inc edi
    jmp outer_loop


print_sorted:
    xor edi, edi

ps_loop:
    cmp edi, [nval]
    jge show_median

    mov eax, [arr + edi*4]
    call print_int
    call print_space

    inc edi
    jmp ps_loop


show_median:
    call print_nl

    mov eax, [nval]
    dec eax
    shr eax, 1

    mov eax, [arr + eax*4]

    call print_int
    call print_nl

    mov eax,1
    xor ebx,ebx
    int 0x80


atoi:
skip_space:
    mov esi, [ptrv]
    mov al, [esi]

    cmp al, ' '
    je move_next

    cmp al, 10
    je move_next

    cmp al, 13
    je move_next

    cmp al, 0
    je atoi_done

    jmp parse_num


move_next:
    inc esi
    mov [ptrv], esi
    jmp skip_space


parse_num:
    xor eax, eax

digit_loop:
    mov esi, [ptrv]
    movzx ebx, byte [esi]

    cmp bl, '0'
    jb atoi_done

    cmp bl, '9'
    ja atoi_done

    sub ebx, '0'

    imul eax, eax, 10
    add eax, ebx

    inc esi
    mov [ptrv], esi

    jmp digit_loop


atoi_done:
    ret


print_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, buf+32

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


print_space:
    mov eax,4
    mov ebx,1
    mov ecx,space
    mov edx,1
    int 0x80
    ret


print_nl:
    mov eax,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    int 0x80
    ret