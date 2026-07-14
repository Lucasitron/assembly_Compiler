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

