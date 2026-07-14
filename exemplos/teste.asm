; Programa de exemplo - Soma de 1 a 10
main:
    mov a, 0        ; Inicializa acumulador
    mov b, 1        ; Inicializa contador
loop:
    add a, b        ; Soma contador ao acumulador
    add b, 1        ; Incrementa contador
    cmp b, 10       ; Compara com 10
    jle loop        ; Se menor ou igual, continua
    hlt             ; Fim do programa