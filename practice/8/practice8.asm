; practice8.asm
; I/O: int 80h (sys_read, sys_write, sys_exit)
; Blocks: I/O, parse, logic, loops, memory

section .data
    msg_idx    db "First index: ", 0
    msg_count  db 10, "Count: ", 0
    msg_list   db 10, "Indices: ", 0
    msg_none   db "-1", 0
    newline    db 10
    space      db " "

section .bss
    buffer     resb 64
    array      resd 100     
    n_val      resd 1      
    target     resd 1
    found_idx  resd 1    
    total_found resd 1     

section .text
    global _start

_start:
    ; --- I/O: Read n ---
    call read_int
    mov [n_val], eax

    ; --- Loops: Read n numbers into array ---
    mov ecx, 0
read_array_loop:
    cmp ecx, [n_val]
    je read_target
    push ecx
    call read_int
    pop ecx
    mov [array + ecx*4], eax
    inc ecx
    jmp read_array_loop

read_target:
    ; --- I/O: Read target value ---
    call read_int
    mov [target], eax

    ; --- Logic: Linear Search ---
    mov dword [found_idx], -1
    mov dword [total_found], 0
    mov ecx, 0

search_loop:
    cmp ecx, [n_val]
    je print_results
    
    mov eax, [array + ecx*4]
    cmp eax, [target]
    jne next_iter

    ; Якщо знайдено
    inc dword [total_found]
    cmp dword [found_idx], -1
    jne next_iter
    mov [found_idx], ecx    

next_iter:
    inc ecx
    jmp search_loop

print_results:
    ; --- I/O: Output First Index ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, 13
    int 0x80

    mov eax, [found_idx]
    cmp eax, -1
    je print_minus_one
    call print_int
    jmp print_cnt_msg

print_minus_one:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_none
    mov edx, 2
    int 0x80

print_cnt_msg:
    ; --- I/O: Output Count ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, 8
    int 0x80
    mov eax, [total_found]
    call print_int

    ; --- I/O: Output List of Indices ---
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_list
    mov edx, 10
    int 0x80

    mov ecx, 0
print_indices_loop:
    cmp ecx, [n_val]
    je exit_prog
    
    mov eax, [array + ecx*4]
    cmp eax, [target]
    jne skip_idx_print

    push ecx
    mov eax, ecx
    call print_int
    ; Друк пробілу
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

skip_idx_print:
    inc ecx
    jmp print_indices_loop

exit_prog:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; --- I/O: sys_exit ---
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Memory: Helper to read integer from stdin ---
read_int:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 64
    int 0x80
    
    xor eax, eax
    xor ebx, ebx
    mov esi, buffer
.parse:
    movzx ebx, byte [esi]
    cmp bl, 10
    je .done
    cmp bl, '0'
    jl .next_char
    cmp bl, '9'
    jg .next_char
    sub bl, '0'
    imul eax, 10
    add eax, ebx
.next_char:
    inc esi
    jmp .parse
.done:
    ret

; --- Memory: Helper to print integer to stdout ---
print_int:
    test eax, eax
    jnz .not_zero
    mov byte [buffer], '0'
    mov edx, 1
    jmp .write
.not_zero:
    mov edi, buffer + 31
    mov byte [edi], 0
    mov ebx, 10
.loop_digits:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .loop_digits
    mov ecx, edi
    mov edx, buffer + 31
    sub edx, edi
.write:
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80
    ret