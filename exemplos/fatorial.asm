; Programa: Fatorial de 5
; Resultado: a = 120 (0x78)
main:
    mov a, 1        ; Resultado = 1
    mov b, 5        ; Contador = 5
    mov d, 1        ; Decremento
loop:
    mul a, b        ; Resultado *= Contador
    sub b, d        ; Contador--
    cmp b, 1        ; Contador > 1?
    jg loop         ; Se sim, continua
    hlt
