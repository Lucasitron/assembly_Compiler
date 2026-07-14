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
