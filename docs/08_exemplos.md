# 📝 Exemplos de Programas Comentados

> **Documento:** 08_exemplos.md  
> **Descrição:** Programas exemplo comentados com saída esperada e resultado da simulação

---

## Índice de Exemplos

1. [Programa Mínimo](#1-programa-mínimo)
2. [Soma de 1 a 10](#2-soma-de-1-a-10)
3. [Fatorial](#3-fatorial)
4. [Maior Número](#4-maior-número)
5. [Acesso à Memória](#5-acesso-à-memória)
6. [Todas as Instruções](#6-todas-as-instruções)

---

## 1. Programa Mínimo

**Arquivo:** `exemplos/teste_simples.asm`

```asm
; Programa mínimo - apenas move valores
inicio:
    mov a, 10
    mov b, 0xFF
    add a, b
    hlt
```

### Resultado da Simulação

```
Registradores:
  a: 10 + 255 = 265 → 9 (0x09)  [overflow: 265 & 0xFF = 9]
  b: 255 (0xFF)
  c: 0 (0x00)
  d: 0 (0x00)
Flags: Z=0 C=1 N=0  [Carry ativado pelo overflow]
```

---

## 2. Soma de 1 a 10

**Arquivo:** `exemplos/teste.asm`

```asm
; Soma de 1 a 10
main:
    mov a, 0        ; Acumulador = 0
    mov b, 1        ; Contador = 1
    mov d, 1        ; Incremento
loop:
    add a, b        ; Acumulador += Contador
    add b, d        ; Contador++
    cmp b, 10       ; Contador <= 10?
    jle loop        ; Se sim, continua
    hlt             ; Fim (a = 55)
```

### Compilação

```bash
$ python main.py exemplos/teste.asm
✅ Código gerado com sucesso - 22 bytes
```

### Resultado da Simulação

```
Registradores:
  a:  55 (0x37)   ← Soma de 1 a 10 = 55 ✓
  b:  11 (0x0B)
  c:   0 (0x00)
  d:   1 (0x01)
Flags: Z=0 C=0 N=0
Instruções executadas: 43
```

### Hexdump

```
Endereço | Bytes                          | ASCII
------------------------------------------------------------
0x0000  | 02 00 00 02 01 01 02 03 01 03 00 01 03 01 03 08 | ................
0x0010  | 01 0A 0E 00 09 FF                               | ......
```

---

## 3. Fatorial

**Arquivo:** `exemplos/fatorial.asm`

```asm
; Fatorial de 5
main:
    mov a, 1        ; Resultado = 1
    mov b, 5        ; Contador = 5
    mov d, 1        ; Decremento
loop:
    mul a, b        ; Resultado *= Contador
    sub b, d        ; Contador--
    cmp b, 1        ; Contador > 1?
    jg loop         ; Se sim, continua
    hlt             ; Fim (a = 120 = 5!)
```

### Compilação

```bash
$ python main.py exemplos/fatorial.asm
✅ Código gerado com sucesso - 22 bytes
```

### Resultado da Simulação

```
Registradores:
  a: 120 (0x78)   ← 5! = 120 ✓
  b:   1 (0x01)
  c:   0 (0x00)
  d:   1 (0x01)
Flags: Z=1 C=0 N=0
Instruções executadas: 19
```

### Hexdump

```
Endereço | Bytes                          | ASCII
------------------------------------------------------------
0x0000  | 02 00 01 02 01 05 02 03 01 05 00 01 04 01 03 08 | ................
0x0010  | 01 01 0C 00 09 FF                               | ......
```

---

## 4. Maior Número

**Arquivo:** `exemplos/maior_numero.asm`

```asm
; Encontra o maior entre dois números
main:
    mov a, 30       ; Primeiro número
    mov b, 50       ; Segundo número
    cmp a, b        ; Compara a com b
    jg a_maior      ; Se a > b, pula para a_maior
    mov c, b        ; Senão, maior = b
    jmp fim
a_maior:
    mov c, a        ; maior = a
fim:
    hlt             ; c = 50 (b é maior)
```

### Resultado da Simulação

```
Registradores:
  a: 30 (0x1E)
  b: 50 (0x32)
  c: 50 (0x32)   ← b > a, então c = b ✓
  d:  0 (0x00)
Flags: Z=0 C=0 N=1  [30 - 50 = negativo]
```

---

## 5. Acesso à Memória

**Arquivo:** `exemplos/soma_memoria.asm`

```asm
; Teste de load/store
main:
    mov a, 10
    mov b, 20
    store [0x10], a    ; Mem[0x10] = 10
    store [0x11], b    ; Mem[0x11] = 20
    load c, [0x10]     ; c = Mem[0x10] = 10
    load d, [0x11]     ; d = Mem[0x11] = 20
    add c, d           ; c = c + d = 30
    hlt
```

### Resultado da Simulação

```
Registradores:
  a: 10 (0x0A)
  b: 20 (0x14)
  c: 30 (0x1E)   ← 10 + 20 = 30 ✓
  d: 20 (0x14)
Flags: Z=0 C=0 N=0
Memória (não-zero):
  [0x10]: 10 (0x0A)
  [0x11]: 20 (0x14)
```

---

## 6. Todas as Instruções

**Arquivo:** `exemplos/teste_completo.asm`

```asm
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
    jg maior        ; a > b, salta
    mov c, 0
    jmp verificar_igual
maior:
    mov c, 1
    
    ; Teste JE
verificar_igual:
    mov a, 42
    mov b, 42
    cmp a, b
    je sao_iguais   ; a == b, salta
    mov d, 0
    jmp fim
sao_iguais:
    mov d, 1
    
    ; Teste memória
    mov a, 0xFF
    store [0x10], a
    load b, [0x10]  ; b = 0xFF
    
fim:
    hlt
```

### Compilação

```bash
$ python main.py exemplos/teste_completo.asm
✅ Código gerado com sucesso - 76 bytes
```

### Resultado da Simulação

```
Registradores:
  a: 255 (0xFF)
  b: 255 (0xFF)
  c:   1 (0x01)
  d:   1 (0x01)
Flags: Z=1 C=0 N=0
Memória (não-zero):
  [0x10]: 255 (0xFF)
Instruções executadas: 21
```

---

## Como Executar os Exemplos

```bash
# Compilar
python main.py exemplos/<arquivo>.asm

# Compilar com detalhes
python main.py exemplos/<arquivo>.asm -v

# Simular execução
python simulador.py exemplos/<arquivo>.asm

# Simular com debug (passo-a-passo)
python simulador.py exemplos/<arquivo>.asm -d

# Rodar todos os testes
./testar_tudo.sh
```

---

> 📅 Última atualização: Julho 2026
