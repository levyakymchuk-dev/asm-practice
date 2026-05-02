BITS 32
GLOBAL _start

SECTION .data
newline db 10
space   db ' '

SECTION .bss
input     resb 1024
arr       resd 100
matches   resd 100
buf       resb 32
n         resd 1
target    resd 1
count     resd 1
first_idx resd 1
p         resd 1

SECTION .text
_start:
    ; read all input at once
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 1024
    int 0x80

    mov eax, input
    mov [p], eax

    ; read n
    call atoi
    mov [n], eax

    ; read array elements
    xor ecx, ecx
read_arr:
    cmp ecx, [n]
    jge read_target
    call atoi
    mov [arr + ecx*4], eax
    inc ecx
    jmp read_arr

read_target:
    call atoi
    mov [target], eax

    mov dword [count], 0
    mov dword [first_idx], -1

    xor ecx, ecx

search:
    cmp ecx, [n]
    jge done

    mov eax, [arr + ecx*4]
    cmp eax, [target]
    jne next

    ; FIX 1: save first_idx only once, then always store in matches
    cmp dword [first_idx], -1
    jne store
    mov [first_idx], ecx

store:
    mov edx, [count]
    mov [matches + edx*4], ecx
    inc dword [count]

next:
    inc ecx
    jmp search

done:
    ; FIX 2: print first_idx correctly — if -1 print nothing / handle gracefully
    mov eax, [first_idx]
    cmp eax, -1
    je print_minus_one
    call print_int
    jmp after_first_idx

print_minus_one:
    ; print "-1" manually
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_one_str
    mov edx, 2
    int 0x80

after_first_idx:
    call nl

    mov eax, [count]
    call print_int
    call nl

    mov ecx, [count]
    test ecx, ecx
    jz finish           ; FIX 3: skip the extra nl when empty

    xor edx, edx
print_loop:
    cmp edx, ecx
    jge finish
    mov eax, [matches + edx*4]
    call print_int
    inc edx
    cmp edx, ecx
    je finish
    call sp
    jmp print_loop

finish:
    call nl
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ── atoi ────────────────────────────────────────────────
atoi:
skip_ws:
    mov esi, [p]
    mov al, [esi]
    cmp al, ' '
    je  .adv
    cmp al, 10          ; \n
    je  .adv
    cmp al, 13          ; \r
    je  .adv
    jmp parse_digits
.adv:
    inc esi
    mov [p], esi
    jmp skip_ws

parse_digits:
    xor eax, eax
.loop:
    mov esi, [p]
    movzx ebx, byte [esi]
    cmp ebx, '0'
    jb  .done
    cmp ebx, '9'
    ja  .done
    sub ebx, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    mov [p], esi
    jmp .loop
.done:
    ret

; ── print_int ───────────────────────────────────────────
print_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, buf + 32

    cmp eax, 0
    jne .loop
    dec esi
    mov byte [esi], '0'
    jmp .out

.loop:
    mov ecx, 10
.digit:
    xor edx, edx
    div ecx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz .digit

.out:
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

; ── nl ──────────────────────────────────────────────────
nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

; ── sp (FIX 4: was missing int 0x80 and ret) ───────────
sp:
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    ret

; ── data for -1 output ──────────────────────────────────
SECTION .data
minus_one_str db '-', '1'