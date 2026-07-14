#!/bin/bash

# ===========================================
# GERADOR DE DOCUMENTAÇÃO - COMPILADOR ASSEMBLY DIDÁTICO
# ===========================================

echo "📝 Gerando documentação completa..."

# Criar diretório docs se não existir
mkdir -p docs

# ===========================================
# README.md PRINCIPAL (RAIZ)
# ===========================================
cat > README.md << 'READMEEOF'
# 🖥️ Compilador Assembly Didático

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Status](https://img.shields.io/badge/status-concluído-brightgreen.svg)]()
[![Licença](https://img.shields.io/badge/licença-MIT-green.svg)]()
[![Testes](https://img.shields.io/badge/testes-17%2F17%20passando-brightgreen.svg)]()

> **Compilador completo** que traduz uma linguagem Assembly Didática para código de máquina executável, desenvolvido para a disciplina de Compiladores.

---

## 📋 Sumário

- [📖 Sobre o Projeto](#-sobre-o-projeto)
- [🚀 Uso Rápido](#-uso-rápido)
- [🧠 Fases do Compilador](#-fases-do-compilador)
- [📐 Especificação da Linguagem](#-especificação-da-linguagem)
- [🔍 Linguagens Regulares](#-linguagens-regulares)
- [🌳 Linguagens Livres de Contexto](#-linguagens-livres-de-contexto)
- [⚙️ Geração de Código](#️-geração-de-código)
- [🧪 Testes](#-testes)
- [📊 Métricas do Projeto](#-métricas-do-projeto)
- [🛠️ Tecnologias](#️-tecnologias)
- [📁 Estrutura do Repositório](#-estrutura-do-repositório)
- [📚 Documentação Detalhada](#-documentação-detalhada)
- [🤝 Contribuição](#-contribuição)
- [📄 Licença](#-licença)

---

## 📖 Sobre o Projeto

O **Compilador Assembly Didático** é um compilador completo de 4 fases que traduz programas escritos em uma linguagem Assembly simplificada para código de máquina binário. O projeto abrange desde a modelagem formal (expressões regulares, autômatos finitos, gramáticas livres de contexto) até a implementação prática em Python, incluindo um simulador de CPU para execução do código gerado.

### ✨ Funcionalidades

- ✅ **4 fases de compilação**: Léxica, Sintática, Semântica e Geração de Código
- ✅ **14 instruções**: mov, add, sub, mul, div, cmp, jmp, je, jne, jg, jl, jle, jge, load, store, hlt
- ✅ **4 registradores**: a, b, c, d
- ✅ **Suporte a labels**: declaração e referência (incluindo forward references)
- ✅ **Comentários**: com `;`
- ✅ **Números decimais e hexadecimais**: `10`, `0xFF`
- ✅ **Acesso à memória**: load/store com endereçamento
- ✅ **Simulador CPU**: execução passo-a-passo com debug
- ✅ **Detecção de erros**: léxicos, sintáticos e semânticos com linha/coluna
- ✅ **Geração de binário**: arquivos `.bin` e `.hex`

---

## 🚀 Uso Rápido

### Compilar um programa

```bash
python main.py exemplos/fatorial.asm
```

**Saída:**
```
============================================================
COMPILADOR ASSEMBLY DIDÁTICO
============================================================
[1/4] ANÁLISE LÉXICA     ✅ 31 tokens encontrados
[2/4] ANÁLISE SINTÁTICA   ✅ AST gerada com sucesso
[3/4] ANÁLISE SEMÂNTICA   ✅ Sem erros
[4/4] GERAÇÃO DE CÓDIGO   ✅ 22 bytes gerados
💾 Código binário salvo em: exemplos/fatorial.bin
✅ COMPILAÇÃO CONCLUÍDA COM SUCESSO!
```

### Simular execução

```bash
python simulador.py exemplos/fatorial.asm
```

**Saída:**
```
✅ Compilado: 22 bytes gerados
✅ Execução concluída: 19 instruções executadas

ESTADO DA CPU
==================================================
Registradores:
  a: 120 (0x78)   ← 5! = 120
  b:   1 (0x01)
  c:   0 (0x00)
  d:   1 (0x01)
Flags: Z=1 C=0 N=0
```

### Modo verbose (detalhado)

```bash
python main.py exemplos/fatorial.asm -v
```

### Modo debug do simulador (passo-a-passo)

```bash
python simulador.py exemplos/fatorial.asm -d
```

### Gerar binário e hexdump personalizados

```bash
python main.py exemplos/fatorial.asm -o saida.bin --hex saida.hex
```

---

## 🧠 Fases do Compilador

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   CÓDIGO     │    │   ANÁLISE    │    │   ANÁLISE    │    │   ANÁLISE    │
│   FONTE      │───▶│   LÉXICA     │───▶│   SINTÁTICA  │───▶│   SEMÂNTICA  │
│  (.asm)      │    │  (tokens)    │    │    (AST)     │    │ (verificações)│
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
                                                                   │
                                                                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   CÓDIGO     │    │   SIMULADOR  │    │   GERADOR    │    │   ANÁLISE    │
│   BINÁRIO    │◀───│     CPU      │◀───│   DE CÓDIGO  │◀───│   SEMÂNTICA  │
│   (.bin)     │    │  (execução)  │    │  (opcodes)   │    │ (verificações)│
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
```

| Fase | Descrição | Entrada | Saída |
|:----:|-----------|---------|-------|
| **1. Léxica** | Tokenização do código fonte | Texto `.asm` | Lista de 31 tipos de tokens |
| **2. Sintática** | Construção da árvore sintática | Tokens | AST (Árvore Sintática Abstrata) |
| **3. Semântica** | Verificação de tipos e labels | AST | AST validada + Tabela de Símbolos |
| **4. Geração** | Tradução para código de máquina | AST validada | Código binário (18 opcodes) |

---

## 📐 Especificação da Linguagem

### Registradores

| Registrador | Descrição |
|:-----------:|-----------|
| `a` | Registrador de propósito geral |
| `b` | Registrador de propósito geral |
| `c` | Registrador de propósito geral |
| `d` | Registrador de propósito geral |

### Conjunto de Instruções

| Mnemônico | Operandos | Descrição |
|:---------:|:---------:|-----------|
| `mov` | `reg, valor` | Move um valor (reg ou imediato) para um registrador |
| `add` | `reg, reg` | Soma dois registradores |
| `sub` | `reg, reg` | Subtrai dois registradores |
| `mul` | `reg, reg` | Multiplica dois registradores |
| `div` | `reg, reg` | Divide dois registradores |
| `cmp` | `reg, valor` | Compara registrador com valor |
| `jmp` | `label` | Salto incondicional |
| `je` | `label` | Salta se igual (ZF=1) |
| `jne` | `label` | Salta se diferente (ZF=0) |
| `jg` | `label` | Salta se maior |
| `jl` | `label` | Salta se menor |
| `jle` | `label` | Salta se menor ou igual |
| `jge` | `label` | Salta se maior ou igual |
| `load` | `reg, [valor]` | Carrega da memória para registrador |
| `store` | `[valor], reg` | Armazena registrador na memória |
| `hlt` | — | Encerra a execução |

### Exemplo de Programa

```asm
; Programa: Fatorial de 5
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

---

## 🔍 Linguagens Regulares

### Alfabeto (Σ)

```text
Σ = {
  a-z, 0-9,
  [, ], ,, :, ;,
  espaço, tabulação, quebra de linha
}
```

### Tokens e Expressões Regulares

| Categoria | Token | Expressão Regular | Exemplos |
|:---------:|:-----:|:-----------------:|:--------:|
| **Símbolos** | `VIRGULA` | `,` | `,` |
| | `DOIS_PONTOS` | `:` | `:` |
| | `PONTO_VIRGULA` | `;` | `;` |
| | `ABRE_COL` | `[` | `[` |
| | `FECHA_COL` | `]` | `]` |
| **Números** | `NUM` | `[0-9]+` | `10`, `255` |
| | `HEX` | `0x[0-9a-f]+` | `0xFF`, `0x1A` |
| **Identificadores** | `REG` | `[a-d]` | `a`, `b` |
| | `ID` | `[a-z][a-z0-9]*` | `main`, `loop1` |
| **Reservadas** | `MNEMONIC` | `mov\|add\|...\|hlt` | `mov`, `hlt` |

### Autômato Finito Determinístico (AFD)

O AFD unificado reconhece todos os tokens da linguagem:

![AFD Unificado](jflap/png/completo.png)

**Estados do AFD:**

| Estado | Tipo | Token Reconhecido |
|:------:|:----:|:-----------------:|
| `q0` | Inicial | — |
| `q1` | Final | `NUM` (inteiros) |
| `q2` | Final | Símbolos |
| `q3` | Final | `ID` / `REG` / `MNEMONIC` |
| `q4` | Final | `HEX` (hexadecimais) |
| `q5` | Intermediário | Prefixo `0x` |
| `q6` | Final | `NUM` (zero) |

> 📚 Detalhes completos: [docs/02_lexico.md](docs/02_lexico.md)

---

## 🌳 Linguagens Livres de Contexto

### Gramática Livre de Contexto (GLC)

```text
G = ({PROG, LINHAS, LINHA, INSTR, LABEL, REG, VALOR, NUM, ID}, Σ', P, PROG)
```

#### Produções Principais

```text
<PROG>    → <LINHAS>

<LINHAS>  → <LINHA> | <LINHA> <LINHAS>

<LINHA>   → <INSTR> | <LABEL> | <COMENT>

<LABEL>   → <ID> :

<INSTR>   → mov <REG> , <VALOR>
          | add <REG> , <REG>
          | sub <REG> , <REG>
          | mul <REG> , <REG>
          | div <REG> , <REG>
          | cmp <REG> , <VALOR>
          | jmp <ID>
          | je  <ID>  | jne <ID>
          | jg  <ID>  | jl  <ID>
          | jle <ID>  | jge <ID>
          | load <REG> , [ <VALOR> ]
          | store [ <VALOR> ] , <REG>
          | hlt

<REG>     → a | b | c | d

<VALOR>   → <NUM> | <REG>
```

> 📚 Detalhes completos: [docs/03_sintatico.md](docs/03_sintatico.md)

---

## ⚙️ Geração de Código

### Conjunto de Opcodes

| Mnemônico | Opcode | Bytes | Descrição |
|:---------:|:------:|:-----:|-----------|
| `mov reg, reg` | `0x01` | 3 | Move registrador para registrador |
| `mov reg, imd` | `0x02` | 3 | Move imediato para registrador |
| `add reg, reg` | `0x03` | 3 | Soma registradores |
| `sub reg, reg` | `0x04` | 3 | Subtrai registradores |
| `mul reg, reg` | `0x05` | 3 | Multiplica registradores |
| `div reg, reg` | `0x06` | 3 | Divide registradores |
| `cmp reg, reg` | `0x07` | 3 | Compara registradores |
| `cmp reg, imd` | `0x08` | 3 | Compara com imediato |
| `jmp label` | `0x09` | 3 | Salto incondicional |
| `je label` | `0x0A` | 3 | Salto se igual |
| `jne label` | `0x0B` | 3 | Salto se diferente |
| `jg label` | `0x0C` | 3 | Salto se maior |
| `jl label` | `0x0D` | 3 | Salto se menor |
| `jle label` | `0x0E` | 3 | Salto se menor ou igual |
| `jge label` | `0x0F` | 3 | Salto se maior ou igual |
| `load reg, [end]` | `0x10` | 3 | Carrega da memória |
| `store [end], reg` | `0x11` | 3 | Armazena na memória |
| `hlt` | `0xFF` | 1 | Para execução |

### Codificação de Registradores

| Registrador | Código |
|:-----------:|:------:|
| `a` | `0x00` |
| `b` | `0x01` |
| `c` | `0x02` |
| `d` | `0x03` |

### Exemplo de Geração

```asm
; Código Assembly
mov a, 10
mov b, 5
add a, b
hlt

; Código de Máquina (hexdump)
0x0000 | 02 00 0A 02 01 05 03 00 01 FF
         │  │  │  │  │  │  │  │  │  └── HLT
         │  │  │  │  │  │  │  │  └───── reg b (origem)
         │  │  │  │  │  │  │  └──────── reg a (destino)
         │  │  │  │  │  │  └─────────── ADD_REG_REG
         │  │  │  │  │  └────────────── valor 5
         │  │  │  │  └───────────────── reg b (destino)
         │  │  │  └──────────────────── MOV_REG_IMD
         │  │  └─────────────────────── valor 10
         │  └────────────────────────── reg a (destino)
         └───────────────────────────── MOV_REG_IMD
```

> 📚 Detalhes completos: [docs/05_gerador.md](docs/05_gerador.md)

---

## 🧪 Testes

O projeto inclui uma suíte completa de testes automatizados:

| Arquivo de Teste | Descrição | Testes |
|:-----------------|-----------|:------:|
| `tests/lexico.py` | Testes do analisador léxico | — |
| `tests/sintatico.py` | Testes do parser e AST | 9 |
| `tests/semantico.py` | Testes de verificação semântica | 17 |
| `tests/compilador_completo.py` | Testes de integração (4 fases) | 20+ |
| `tests/integracao.py` | Geração de executáveis | 8 |

### Executar todos os testes

```bash
python tests/compilador_completo.py
cat tests/saidas/resultado_testes.txt
```

**Resultado típico:**
```
✅ 17/17 testes semânticos passando
✅ 20+ testes de integração passando
✅ 8 executáveis gerados com sucesso
```

---

## 📊 Métricas do Projeto

| Métrica | Valor |
|:--------|:-----:|
| **Tokens implementados** | 31 |
| **Instruções suportadas** | 16 |
| **Opcodes definidos** | 18 |
| **Fases do compilador** | 4/4 |
| **Testes unitários** | 17+ |
| **Testes de integração** | 20+ |
| **Programas de exemplo** | 11 |
| **Linhas de código** | ~2.500+ |
| **Cobertura de instruções** | 100% |

---

## 🛠️ Tecnologias

| Tecnologia | Uso |
|:-----------|:----|
| **Python 3.8+** | Linguagem de implementação |
| **JFLAP** | Modelagem de AFD e GLC |
| **Enum** | Definição de tokens e opcodes |
| **unittest/pytest** | Framework de testes |

---

## 📁 Estrutura do Repositório

```text
compilador_assembly/
├── README.md                         # Documentação principal (este arquivo)
├── main.py                           # Compilador principal (4 fases)
├── simulador.py                      # Simulador da CPU Didática
├── testar_tudo.sh                    # Script de teste automatizado
│
├── docs/                             # Documentação detalhada
│   ├── 01_linguagem.md               # Especificação da linguagem
│   ├── 02_lexico.md                  # Analisador léxico
│   ├── 03_sintatico.md               # Analisador sintático
│   ├── 04_semantico.md               # Analisador semântico
│   ├── 05_gerador.md                 # Gerador de código
│   ├── 06_simulador.md               # Simulador CPU
│   ├── 07_opcodes.md                 # Referência de opcodes
│   └── 08_exemplos.md                # Exemplos comentados
│
├── src/                              # Código fonte
│   ├── lexico/                       # Fase 1: Analisador léxico
│   │   ├── token.py                  # Definição de tokens (31 tipos)
│   │   └── lexer.py                  # Tokenizador (AFD implementado)
│   ├── sintatico/                    # Fase 2: Analisador sintático
│   │   ├── ast.py                    # Árvore Sintática Abstrata
│   │   └── parser.py                 # Parser recursivo descendente
│   ├── semantico/                    # Fase 3: Analisador semântico
│   │   ├── tabela_simbolos.py        # Tabela de símbolos
│   │   └── analisador_semantico.py   # Verificador de tipos e regras
│   └── gerador/                      # Fase 4: Gerador de código
│       ├── opcodes.py                # Conjunto de instruções (18 opcodes)
│       ├── gerador_codigo.py         # Gerador de código binário
│       └── simulador.py              # Simulador da CPU virtual
│
├── exemplos/                         # Programas de exemplo (.asm)
│   ├── teste.asm                     # Soma de 1 a 10
│   ├── fatorial.asm                  # Cálculo de fatorial
│   ├── maior_numero.asm              # Condicional (maior número)
│   ├── soma_memoria.asm              # Teste de load/store
│   └── teste_completo.asm            # Todas as instruções
│
├── tests/                            # Testes automatizados
│   ├── lexico.py                     # Testes do léxico
│   ├── sintatico.py                  # Testes do sintático
│   ├── semantico.py                  # Testes do semântico
│   ├── compilador_completo.py        # Testes de integração
│   ├── integracao.py                 # Geração de executáveis
│   └── saidas/                       # Resultados dos testes
│
├── jflap/                            # Modelos JFLAP
│   ├── afd.jff                       # AFD principal
│   ├── glc.jff                       # GLC
│   ├── inteiros.jff                  # AFD de inteiros
│   ├── hex.jff                       # AFD de hexadecimais
│   ├── identificador.jff             # AFD de identificadores
│   └── png/                          # Diagramas exportados
│       ├── completo.png              # AFD unificado
│       ├── int.png                   # AFD de inteiros
│       ├── hex.png                   # AFD de hexadecimais
│       ├── identificador.png         # AFD de identificadores
│       └── symbol.png                # AFD de símbolos
│
└── saidas/                           # Arquivos gerados
    ├── *.bin                          # Código binário
    └── *.hex                          # Hexdump
```

---

## 📚 Documentação Detalhada

Documentação aprofundada de cada componente está disponível em `docs/`:

| Documento | Conteúdo |
|:----------|:---------|
| [`01_linguagem.md`](docs/01_linguagem.md) | Especificação completa da linguagem fonte |
| [`02_lexico.md`](docs/02_lexico.md) | Expressões regulares, AFD, implementação do tokenizador |
| [`03_sintatico.md`](docs/03_sintatico.md) | GLC, classes da AST, parser recursivo |
| [`04_semantico.md`](docs/04_semantico.md) | Tabela de símbolos, regras semânticas, verificações |
| [`05_gerador.md`](docs/05_gerador.md) | Opcodes, formato binário, resolução de endereços |
| [`06_simulador.md`](docs/06_simulador.md) | Arquitetura da CPU virtual, flags, ciclo de execução |
| [`07_opcodes.md`](docs/07_opcodes.md) | Referência completa do conjunto de instruções |
| [`08_exemplos.md`](docs/08_exemplos.md) | Programas exemplo comentados com saída esperada |

---

## 🤝 Contribuição

Este é um projeto acadêmico da disciplina de Compiladores, mas contribuições são bem-vindas!

### Como contribuir

1. Faça um fork do repositório
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit suas mudanças: `git commit -m 'Adiciona nova funcionalidade'`
4. Push para a branch: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

### Convenções de código

- Python: PEP 8
- Comentários em português
- Testes para novas funcionalidades
- Documentação atualizada

---

## 📄 Licença

Este projeto é parte de um trabalho acadêmico da disciplina de **Compiladores** e está licenciado sob a licença MIT.

---

> 📅 Última atualização: Julho 2026
> 
> 🎓 Desenvolvido para a disciplina de Compiladores - Construção completa de um compilador didático, desde a modelagem formal até a geração de código executável.

READMEEOF

echo "✅ README.md principal gerado"

# ===========================================
# docs/01_linguagem.md
# ===========================================
cat > docs/01_linguagem.md << 'DOCEOF'
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
DOCEOF

echo "✅ docs/01_linguagem.md gerado"

# ===========================================
# docs/02_lexico.md
# ===========================================
cat > docs/02_lexico.md << 'DOCEOF'
# 🔍 Analisador Léxico

> **Documento:** 02_lexico.md  
> **Descrição:** Implementação do analisador léxico - tokenização do código fonte

---

## 1. Visão Geral

O analisador léxico (lexer/scanner) é a primeira fase do compilador. Sua função é ler o código fonte como uma sequência de caracteres e convertê-lo em uma sequência de **tokens** (símbolos léxicos) que serão usados pelo analisador sintático.

### Responsabilidades

- ✅ Identificar tokens válidos
- ✅ Ignorar espaços em branco e comentários
- ✅ Detectar erros léxicos (caracteres inválidos, hexadecimais mal formados)
- ✅ Fornecer informações de linha/coluna para mensagens de erro

---

## 2. Tokens Definidos (31 tipos)

### 2.1 Tokens de Registradores

| Token | Valor | Descrição |
|:------|:-----:|-----------|
| `REG` | `a`, `b`, `c`, `d` | Um dos 4 registradores |

### 2.2 Tokens de Valores Numéricos

| Token | Exemplos | Descrição |
|:------|----------|-----------|
| `NUM` | `10`, `255`, `0` | Número decimal |
| `HEX` | `0xFF`, `0x1A` | Número hexadecimal |

### 2.3 Tokens de Mnemônicos (16 instruções)

| Token | Mnemônico | Categoria |
|:------|:---------:|-----------|
| `MOV` | `mov` | Movimentação |
| `ADD` | `add` | Aritmética |
| `SUB` | `sub` | Aritmética |
| `MUL` | `mul` | Aritmética |
| `DIV` | `div` | Aritmética |
| `CMP` | `cmp` | Comparação |
| `JMP` | `jmp` | Salto |
| `JE` | `je` | Salto condicional |
| `JNE` | `jne` | Salto condicional |
| `JG` | `jg` | Salto condicional |
| `JL` | `jl` | Salto condicional |
| `JLE` | `jle` | Salto condicional |
| `JGE` | `jge` | Salto condicional |
| `LOAD` | `load` | Memória |
| `STORE` | `store` | Memória |
| `HLT` | `hlt` | Controle |

### 2.4 Tokens de Símbolos

| Token | Símbolo |
|:------|:-------:|
| `VIRGULA` | `,` |
| `DOIS_PONTOS` | `:` |
| `PONTO_VIRGULA` | `;` |
| `ABRE_COL` | `[` |
| `FECHA_COL` | `]` |

### 2.5 Tokens Especiais

| Token | Descrição |
|:------|-----------|
| `ID` | Identificador (label) |
| `EOF` | Fim de arquivo |
| `INVALIDO` | Token inválido (erro) |

---

## 3. Expressões Regulares

| Categoria | Token | ER |
|:---------:|:-----:|:--:|
| Símbolos | `VIRGULA` | `,` |
| | `DOIS_PONTOS` | `:` |
| | `PONTO_VIRGULA` | `;` |
| | `ABRE_COL` | `[` |
| | `FECHA_COL` | `]` |
| Números | `NUM` | `[0-9]+` |
| | `HEX` | `0x[0-9a-f]+` |
| Identificadores | `REG` | `[a-d]` |
| | `ID` | `[a-z][a-z0-9]*` |
| Reservadas | `MNEMONIC` | `mov\|add\|sub\|mul\|div\|cmp\|jmp\|je\|jne\|jg\|jl\|jle\|jge\|load\|store\|hlt` |

---

## 4. Autômato Finito Determinístico (AFD)

### 4.1 Componentes do AFD

O AFD da linguagem pode ser decomposto em autômatos menores para cada categoria de token:

#### Inteiros

![AFD Inteiros](../jflap/png/int.png)

#### Hexadecimais

![AFD Hexadecimais](../jflap/png/hex.png)

#### Identificadores

![AFD Identificadores](../jflap/png/identificador.png)

#### Símbolos

![AFD Símbolos](../jflap/png/symbol.png)

### 4.2 AFD Unificado

O autômato completo que reconhece todos os tokens:

![AFD Unificado](../jflap/png/completo.png)

### 4.3 Tabela de Transições

| Estado | Tipo | Transições | Token |
|:------:|:----:|------------|:-----:|
| `q0` | Inicial | `1-9 → q1` · `0 → q6` · `a-z → q3` · `,;:[] → q2` | — |
| `q1` | Final | `0-9 → q1` | `NUM` |
| `q2` | Final | — | Símbolo |
| `q3` | Final | `a-z,0-9 → q3` | `ID`/`REG`/`MNEMONIC` |
| `q4` | Final | `0-9,a-f → q4` | `HEX` |
| `q5` | Intermediário | `0-9,a-f → q4` | — |
| `q6` | Final | `0-9 → q1` · `x → q5` | `NUM` (zero) |

---

## 5. Implementação em Python

### 5.1 Estrutura do Token

```python
class Token:
    def __init__(self, tipo, valor, linha, coluna):
        self.tipo = tipo        # TokenType (enum)
        self.valor = valor      # String do token
        self.linha = linha      # Linha no código fonte
        self.coluna = coluna    # Coluna no código fonte
```

### 5.2 Arquitetura do Lexer

O lexer é implementado como uma classe `Lexer` que percorre o código fonte caractere por caractere:

```python
class Lexer:
    def __init__(self, codigo_fonte):
        self.codigo = codigo_fonte
        self.pos = 0
        self.linha = 1
        self.coluna = 1
        self.tokens = []
        self.erros = []
    
    def tokenizar(self):
        """Analisa todo o código fonte e retorna a lista de tokens"""
        while self.pos < len(self.codigo):
            char = self.codigo[self.pos]
            
            if char in ' \t':       self.avancar()      # Ignora espaços
            elif char == '\n':      self.linha += 1      # Conta linha
            elif char == ';':       self.ler_comentario() # Pula comentário
            elif char == '0' and self.peek() == 'x':      # Hex
                self.ler_hex()
            elif char.isdigit():    self.ler_numero()    # Decimal
            elif char.isalpha():    self.ler_identificador() # ID/REG/MNEM
            else:                   self.ler_simbolo()   # Símbolos
```

### 5.3 Palavras Reservadas

```python
PALAVRAS_RESERVADAS = {
    'mov': TokenType.MOV, 'add': TokenType.ADD,
    'sub': TokenType.SUB, 'mul': TokenType.MUL,
    'div': TokenType.DIV, 'cmp': TokenType.CMP,
    'jmp': TokenType.JMP, 'je': TokenType.JE,
    'jne': TokenType.JNE, 'jg': TokenType.JG,
    'jl': TokenType.JL, 'jle': TokenType.JLE,
    'jge': TokenType.JGE, 'load': TokenType.LOAD,
    'store': TokenType.STORE, 'hlt': TokenType.HLT,
}
```

---

## 6. Tratamento de Erros Léxicos

O analisador léxico detecta e reporta os seguintes erros:

| Erro | Exemplo | Mensagem |
|------|---------|----------|
| Caractere inválido | `@`, `#`, `&` | "Caractere inválido '@' na linha X, coluna Y" |
| Hexadecimal inválido | `0x` (sem dígitos) | "Hexadecimal inválido '0x' na linha X, coluna Y" |
| Hexadecimal com dígitos inválidos | `0xGG` | (tratado como `0x` + identificador) |

---

## 7. Exemplo de Tokenização

### Código Fonte

```asm
; Programa de exemplo
main:
    mov a, 10
    add a, b
    hlt
```

### Tokens Gerados

```text
Token(ID           | 'main'   | linha=2, col=2)
Token(DOIS_PONTOS  | ':'      | linha=2, col=6)
Token(MOV          | 'mov'    | linha=3, col=6)
Token(REG          | 'a'      | linha=3, col=10)
Token(VIRGULA      | ','      | linha=3, col=11)
Token(NUM          | '10'     | linha=3, col=13)
Token(ADD          | 'add'    | linha=4, col=6)
Token(REG          | 'a'      | linha=4, col=10)
Token(VIRGULA      | ','      | linha=4, col=11)
Token(REG          | 'b'      | linha=4, col=13)
Token(HLT          | 'hlt'    | linha=5, col=6)
Token(EOF          | ''       | linha=5, col=9)
```

> **Observação:** Tokens de `PONTO_VIRGULA` (comentários) são filtrados após a tokenização e não aparecem na saída.

---

## 8. Localização no Código Fonte

```
src/lexico/
├── __init__.py      # Exporta Token, TokenType, Lexer
├── token.py         # Definição dos tipos de tokens (TokenType enum)
└── lexer.py         # Implementação do analisador léxico
```

---

> 📅 Última atualização: Julho 2026
DOCEOF

echo "✅ docs/02_lexico.md gerado"

# ===========================================
# docs/03_sintatico.md
# ===========================================
cat > docs/03_sintatico.md << 'DOCEOF'
# 🌳 Analisador Sintático

> **Documento:** 03_sintatico.md  
> **Descrição:** Implementação do parser - construção da Árvore Sintática Abstrata (AST)

---

## 1. Visão Geral

O analisador sintático (parser) é a segunda fase do compilador. Sua função é receber a sequência de tokens do analisador léxico e construir uma **Árvore Sintática Abstrata (AST)** que representa a estrutura hierárquica do programa.

### Características do Parser

- **Tipo:** Preditivo recursivo descendente (Top-Down)
- **Gramática:** LL(1) (com validação semântica adicional para escolha de produções)
- **Estratégia:** Cada não-terminal da gramática corresponde a um método da classe `Parser`
- **Tratamento de erros:** Recuperação por sincronização (panic mode)

---

## 2. Gramática Livre de Contexto (GLC)

### 2.1 Produções Completas

```text
<programa>    → <linhas>

<linhas>      → <linha> <linhas>
              | ε

<linha>       → <label>
              | <instrucao>
              | ε

<label>       → ID DOIS_PONTOS

<instrucao>   → MOV REG VIRGULA <valor>
              | ADD REG VIRGULA REG
              | SUB REG VIRGULA REG
              | MUL REG VIRGULA REG
              | DIV REG VIRGULA REG
              | CMP REG VIRGULA <valor>
              | JMP ID
              | JE ID
              | JNE ID
              | JG ID
              | JL ID
              | JLE ID
              | JGE ID
              | LOAD REG VIRGULA ABRE_COL <valor> FECHA_COL
              | STORE ABRE_COL <valor> FECHA_COL VIRGULA REG
              | HLT

<valor>       → REG
              | NUM
              | HEX

<reg>         → REG
```

### 2.2 Símbolos Não-Terminais

| Símbolo | Descrição |
|:--------|-----------|
| `<programa>` | Raiz da gramática |
| `<linhas>` | Sequência de linhas |
| `<linha>` | Uma linha do programa |
| `<label>` | Definição de label |
| `<instrucao>` | Uma instrução |
| `<valor>` | Operando (registrador ou imediato) |
| `<reg>` | Registrador |

### 2.3 Símbolos Terminais

| Terminal | Categoria |
|:---------|:----------|
| `ID` | Identificador (label) |
| `REG` | Registrador (a-d) |
| `NUM` | Número decimal |
| `HEX` | Número hexadecimal |
| `VIRGULA` | `,` |
| `DOIS_PONTOS` | `:` |
| `ABRE_COL` | `[` |
| `FECHA_COL` | `]` |
| `MOV`, `ADD`, `SUB`, ... | Mnemônicos |

---

## 3. Árvore Sintática Abstrata (AST)

### 3.1 Hierarquia de Classes

```
NoAST (abstrato)
├── Programa
│   └── linhas: List[NoAST]
├── LinhaLabel
│   └── nome: str
├── LinhaInstrucao
│   ├── mnemonico: str
│   └── operandos: List[Operando]
└── Operando
    ├── tipo: str ('reg', 'num', 'hex', 'id', 'mem')
    └── valor: str

OperandoMemoria (herda de Operando)
    └── endereco: Operando
```

### 3.2 Exemplo de AST

**Código fonte:**
```asm
main:
    mov a, 10
    add a, b
    hlt
```

**AST gerada:**
```
Programa[
  Label(main)
  Instrucao(mov, [Reg(a), Num(10)])
  Instrucao(add, [Reg(a), Reg(b)])
  Instrucao(hlt)
]
```

---

## 4. Implementação do Parser

### 4.1 Estrutura Principal

```python
class Parser:
    def __init__(self, tokens, verbose=False):
        self.tokens = tokens    # Lista de tokens (sem comentários)
        self.pos = 0            # Posição atual
        self.token_atual = tokens[0]
        self.erros = []         # Lista de erros sintáticos
    
    def programa(self):
        """<programa> → <linhas>"""
        pass
    
    def linhas(self):
        """<linhas> → <linha> <linhas> | ε"""
        pass
    
    def linha(self):
        """<linha> → <label> | <instrucao>"""
        pass
    
    def label(self):
        """<label> → ID DOIS_PONTOS"""
        pass
    
    def instrucao(self):
        """<instrucao> → MNEMONIC <operandos>"""
        pass
```

### 4.2 Método de Decisão

O parser decide qual produção usar baseado no token atual:

```python
def linha(self):
    if self.token_atual.tipo == TokenType.ID:
        # Verifica se o próximo token é ':'
        if self.tokens[self.pos + 1].tipo == TokenType.DOIS_PONTOS:
            return self.label()  # É um label
        else:
            return self.instrucao()  # É uma instrução (jump)
    
    elif self.token_atual.tipo in [MOV, ADD, SUB, ...]:
        return self.instrucao()  # É uma instrução
```

### 4.3 Processamento de Instruções

Cada instrução tem um método específico para validar seus operandos:

```python
def operandos(self, mnemonico):
    # Instruções sem operandos
    if mnemonico == 'hlt':
        return []
    
    # Instruções com 1 operando (jumps)
    elif mnemonico in ['jmp', 'je', 'jne', 'jg', 'jl', 'jle', 'jge']:
        return self.operando_um()  # → [Operando(id)]
    
    # Instruções com 2 operandos
    elif mnemonico in ['mov', 'add', 'sub', 'mul', 'div', 'cmp']:
        return self.operando_dois()
    
    # Instruções especiais
    elif mnemonico == 'load':
        return self.operando_load()  # reg, [mem]
    elif mnemonico == 'store':
        return self.operando_store() # [mem], reg
```

---

## 5. Tratamento de Erros Sintáticos

### 5.1 Estratégia de Recuperação

Quando um erro sintático é encontrado, o parser tenta **sincronizar** avançando até encontrar um token "seguro" que indique o início de uma nova construção:

```python
def sincronizar(self):
    tokens_seguros = [ID, MOV, ADD, SUB, MUL, DIV, CMP, 
                      JMP, JE, JNE, JG, JL, JLE, JGE, 
                      LOAD, STORE, HLT]
    
    while self.token_atual.tipo not in tokens_seguros:
        self.avancar()
```

### 5.2 Tipos de Erros Detectados

| Erro | Exemplo | Mensagem |
|------|---------|----------|
| Token inesperado | `@label:` | "Token inesperado: INVALIDO ('@')" |
| ID sozinho | `loop` (sem `:`) | "Identificador 'loop' inesperado" |
| Operando inválido | `mov [a], 10` | "Esperado REG, encontrado ABRE_COL" |
| Faltando vírgula | `mov a 10` | "Esperado VIRGULA, encontrado NUM" |

---

## 6. Exemplo de Análise Sintática

### Entrada (Tokens)

```
ID('main') DOIS_PONTOS(';') MOV('mov') REG('a') VIRGULA(',') NUM('10') HLT('hlt') EOF('')
```

### Processo de Derivação

```
<programa>
  → <linhas>
    → <linha> <linhas>
      → <label> <linhas>
        → ID DOIS_PONTOS <linhas>       // main:
        → <linha> <linhas>
          → <instrucao> <linhas>
            → MOV REG VIRGULA <valor> <linhas>  // mov a, 10
            → MOV REG VIRGULA NUM <linhas>
            → <linha>
              → <instrucao>
                → HLT                // hlt
              → ε
```

### AST Resultante

```
Programa[
  Label('main')
  Instrucao('mov', [Reg('a'), Num('10')])
  Instrucao('hlt', [])
]
```

---

## 7. Localização no Código Fonte

```
src/sintatico/
├── __init__.py      # Exporta Parser, classes AST
├── ast.py           # Definição das classes da AST
└── parser.py        # Implementação do parser recursivo
```

---

> 📅 Última atualização: Julho 2026
DOCEOF

echo "✅ docs/03_sintatico.md gerado"

# ===========================================
# docs/04_semantico.md
# ===========================================
cat > docs/04_semantico.md << 'DOCEOF'
# ✅ Analisador Semântico

> **Documento:** 04_semantico.md  
> **Descrição:** Implementação da análise semântica - verificação de tipos, labels e regras

---

## 1. Visão Geral

O analisador semântico é a terceira fase do compilador. Sua função é verificar se o programa, embora sintaticamente correto, obedece às regras semânticas da linguagem. Enquanto o parser verifica a **forma**, o analisador semântico verifica o **significado**.

### Responsabilidades

- ✅ Construir e gerenciar a **Tabela de Símbolos**
- ✅ Verificar se labels referenciados foram definidos
- ✅ Detectar labels duplicados
- ✅ Validar tipos de operandos para cada instrução
- ✅ Emitir avisos sobre código potencialmente problemático

---

## 2. Tabela de Símbolos

### 2.1 Estrutura

```python
class TabelaSimbolos:
    def __init__(self):
        self.simbolos = {}  # nome → Simbolo
    
class Simbolo:
    def __init__(self, nome, tipo, linha, coluna):
        self.nome = nome
        self.tipo = tipo           # 'label' ou 'constante'
        self.linha = linha
        self.coluna = coluna
        self.referencias = []      # Onde foi referenciado
```

### 2.2 Operações

| Operação | Descrição |
|:---------|-----------|
| `adicionar(nome, tipo, linha, coluna)` | Insere novo símbolo (falha se duplicado) |
| `obter(nome)` | Recupera um símbolo pelo nome |
| `existe(nome)` | Verifica se símbolo existe |
| `adicionar_referencia(nome, linha, coluna)` | Registra onde um label foi usado |

### 2.3 Exemplo de Tabela

**Código:**
```asm
main:
    mov a, 10
    jmp fim
fim:
    hlt
```

**Tabela de Símbolos gerada:**
```
Tabela de Símbolos:
--------------------------------------------------
Simbolo(label: main, linha=1)
Simbolo(label: fim, linha=3)
  Referenciado em: [(2, 10)]
```

---

## 3. Regras Semânticas por Instrução

### 3.1 Movimentação (`mov`, `cmp`)

| Regra | Exemplo Válido | Exemplo Inválido |
|:------|:--------------:|:----------------:|
| Destino deve ser registrador | `mov a, 10` | `mov 10, a` ❌ |
| Origem pode ser reg/num/hex | `mov a, b` | — |

### 3.2 Aritmética (`add`, `sub`, `mul`, `div`)

| Regra | Exemplo Válido | Exemplo Inválido |
|:------|:--------------:|:----------------:|
| Ambos operandos devem ser registradores | `add a, b` | `add a, 10` ❌ |
| Uso de imediato requer `mov` antes | `mov b, 10` + `add a, b` | — |

### 3.3 Saltos (`jmp`, `je`, `jne`, `jg`, `jl`, `jle`, `jge`)

| Regra | Exemplo Válido | Exemplo Inválido |
|:------|:--------------:|:----------------:|
| Operando deve ser label | `jmp loop` | `jmp 10` ❌ |
| Label deve existir | `jmp fim` (fim definido) | `jmp inexistente` ❌ |

### 3.4 Memória (`load`, `store`)

| Regra | Exemplo Válido | Exemplo Inválido |
|:------|:--------------:|:----------------:|
| `load` destino deve ser registrador | `load a, [0x10]` | `load 10, [a]` ❌ |
| `load` fonte deve ser `[end]` | `load a, [b]` | `load a, b` ❌ |
| `store` destino deve ser `[end]` | `store [0xFF], a` | `store a, [0xFF]` ❌ |
| `store` fonte deve ser registrador | `store [0x10], a` | `store [0x10], 10` ❌ |

---

## 4. Verificações Implementadas

### 4.1 Primeira Passada - Coleta de Labels

Percorre a AST e registra todos os labels na tabela de símbolos:

```python
def _coletar_labels(self, programa):
    for linha in programa.linhas:
        if isinstance(linha, LinhaLabel):
            if not self.tabela.adicionar(linha.nome, 'label', ...):
                self.erro(f"Label '{linha.nome}' já definido")
```

### 4.2 Segunda Passada - Análise de Instruções

Analisa cada instrução verificando tipos de operandos e referências:

```python
def _analisar_instrucao(self, instrucao, ...):
    if mnem == 'mov' or mnem == 'cmp':
        self._verificar_mov_cmp(instrucao)
    elif mnem in ['add', 'sub', 'mul', 'div']:
        self._verificar_aritmetica(instrucao)
    elif mnem in ['jmp', 'je', ...]:
        self._verificar_jump(instrucao)
    # ...
```

### 4.3 Verificações Finais

Após analisar todas as instruções:

```python
def _verificacoes_finais(self):
    # Labels definidos mas nunca referenciados (exceto 'main')
    nao_referenciados = self.tabela.verificar_labels_nao_referenciados()
    for simbolo in nao_referenciados:
        if simbolo.nome != 'main':
            self.aviso(f"Label '{simbolo.nome}' nunca referenciado")
```

---

## 5. Mensagens de Erro e Aviso

### 5.1 Erros (impedem a compilação)

| Código | Mensagem |
|:------:|----------|
| E001 | "Label 'X' já definido anteriormente" |
| E002 | "Label 'X' não definido" |
| E003 | "Primeiro operando de mov deve ser registrador, encontrado num" |
| E004 | "Operando 2 de add deve ser registrador, encontrado num" |
| E005 | "Primeiro operando de store deve ser [endereço]" |
| E006 | "Segundo operando de load deve ser [endereço]" |

### 5.2 Avisos (não impedem a compilação)

| Código | Mensagem |
|:------:|----------|
| W001 | "Programa contém apenas HLT" |
| W002 | "Label 'X' definido mas nunca referenciado" |
| W003 | "Jump para label 'X' ignora instruções intermediárias" |
| W004 | "Instruções após HLT nunca serão executadas" |

---

## 6. Exemplo de Análise Semântica

### Programa Correto

```asm
main:
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

**Resultado:**
```
✅ Análise semântica concluída - Sem erros
📌 Avisos (2):
  ⚠️  Jump para label 'igual' ignora instruções intermediárias
  ⚠️  Jump para label 'fim' ignora instruções intermediárias
```

### Programa com Erros

```asm
main:
    mov 10, a       ; Erro: destino inválido
    add a, 10       ; Erro: add só aceita registradores
    jmp inexistente ; Erro: label não definido
    hlt
```

**Resultado:**
```
❌ Erros (3):
  🚫 Primeiro operando de mov deve ser registrador, encontrado num
  🚫 Operando 2 de add deve ser registrador, encontrado num
  🚫 Label 'inexistente' não definido
```

---

## 7. Localização no Código Fonte

```
src/semantico/
├── __init__.py                  # Exporta classes
├── tabela_simbolos.py           # Tabela de Símbolos e classe Simbolo
└── analisador_semantico.py      # Implementação das verificações
```

---

> 📅 Última atualização: Julho 2026
DOCEOF

echo "✅ docs/04_semantico.md gerado"

# ===========================================
# docs/05_gerador.md
# ===========================================
cat > docs/05_gerador.md << 'DOCEOF'
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
DOCEOF

echo "✅ docs/05_gerador.md gerado"

# ===========================================
# docs/06_simulador.md
# ===========================================
cat > docs/06_simulador.md << 'DOCEOF'
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
DOCEOF

echo "✅ docs/06_simulador.md gerado"

# ===========================================
# docs/07_opcodes.md
# ===========================================
cat > docs/07_opcodes.md << 'DOCEOF'
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
DOCEOF

echo "✅ docs/07_opcodes.md gerado"

# ===========================================
# docs/08_exemplos.md
# ===========================================
cat > docs/08_exemplos.md << 'DOCEOF'
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
DOCEOF

echo "✅ docs/08_exemplos.md gerado"

# ===========================================
# FINALIZAÇÃO
# ===========================================
echo ""
echo "=========================================="
echo "📚 DOCUMENTAÇÃO GERADA COM SUCESSO!"
echo "=========================================="
echo ""
echo "Arquivos criados:"
echo "  ✅ README.md                    (documentação principal)"
echo "  ✅ docs/01_linguagem.md          (especificação da linguagem)"
echo "  ✅ docs/02_lexico.md             (analisador léxico)"
echo "  ✅ docs/03_sintatico.md          (analisador sintático)"
echo "  ✅ docs/04_semantico.md          (analisador semântico)"
echo "  ✅ docs/05_gerador.md            (gerador de código)"
echo "  ✅ docs/06_simulador.md          (simulador CPU)"
echo "  ✅ docs/07_opcodes.md            (referência de opcodes)"
echo "  ✅ docs/08_exemplos.md           (exemplos comentados)"
echo ""
echo "Execute: bash docs.sh"
