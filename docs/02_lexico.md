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
