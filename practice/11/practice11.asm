section .data
    prompt db "Enter height (5-25): ", 0
    prompt_len equ $ - prompt
    newline db 10

section .bss
    input_buf resb 10
    line_buf  resb 100  ; Буфер для формування рядка (зірочки + пробіли)
    height    resd 1

section .text
    global _start

_start:
    ; --- I/O: Prompt ---
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; --- I/O: Read height ---
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, input_buf
    mov edx, 10
    int 0x80

    ; --- Parse: ASCII to Int ---
    xor eax, eax
    mov esi, input_buf
parse_loop:
    movzx ecx, byte [esi]
    cmp cl, 10          ; Перевірка на '\n'
    je parse_done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp parse_loop
parse_done:
    mov [height], eax

    ; --- Logic: Nested Loops ---
    mov esi, 1          ; i = 1 (поточний рядок від 1 до h)

main_loop:
    mov eax, [height]
    cmp esi, eax
    jg exit_prog

    ; --- Math: Calculate spaces and stars ---
    ; spaces = height - i
    ; stars  = 2*i - 1
    mov ebx, [height]
    sub ebx, esi        ; ebx = кількість пробілів
    
    mov edx, esi
    shl edx, 1
    dec edx             ; edx = кількість зірочок

    ; --- Memory: Fill line_buf ---
    mov edi, line_buf   ; Покажчик на початок буфера
    
    ; Цикл пробілів
    mov ecx, ebx
    test ecx, ecx
    jz fill_stars
fill_spaces:
    mov byte [edi], ' '
    inc edi
    loop fill_spaces

fill_stars:
    mov ecx, edx
fill_stars_loop:
    mov byte [edi], '*'
    inc edi
    loop fill_stars_loop

    ; Додаємо символ переносу рядка
    mov byte [edi], 10
    inc edi

    ; --- I/O: Call print_line ---
    ; Довжина рядка = (edi - line_buf)
    mov edx, edi
    sub edx, line_buf
    push edx            ; Параметр: довжина
    push line_buf       ; Параметр: адреса буфера
    call print_line
    add esp, 8          ; Очищення стеку

    inc esi             ; i++
    jmp main_loop

exit_prog:
    ; --- I/O: Exit ---
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

; --- Loops: Subroutine print_line(buf, len) ---
print_line:
    push ebp
    mov ebp, esp
    
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, [ebp+8]    ; адреса буфера
    mov edx, [ebp+12]   ; довжина
    int 0x80
    
    pop ebp
    ret