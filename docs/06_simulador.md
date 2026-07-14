# 🖥️ Simulador da CPU Didática

> **Documento:** 06_simulador.md  
> **Descrição:** Simulador da CPU virtual que executa o código de máquina gerado

---

## 1. Visão Geral

O simulador é uma CPU virtual que executa o código de máquina gerado pelo compilador. Ele implementa o ciclo completo de **fetch-decode-execute**, mantendo o estado dos registradores, flags e memória.

---

## 2. Arquitetura da CPU

### 2.1 Componentes

```
┌─────────────────────────────────────────────────┐
│                   CPU DIDÁTICA                   │
├─────────────────────────────────────────────────┤
│  REGISTRADORES                                   │
│  ┌──────┬──────┬──────┬──────┐                  │
│  │  a   │  b   │  c   │  d   │  8 bits cada    │
│  └──────┴──────┴──────┴──────┘                  │
│                                                   │
│  FLAGS                                           │
│  ┌──────┬──────┬──────┐                         │
│  │  ZF  │  CF  │  NF  │  Zero/Carry/Negative   │
│  └──────┴──────┴──────┘                         │
│                                                   │
│  PC (Program Counter): 16 bits                   │
│  MEMÓRIA: 256 bytes                              │
└─────────────────────────────────────────────────┘
```

### 2.2 Especificações

| Característica | Valor |
|:---------------|:-----:|
| Registradores | 4 × 8 bits (a, b, c, d) |
| PC (Program Counter) | 16 bits |
| Memória | 256 bytes (endereçável por 8 bits) |
| Flags | ZF (Zero), CF (Carry), NF (Negative) |
| Instruções | 18 opcodes |

---

## 3. Ciclo de Execução

```
while rodando:
    1. FETCH:    Buscar opcode em memória[PC]
    2. DECODE:   Identificar instrução e operandos
    3. EXECUTE:  Executar a operação
    4. UPDATE:   Atualizar PC e flags
```

### Implementação

```python
def executar(self, max_instrucoes=1000, debug=False):
    self.rodando = True
    instrucoes_executadas = 0
    
    while self.rodando and instrucoes_executadas < max_instrucoes:
        opcode = self.codigo[self.pc]
        
        if opcode == Opcode.HLT.value:
            self.rodando = False
        elif opcode == Opcode.MOV_REG_REG.value:
            self._executar_mov_reg_reg()
        elif opcode == Opcode.ADD_REG_REG.value:
            self._executar_add()
        # ... outras instruções
        
        instrucoes_executadas += 1
```

---

## 4. Instruções Implementadas

### 4.1 Movimentação

```python
def _executar_mov_reg_reg(self):
    reg_dest = self._ler_reg(self.codigo[self.pc + 1])
    reg_orig = self._ler_reg(self.codigo[self.pc + 2])
    self.registradores[reg_dest] = self.registradores[reg_orig]
    self.pc += 3

def _executar_mov_reg_imd(self):
    reg_dest = self._ler_reg(self.codigo[self.pc + 1])
    valor = self.codigo[self.pc + 2]
    self.registradores[reg_dest] = valor
    self.pc += 3
```

### 4.2 Aritmética

```python
def _executar_add(self):
    reg_dest = self._ler_reg(self.codigo[self.pc + 1])
    reg_orig = self._ler_reg(self.codigo[self.pc + 2])
    
    resultado = self.registradores[reg_dest] + self.registradores[reg_orig]
    self.flags['carry'] = resultado > 255
    self.registradores[reg_dest] = resultado & 0xFF
    self.pc += 3
```

### 4.3 Saltos

```python
def _executar_jump(self, opcode):
    endereco = (self.codigo[self.pc + 1] << 8) | self.codigo[self.pc + 2]
    
    if opcode == Opcode.JMP.value:
        self.pc = endereco
    elif opcode == Opcode.JE.value and self.flags['zero']:
        self.pc = endereco
    elif opcode == Opcode.JNE.value and not self.flags['zero']:
        self.pc = endereco
    else:
        self.pc += 3
```

### 4.4 Memória

```python
def _executar_load(self):
    reg = self._ler_reg(self.codigo[self.pc + 1])
    endereco = self.codigo[self.pc + 2]
    self.registradores[reg] = self.memoria[endereco]
    self.pc += 3

def _executar_store(self):
    endereco = self.codigo[self.pc + 1]
    reg = self._ler_reg(self.codigo[self.pc + 2])
    self.memoria[endereco] = self.registradores[reg]
    self.pc += 3
```

---

## 5. Flags da CPU

| Flag | Nome | Atualizada por | Significado quando 1 |
|:----:|------|:--------------:|----------------------|
| **ZF** | Zero | `cmp`, `add`, `sub`, `mul`, `div` | Resultado igual a zero |
| **CF** | Carry | `add`, `mul` | Resultado > 255 (overflow) |
| **NF** | Negative | `cmp`, `sub` | Resultado < 0 (negativo) |

---

## 6. Modo Debug

O simulador oferece um modo debug que mostra o estado da CPU a cada instrução:

```bash
python simulador.py exemplos/fatorial.asm -d
```

**Saída:**
```
PC=0x0000 OP=0x02 | a=  0 b=  0 c=  0 d=  0 | Z=0 C=0 N=0
PC=0x0003 OP=0x02 | a=  1 b=  0 c=  0 d=  0 | Z=0 C=0 N=0
PC=0x0006 OP=0x02 | a=  1 b=  5 c=  0 d=  0 | Z=0 C=0 N=0
PC=0x0009 OP=0x02 | a=  1 b=  5 c=  0 d=  1 | Z=0 C=0 N=0
PC=0x000C OP=0x05 | a=  1 b=  5 c=  0 d=  1 | Z=0 C=0 N=0
PC=0x000F OP=0x04 | a=  5 b=  5 c=  0 d=  1 | Z=0 C=0 N=0
...
✅ Execução concluída: 19 instruções executadas

ESTADO DA CPU
==================================================
PC: 0x0016
Registradores:
  a: 120 (0x78)   ← 5! = 120
  b:   1 (0x01)
  c:   0 (0x00)
  d:   1 (0x01)
Flags: Z=1 C=0 N=0
```

---

## 7. Exemplo de Execução

### Programa: Maior Número

```asm
main:
    mov a, 30
    mov b, 50
    cmp a, b
    jg a_maior
    mov c, b
    jmp fim
a_maior:
    mov c, a
fim:
    hlt
```

### Resultado da Simulação

```
Estado final:
  a: 30  (0x1E)
  b: 50  (0x32)
  c: 50  (0x32)  ← b é maior, então c = b
  d:  0  (0x00)
Flags: Z=0 C=0 N=1  (30 - 50 = negativo)
```

---

## 8. Limitações do Simulador

| Limitação | Valor/Descrição |
|:----------|:----------------|
| Instruções máximas por execução | 1.000 (evita loops infinitos) |
| Tamanho da memória | 256 bytes |
| Precisão dos registradores | 8 bits (0-255) |
| Divisão por zero | Detectada e ignorada (emite aviso) |

---

## 9. Localização no Código Fonte

```
src/gerador/simulador.py    # Implementação da classe CPU
simulador.py                # Interface de linha de comando
```

---

> 📅 Última atualização: Julho 2026
