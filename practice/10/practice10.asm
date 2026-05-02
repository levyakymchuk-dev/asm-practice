section .data
    prompt db "Enter a number: ", 0
    prompt_len equ $ - prompt
    newline db 10
    space   db " "
    msg_pop db 10, "popcount: ", 0
    msg_res db 10, "Result after bit manipulation: ", 0

section .bss
    buffer resb 16    ; Буфер для вводу/виводу
    num    resd 1     ; Введене число
    result resd 1     ; Результат маніпуляцій

section .text
    global _start

_start:
    ; --- I/O: Prompt ---
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; --- I/O: Read number ---
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; --- Parse: ASCII to Integer ---
    xor eax, eax
    xor ebx, ebx
    mov esi, buffer
parse_loop:
    movzx ecx, byte [esi]
    cmp cl, 10          ; Перевірка на перенос рядка
    je parse_done
    cmp cl, '0'
    jl parse_done
    cmp cl, '9'
    jg parse_done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp parse_loop
parse_done:
    mov [num], eax

    ; --- Logic: Binary Print (32 bits, groups of 4) ---
    mov edi, [num]
    mov ecx, 32         ; Лічильник циклу
print_bits:
    push ecx            ; Зберігаємо лічильник
    
    test edi, 0x80000000
    jz print_zero
    mov byte [buffer], '1'
    jmp do_write
print_zero:
    mov byte [buffer], '0'
do_write:
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80

    shl edi, 1          ; Зсув для наступного біта
    pop ecx             ; Відновлюємо лічильник
    
    ; Перевірка на групування по 4
    dec ecx
    jz end_bits
    mov eax, ecx
    and eax, 3          ; ecx % 4 == 0
    jnz skip_space
    
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

skip_space:
    test ecx, ecx
    jnz print_bits
end_bits:

    ; --- Math: Popcount (shr + and 1) ---
    mov edi, [num]
    xor ebx, ebx        ; Тут буде сума бітів
    mov ecx, 32
pop_loop:
    mov edx, edi
    and edx, 1          ; Маска для молодшого біта
    add ebx, edx
    shr edi, 1
    loop pop_loop

    ; Вивід popcount
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, 11
    int 0x80
    pop ebx
    call print_dec

    ; --- Logic: Bit manipulation ---
    ; Встановити біти p=0, q=4 (OR), скинути r=2 (AND NOT)
    mov eax, [num]
    or eax, (1 << 0)    ; set p=0
    or eax, (1 << 4)    ; set q=4
    and eax, ~(1 << 2)  ; clear r=2
    mov [result], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, 32
    int 0x80
    
    mov ebx, [result]
    call print_dec

    ; --- Exit ---
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Memory: Helper function to print decimal (ebx) ---
print_dec:
    mov eax, ebx
    mov edi, buffer + 15
    mov byte [edi], 0
    mov ecx, 10
.dec_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .dec_loop
    
    ; Write result
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi]
    mov edx, buffer + 15
    sub edx, edi
    int 0x80
    ret