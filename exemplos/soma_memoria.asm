; Programa: Teste de load/store
main:
    mov a, 10
    mov b, 20
    store [0x10], a    ; Mem[0x10] = 10
    store [0x11], b    ; Mem[0x11] = 20
    load c, [0x10]     ; c = Mem[0x10]
    load d, [0x11]     ; d = Mem[0x11]
    add c, d           ; c = c + d
    hlt
