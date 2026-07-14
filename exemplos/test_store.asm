; Teste específico para store
main:
    mov a, 42
    store [0xFF], a
    load b, [0xFF]
    cmp a, b
    je igual
    hlt
igual:
    mov c, 1
    hlt