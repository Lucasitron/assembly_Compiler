; Teste completo de todas as instruções
main:
    ; Teste MOV
    mov a, 10
    mov b, 20
    mov c, a
    
    ; Teste aritmética
    add a, b        ; a = 30
    sub b, c        ; b = 10
    mul a, b        ; a = 300
    mov d, 3
    div a, d        ; a = 100
    
    ; Teste comparação e saltos
    mov a, 50
    mov b, 30
    cmp a, b
    jg maior
    mov c, 0
    jmp verificar_igual
maior:
    mov c, 1
verificar_igual:
    mov a, 42
    mov b, 42
    cmp a, b
    je sao_iguais
    mov d, 0
    jmp fim
sao_iguais:
    mov d, 1
    
    ; Teste memória
    mov a, 0xFF
    store [0x10], a
    load b, [0x10]
    
fim:
    hlt
