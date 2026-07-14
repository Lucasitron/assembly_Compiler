; Teste de acesso à memória
main:
    mov a, 100
    store [0xFF], a
    load b, [0xFF]
    cmp a, b
    je igual
    hlt
igual:
    mov c, 1
    hlt