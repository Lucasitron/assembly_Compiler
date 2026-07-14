# ⚙️ Gerador de Código de Máquina

> **Documento:** 05_gerador.md  
> **Descrição:** Implementação do gerador de código - tradução AST → código binário

---

## 1. Visão Geral

O gerador de código é a quarta e última fase do compilador. Sua função é traduzir a Árvore Sintática Abstrata (AST) já validada em código de máquina binário executável pela CPU Didática.

### Estratégia de Geração

- **Duas passadas:**
  1. **Primeira passada:** Calcula endereços de todas as instruções e labels
  2. **Segunda passada:** Gera os bytes do código, resolvendo referências
- **Forward references:** Suportadas via tabela de pendências

---

## 2. Conjunto de Opcodes

### 2.1 Tabela Completa

| Mnemônico | Opcode | Bytes | Formato |
|:---------:|:------:|:-----:|---------|
| `mov reg, reg` | `0x01` | 3 | `[opcode] [reg_dest] [reg_orig]` |
| `mov reg, imd` | `0x02` | 3 | `[opcode] [reg_dest] [imediato]` |
| `add reg, reg` | `0x03` | 3 | `[opcode] [reg_dest] [reg_orig]` |
| `sub reg, reg` | `0x04` | 3 | `[opcode] [reg_dest] [reg_orig]` |
| `mul reg, reg` | `0x05` | 3 | `[opcode] [reg_dest] [reg_orig]` |
| `div reg, reg` | `0x06` | 3 | `[opcode] [reg_dest] [reg_orig]` |
| `cmp reg, reg` | `0x07` | 3 | `[opcode] [reg] [reg]` |
| `cmp reg, imd` | `0x08` | 3 | `[opcode] [reg] [imediato]` |
| `jmp label` | `0x09` | 3 | `[opcode] [end_high] [end_low]` |
| `je label` | `0x0A` | 3 | `[opcode] [end_high] [end_low]` |
| `jne label` | `0x0B` | 3 | `[opcode] [end_high] [end_low]` |
| `jg label` | `0x0C` | 3 | `[opcode] [end_high] [end_low]` |
| `jl label` | `0x0D` | 3 | `[opcode] [end_high] [end_low]` |
| `jle label` | `0x0E` | 3 | `[opcode] [end_high] [end_low]` |
| `jge label` | `0x0F` | 3 | `[opcode] [end_high] [end_low]` |
| `load reg, [end]` | `0x10` | 3 | `[opcode] [reg] [endereço]` |
| `store [end], reg` | `0x11` | 3 | `[opcode] [endereço] [reg]` |
| `hlt` | `0xFF` | 1 | `[opcode]` |

### 2.2 Codificação de Registradores

| Registrador | Código |
|:-----------:|:------:|
| `a` | `0x00` |
| `b` | `0x01` |
| `c` | `0x02` |
| `d` | `0x03` |

---

## 3. Arquitetura do Gerador

### 3.1 Primeira Passada - Cálculo de Endereços

Percorre a AST calculando o endereço de cada instrução e registrando labels:

```python
def _primeira_passada(self, programa):
    endereco_atual = 0
    
    for linha in programa.linhas:
        if isinstance(linha, LinhaLabel):
            self.tabela_labels[linha.nome] = endereco_atual
        
        elif isinstance(linha, LinhaInstrucao):
            tamanho = self._calcular_tamanho(linha)
            endereco_atual += tamanho
```

### 3.2 Segunda Passada - Geração de Bytes

Percorre novamente gerando os bytes de cada instrução:

```python
def _segunda_passada(self, programa):
    for linha in programa.linhas:
        if isinstance(linha, LinhaInstrucao):
            bytes_gerados = self._gerar_instrucao(linha)
            self.codigo_maquina.extend(bytes_gerados)
```

### 3.3 Resolução de Pendências (Forward References)

Quando um jump referencia um label que ainda não foi encontrado:

```python
def _gerar_jump(self, mnem, ops, linha):
    label = ops[0].valor
    
    if label in self.tabela_labels:
        # Label já conhecido
        endereco = self.tabela_labels[label]
        return [opcode, endereco >> 8, endereco & 0xFF]
    else:
        # Forward reference - registra pendência
        self.pendencias.append((posicao_atual, label, linha))
        return [opcode, 0x00, 0x00]  # Placeholder
```

Após a segunda passada:
```python
def _resolver_pendencias(self):
    for endereco, label, linha in self.pendencias:
        endereco_label = self.tabela_labels[label]
        self.codigo_maquina[endereco] = (endereco_label >> 8) & 0xFF
        self.codigo_maquina[endereco + 1] = endereco_label & 0xFF
```

---

## 4. Exemplo de Geração

### Código Assembly

```asm
main:
    mov a, 10
    mov b, 5
    add a, b
    hlt
```

### Processo de Geração

**Passada 1 - Cálculo de endereços:**
```
Label 'main' → 0x0000
  mov a, 10   (3 bytes) → 0x0000-0x0002
  mov b, 5    (3 bytes) → 0x0003-0x0005
  add a, b    (3 bytes) → 0x0006-0x0008
  hlt         (1 byte)  → 0x0009
```

**Passada 2 - Geração de bytes:**
```
0x0000: 02 00 0A    MOV_REG_IMD a, 10
0x0003: 02 01 05    MOV_REG_IMD b, 5
0x0006: 03 00 01    ADD_REG_REG a, b
0x0009: FF          HLT
```

### Hexdump

```
Endereço | Bytes                          | ASCII
------------------------------------------------------------
0x0000  | 02 00 0A 02 01 05 03 00 01 FF  | ..........
```

---

## 5. Formatos de Saída

O gerador produz três formatos de saída:

| Formato | Método | Descrição |
|:--------|:-------|-----------|
| **Lista Python** | `gerar()` | Lista de inteiros (bytes) |
| **Arquivo binário** | `gerar_arquivo_binario()` | `.bin` - bytes brutos |
| **Hexdump** | `gerar_arquivo_hex()` | `.hex` - representação hexadecimal legível |

---

## 6. Localização no Código Fonte

```
src/gerador/
├── __init__.py          # Exporta classes e constantes
├── opcodes.py           # Definição dos opcodes e codificação
├── gerador_codigo.py    # Implementação do gerador
└── simulador.py         # Simulador da CPU (usa os opcodes)
```

---

> 📅 Última atualização: Julho 2026
