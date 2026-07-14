; Programa: Encontra o maior entre dois números
main:
    mov a, 30       ; Primeiro número
    mov b, 50       ; Segundo número
    cmp a, b        ; Compara a com b
    jg a_maior      ; Se a > b
    mov c, b        ; Senão, maior = b
    jmp fim
a_maior:
    mov c, a        ; maior = a
fim:
    hlt
