; Programa: Contagem regressiva de 10 a 1
main:
    mov a, 0        ; Acumulador
    mov b, 10       ; Contador = 10
    mov d, 1        ; Decremento
loop:
    add a, b        ; Acumulador += Contador
    sub b, d        ; Contador--
    cmp b, 0        ; Contador == 0?
    jne loop        ; Se não, continua
    hlt
