# 📐 Especificação da Linguagem Assembly Didática

> **Documento:** 01_linguagem.md  
> **Descrição:** Especificação formal completa da linguagem fonte

---

## 1. Visão Geral

A **Assembly Didática** é uma linguagem de montagem simplificada projetada para fins educacionais. Possui um conjunto reduzido de instruções, quatro registradores de propósito geral e suporte a labels, comentários e operandos imediatos.

### Características Principais

- **RISC-like**: Conjunto enxuto de instruções
- **4 registradores**: `a`, `b`, `c`, `d` (8 bits cada)
- **Endereçamento**: Imediato, registrador e memória
- **Saltos**: Condicionais e incondicionais
- **Comentários**: Suporte a `;`

---

## 2. Alfabeto

```
Σ = {
  a-z, 0-9,           # Letras minúsculas e dígitos
  [, ], ,, :, ;,      # Símbolos especiais
  espaço, tab, newline # Caracteres de controle
}
```

---

## 3. Registradores

A CPU Didática possui 4 registradores de propósito geral de 8 bits:

| Registrador | Código | Descrição |
|:-----------:|:------:|-----------|
| `a` | `0x00` | Propósito geral (frequentemente acumulador) |
| `b` | `0x01` | Propósito geral (frequentemente contador) |
| `c` | `0x02` | Propósito geral |
| `d` | `0x03` | Propósito geral (frequentemente auxiliar) |

---

## 4. Conjunto de Instruções

### 4.1 Movimentação de Dados

| Mnemônico | Sintaxe | Descrição | Opcode |
|:---------:|---------|-----------|:------:|
| `mov` | `mov reg, reg` | Copia valor de um registrador para outro | `0x01` |
| `mov` | `mov reg, imd` | Carrega valor imediato no registrador | `0x02` |

### 4.2 Operações Aritméticas

| Mnemônico | Sintaxe | Descrição | Opcode |
|:---------:|---------|-----------|:------:|
| `add` | `add reg, reg` | Destino = Destino + Origem | `0x03` |
| `sub` | `sub reg, reg` | Destino = Destino - Origem | `0x04` |
| `mul` | `mul reg, reg` | Destino = Destino × Origem | `0x05` |
| `div` | `div reg, reg` | Destino = Destino ÷ Origem | `0x06` |

> **Nota:** Todas as operações aritméticas exigem **dois registradores** como operandos.
> Para usar valores imediatos, carregue-os em um registrador primeiro com `mov`.

### 4.3 Comparação

| Mnemônico | Sintaxe | Descrição | Opcode |
|:---------:|---------|-----------|:------:|
| `cmp` | `cmp reg, reg` | Compara dois registradores (reg1 - reg2) | `0x07` |
| `cmp` | `cmp reg, imd` | Compara registrador com imediato | `0x08` |

### 4.4 Saltos

| Mnemônico | Sintaxe | Condição | Opcode |
|:---------:|---------|----------|:------:|
| `jmp` | `jmp label` | Incondicional | `0x09` |
| `je` | `je label` | ZF = 1 (igual) | `0x0A` |
| `jne` | `jne label` | ZF = 0 (diferente) | `0x0B` |
| `jg` | `jg label` | !ZF e !NF (maior) | `0x0C` |
| `jl` | `jl label` | NF = 1 (menor) | `0x0D` |
| `jle` | `jle label` | ZF=1 ou NF=1 (menor/igual) | `0x0E` |
| `jge` | `jge label` | NF=0 ou ZF=1 (maior/igual) | `0x0F` |

### 4.5 Acesso à Memória

| Mnemônico | Sintaxe | Descrição | Opcode |
|:---------:|---------|-----------|:------:|
| `load` | `load reg, [end]` | Carrega valor da memória para registrador | `0x10` |
| `store` | `store [end], reg` | Armazena valor do registrador na memória | `0x11` |

### 4.6 Controle

| Mnemônico | Sintaxe | Descrição | Opcode |
|:---------:|---------|-----------|:------:|
| `hlt` | `hlt` | Encerra execução do programa | `0xFF` |

---

## 5. Tipos de Operandos

| Tipo | Formato | Exemplos | Tamanho |
|------|---------|----------|:-------:|
| **Registrador** | `a \| b \| c \| d` | `a`, `b` | 8 bits |
| **Imediato decimal** | `[0-9]+` | `10`, `255` | 8 bits |
| **Imediato hexadecimal** | `0x[0-9a-f]+` | `0xFF`, `0x1A` | 8 bits |
| **Label** | `[a-z][a-z0-9]*` | `main`, `loop1` | 16 bits (endereço) |
| **Endereço de memória** | `[valor]` | `[100]`, `[0xFF]` | 8 bits |

---

## 6. Sintaxe do Programa

### 6.1 Regras Gerais

1. Um comando por linha
2. Labels terminam com `:` e ficam em linha própria (ou antes de instrução)
3. Comentários iniciam com `;` (linha inteira ou final de linha)
4. Instruções seguem o formato: `MNEMÔNICO [operando1[, operando2]]`
5. Case insensitive (todas as instruções são convertidas para minúsculas)

### 6.2 Formato das Linhas

```text
[identificador:]     ; Label (opcional)
    [mnemônico]      ; Instrução (obrigatória em linhas de código)
    [operandos]      ; 0, 1 ou 2 operandos separados por vírgula
    [; comentário]   ; Comentário inline (opcional)
```

---

## 7. Exemplos

### 7.1 Programa Mínimo

```asm
    hlt
```

### 7.2 Movimentação de Dados

```asm
    mov a, 10          ; a = 10
    mov b, a           ; b = a
    mov c, 0xFF        ; c = 255
```

### 7.3 Operações Aritméticas

```asm
    mov a, 10
    mov b, 5
    add a, b           ; a = 15
    sub a, b           ; a = 10
    mul a, b           ; a = 50
    div a, b           ; a = 10
```

### 7.4 Loop

```asm
main:
    mov a, 0           ; acumulador
    mov b, 5           ; contador
    mov d, 1           ; incremento
loop:
    add a, b           ; acumulador += contador
    sub b, d           ; contador--
    cmp b, 0
    jne loop           ; repete até b == 0
    hlt
```

### 7.5 Condicional

```asm
    mov a, 50
    mov b, 30
    cmp a, b
    jg a_maior         ; se a > b
    mov c, 0
    jmp fim
a_maior:
    mov c, 1
fim:
    hlt
```

### 7.6 Acesso à Memória

```asm
    mov a, 0xFF
    store [0x10], a    ; mem[0x10] = a
    load b, [0x10]     ; b = mem[0x10]
    hlt
```

---

## 8. Flags da CPU

| Flag | Nome | Descrição |
|:----:|------|-----------|
| **ZF** | Zero | Resultado da última operação foi zero |
| **CF** | Carry | Houve transporte/empréstimo |
| **NF** | Negative | Resultado foi negativo |

As flags são atualizadas pelas instruções: `cmp`, `add`, `sub`, `mul`, `div`.

---

## 9. Restrições e Limitações

| Limitação | Valor |
|:----------|:-----:|
| Registradores | 4 (a, b, c, d) |
| Tamanho do registrador | 8 bits (0-255) |
| Memória endereçável | 256 bytes (0x00-0xFF) |
| Tamanho máximo de label | Ilimitado (alfanumérico) |
| Instruções aninhadas | Não suportado |

---

> 📅 Última atualização: Julho 2026
