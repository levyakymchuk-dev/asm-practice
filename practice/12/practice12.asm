BITS 32
GLOBAL _start

SECTION .data
newline db 10

SECTION .bss
text_buf    resb 256
pattern_buf resb 64
buf         resb 32

text_len    resd 1
pat_len     resd 1

first_pos   resd 1
count       resd 1

SECTION .text

_start:
    ; I/O
    mov eax,3
    mov ebx,0
    mov ecx,text_buf
    mov edx,256
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx,pattern_buf
    mov edx,64
    int 0x80

    ; parse
    mov esi,text_buf
    call strlen
    mov [text_len],eax

    mov esi,pattern_buf
    call strlen
    mov [pat_len],eax

    ; empty pattern
    cmp dword [pat_len],0
    jne start_search

    mov eax,0
    call print_int
    call print_nl

    mov eax,0
    call print_int
    call print_nl

    jmp exit_program


start_search:
    mov dword [first_pos],-1
    mov dword [count],0

    xor edi,edi

outer_loop:
    mov eax,[text_len]
    sub eax,[pat_len]

    cmp edi,eax
    jg search_done

    xor ecx,ecx

inner_loop:
    cmp ecx,[pat_len]
    je found_match

    mov al,[text_buf + edi + ecx]
    mov bl,[pattern_buf + ecx]

    cmp al,bl
    jne no_match

    inc ecx
    jmp inner_loop


found_match:
    cmp dword [first_pos],-1
    jne skip_first

    mov [first_pos],edi

skip_first:
    inc dword [count]

    add edi,[pat_len]
    jmp outer_loop


no_match:
    inc edi
    jmp outer_loop


search_done:
    mov eax,[first_pos]
    call print_int
    call print_nl

    mov eax,[count]
    call print_int
    call print_nl


exit_program:
    mov eax,1
    xor ebx,ebx
    int 0x80


; remove LF
strlen:
    xor eax,eax

strlen_loop:
    mov bl,[esi + eax]

    cmp bl,10
    je zero_end

    cmp bl,13
    je zero_end

    cmp bl,0
    je strlen_done

    inc eax
    jmp strlen_loop

zero_end:
    mov byte [esi + eax],0

strlen_done:
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

pi_digit:
    xor edx,edx
    div ebx

    add dl,'0'

    dec esi
    mov [esi],dl

    test eax,eax
    jnz pi_digit


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