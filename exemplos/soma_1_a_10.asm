; Programa: Soma de 1 a 10
; Resultado: a = 55 (0x37)
main:
    mov a, 0        ; Acumulador = 0
    mov b, 1        ; Contador = 1
    mov d, 1        ; Incremento
loop:
    add a, b        ; Acumulador += Contador
    add b, d        ; Contador++
    cmp b, 10       ; Contador <= 10?
    jle loop        ; Se sim, continua
    hlt
