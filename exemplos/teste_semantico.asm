; Teste de análise semântica - programa correto
main:
    mov a, 10
    mov b, 20
    add a, b
    cmp a, 30
    je igual
    mov c, 0
    jmp fim
igual:
    mov c, 1
fim:
    hlt
