bits 64
default rel

segment .data
    x dd 5, 3, 2, 6, 1, 7, 4
    y dd 0, 10, 1, 9, 2, 8, 5
    count equ 7
    
    ; Строка формата для вывода
    fmt db "Average difference: %lld", 10, 0

segment .text
    global main
    extern printf
    extern ExitProcess

main:
    push rbp            ; Сохраняем базу стека
    mov rbp, rsp
    sub rsp, 32         ; Резервируем 32 байта

    xor rsi, rsi        ; Суммировалка
    mov rcx, 0          ; Счетчик

loop_start:
    cmp rcx, count
    je calculate_avg

    ; Получаем адрес x[i] и y[i]
    lea rdx, [x]
    movsxd rax, dword [rdx + rcx*4]
    
    lea rdx, [y]
    movsxd rbx, dword [rdx + rcx*4]
    
    sub rax, rbx        ; rax = x[i] - y[i]
    add rsi, rax        ; sum += rax
    
    inc rcx
    jmp loop_start

calculate_avg:
    mov rax, rsi
    cqo                 ; Расширяем rax до rdx:rax для деления
    mov rbx, count
    idiv rbx            ; rax = rax / 7

    ; Выводим результат через printf
    mov rcx, fmt        ; строка формата
    mov rdx, rax        ; наше число
    call printf

    ; Выход из программы
    xor rcx, rcx        ; Код возврата 0
    call ExitProcess