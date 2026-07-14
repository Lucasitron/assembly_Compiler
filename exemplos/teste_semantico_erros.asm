; Teste de análise semântica - programa com erros
main:
    mov 10, a       ; Erro: destino deve ser registrador
    add a, 10       ; Erro: add só aceita registradores
    jmp inexistente ; Erro: label não definido
    hlt
