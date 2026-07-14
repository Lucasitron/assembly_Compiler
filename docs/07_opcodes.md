# 📋 Referência Completa de Opcodes

> **Documento:** 07_opcodes.md  
> **Descrição:** Referência técnica completa do conjunto de instruções da CPU Didática

---

## 1. Tabela de Opcodes

| Opcode | Mnemônico | Operandos | Bytes | Flags Afetadas |
|:------:|:---------:|:----------|:-----:|:--------------:|
| `0x01` | `mov` | `reg, reg` | 3 | Nenhuma |
| `0x02` | `mov` | `reg, imd` | 3 | Nenhuma |
| `0x03` | `add` | `reg, reg` | 3 | ZF, CF, NF |
| `0x04` | `sub` | `reg, reg` | 3 | ZF, CF, NF |
| `0x05` | `mul` | `reg, reg` | 3 | ZF, CF, NF |
| `0x06` | `div` | `reg, reg` | 3 | ZF, CF, NF |
| `0x07` | `cmp` | `reg, reg` | 3 | ZF, CF, NF |
| `0x08` | `cmp` | `reg, imd` | 3 | ZF, CF, NF |
| `0x09` | `jmp` | `label` | 3 | Nenhuma |
| `0x0A` | `je` | `label` | 3 | Nenhuma |
| `0x0B` | `jne` | `label` | 3 | Nenhuma |
| `0x0C` | `jg` | `label` | 3 | Nenhuma |
| `0x0D` | `jl` | `label` | 3 | Nenhuma |
| `0x0E` | `jle` | `label` | 3 | Nenhuma |
| `0x0F` | `jge` | `label` | 3 | Nenhuma |
| `0x10` | `load` | `reg, [end]` | 3 | Nenhuma |
| `0x11` | `store` | `[end], reg` | 3 | Nenhuma |
| `0xFF` | `hlt` | — | 1 | Nenhuma |

---

## 2. Codificação de Registradores

| Registrador | Código Binário | Código Hex |
|:-----------:|:--------------:|:----------:|
| `a` | `00` | `0x00` |
| `b` | `01` | `0x01` |
| `c` | `10` | `0x02` |
| `d` | `11` | `0x03` |

---

## 3. Formato das Instruções

### 3.1 `MOV_REG_REG` (0x01) - 3 bytes

```
Byte 0: 0x01 (opcode)
Byte 1: registrador destino
Byte 2: registrador origem
```

**Exemplo:** `mov a, b` → `01 00 01`

### 3.2 `MOV_REG_IMD` (0x02) - 3 bytes

```
Byte 0: 0x02 (opcode)
Byte 1: registrador destino
Byte 2: valor imediato (0-255)
```

**Exemplo:** `mov a, 10` → `02 00 0A`

### 3.3 `ADD_REG_REG` (0x03) - 3 bytes

```
Byte 0: 0x03 (opcode)
Byte 1: registrador destino
Byte 2: registrador origem
```

**Exemplo:** `add a, b` → `03 00 01`

### 3.4 `SUB_REG_REG` (0x04) - 3 bytes

```
Byte 0: 0x04 (opcode)
Byte 1: registrador destino
Byte 2: registrador origem
```

**Exemplo:** `sub a, b` → `04 00 01`

### 3.5 `MUL_REG_REG` (0x05) - 3 bytes

```
Byte 0: 0x05 (opcode)
Byte 1: registrador destino
Byte 2: registrador origem
```

**Exemplo:** `mul a, b` → `05 00 01`

### 3.6 `DIV_REG_REG` (0x06) - 3 bytes

```
Byte 0: 0x06 (opcode)
Byte 1: registrador destino
Byte 2: registrador origem
```

**Exemplo:** `div a, b` → `06 00 01`

### 3.7 `CMP_REG_REG` (0x07) - 3 bytes

```
Byte 0: 0x07 (opcode)
Byte 1: registrador
Byte 2: registrador
```

**Exemplo:** `cmp a, b` → `07 00 01`

### 3.8 `CMP_REG_IMD` (0x08) - 3 bytes

```
Byte 0: 0x08 (opcode)
Byte 1: registrador
Byte 2: valor imediato
```

**Exemplo:** `cmp a, 10` → `08 00 0A`

### 3.9 Saltos (0x09-0x0F) - 3 bytes

```
Byte 0: opcode (0x09-0x0F)
Byte 1: endereço (byte alto)
Byte 2: endereço (byte baixo)
```

**Exemplo:** `jmp 0x0009` → `09 00 09`

### 3.10 `LOAD` (0x10) - 3 bytes

```
Byte 0: 0x10 (opcode)
Byte 1: registrador destino
Byte 2: endereço de memória
```

**Exemplo:** `load a, [0x10]` → `10 00 10`

### 3.11 `STORE` (0x11) - 3 bytes

```
Byte 0: 0x11 (opcode)
Byte 1: endereço de memória
Byte 2: registrador origem
```

**Exemplo:** `store [0xFF], a` → `11 FF 00`

### 3.12 `HLT` (0xFF) - 1 byte

```
Byte 0: 0xFF (opcode)
```

**Exemplo:** `hlt` → `FF`

---

## 4. Condições de Salto

| Instrução | Opcode | Condição |
|:---------:|:------:|----------|
| `jmp` | `0x09` | Sempre |
| `je` | `0x0A` | ZF = 1 |
| `jne` | `0x0B` | ZF = 0 |
| `jg` | `0x0C` | ZF = 0 e NF = 0 |
| `jl` | `0x0D` | NF = 1 |
| `jle` | `0x0E` | ZF = 1 ou NF = 1 |
| `jge` | `0x0F` | ZF = 1 ou NF = 0 |

---

## 5. Mapa de Memória

| Endereço | Uso |
|:--------:|-----|
| `0x00 - 0xFF` | Memória de dados (256 bytes) |
| Programa | Carregado a partir do endereço 0 |

---

## 6. Exemplo de Programa Codificado

### Assembly

```asm
    mov a, 10
    mov b, 20
    add a, b
    cmp a, 30
    je igual
    mov c, 0
    jmp fim
igual:
    mov c, 1
fim:
    hlt
```

### Mapa de Endereços (Labels)

| Label | Endereço |
|:-----:|:--------:|
| `igual` | `0x000F` |
| `fim` | `0x0012` |

### Código Binário

```
Endereço | Bytes
0x0000  | 02 00 0A        mov a, 10
0x0003  | 02 01 14        mov b, 20
0x0006  | 03 00 01        add a, b
0x0009  | 08 00 1E        cmp a, 30
0x000C  | 0A 00 0F        je igual (→ 0x000F)
0x000F  | 02 02 01        mov c, 1
0x0012  | FF              hlt
```

---

> 📅 Última atualização: Julho 2026
