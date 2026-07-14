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
