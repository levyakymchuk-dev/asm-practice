BITS 32
GLOBAL _start

SECTION .data
newline db 10
space db ' '
yesmsg db 'YES'
nomsg db 'NO'

SECTION .bss
input resb 2048
buf resb 32

arr resd 200
rev resd 200

nval resd 1
pos resd 1
pal resd 1

SECTION .text

_start:
    ; I/O
    mov eax,3
    mov ebx,0
    mov ecx,input
    mov edx,2048
    int 0x80

    mov dword [pos],input

    ; parse n
    call atoi
    mov [nval],eax

    ; read array
    xor edi,edi

read_loop:
    cmp edi,[nval]
    jge print_original

    call atoi
    mov [arr + edi*4],eax

    inc edi
    jmp read_loop


print_original:
    xor edi,edi

po_loop:
    cmp edi,[nval]
    jge build_reverse

    mov eax,[arr + edi*4]
    call print_int
    call print_space

    inc edi
    jmp po_loop


build_reverse:
    call print_nl

    xor edi,edi

rev_loop:
    cmp edi,[nval]
    jge print_reverse

    mov ecx,[nval]
    dec ecx
    sub ecx,edi

    mov eax,[arr + ecx*4]
    mov [rev + edi*4],eax

    inc edi
    jmp rev_loop


print_reverse:
    xor edi,edi

pr_loop:
    cmp edi,[nval]
    jge check_pal

    mov eax,[rev + edi*4]
    call print_int
    call print_space

    inc edi
    jmp pr_loop


check_pal:
    call print_nl

    mov dword [pal],1

    xor edi,edi

cp_loop:
    mov ecx,[nval]
    shr ecx,1

    cmp edi,ecx
    jge print_result

    mov eax,[arr + edi*4]

    mov ecx,[nval]
    dec ecx
    sub ecx,edi

    mov edx,[arr + ecx*4]

    cmp eax,edx
    je cp_next

    mov dword [pal],0
    jmp print_result


cp_next:
    inc edi
    jmp cp_loop


print_result:
    cmp dword [pal],1
    je show_yes

    mov eax,4
    mov ebx,1
    mov ecx,nomsg
    mov edx,2
    int 0x80
    jmp finish

show_yes:
    mov eax,4
    mov ebx,1
    mov ecx,yesmsg
    mov edx,3
    int 0x80

finish:
    call print_nl

    mov eax,1
    xor ebx,ebx
    int 0x80


atoi:
skip_ws:
    mov esi,[pos]
    mov al,[esi]

    cmp al,' '
    je skip_advance
    cmp al,10
    je skip_advance
    cmp al,13
    je skip_advance
    cmp al,0
    je atoi_done

    jmp parse_digits

skip_advance:
    inc esi
    mov [pos],esi
    jmp skip_ws


parse_digits:
    xor eax,eax

digit_loop:
    mov esi,[pos]
    movzx ebx,byte [esi]

    cmp bl,'0'
    jb atoi_done
    cmp bl,'9'
    ja atoi_done

    sub ebx,'0'

    imul eax,eax,10
    add eax,ebx

    inc esi
    mov [pos],esi

    jmp digit_loop


atoi_done:
    ret


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