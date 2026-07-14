; Programa de exemplo - Soma de 1 a 10 (versão corrigida)
main:
    mov a, 0        ; Inicializa acumulador
    mov b, 1        ; Inicializa contador
    mov d, 1        ; Constante para incremento
loop:
    add a, b        ; Soma contador ao acumulador
    add b, d        ; Incrementa contador (b = b + d)
    cmp b, 10       ; Compara com 10
    jle loop        ; Se menor ou igual, continua
    hlt             ; Fim do programa
