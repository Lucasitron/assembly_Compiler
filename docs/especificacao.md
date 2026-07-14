# Especificação da Linguagem e do Compilador

Este documento descreve a linguagem Assembly didática suportada pelo compilador, os tokens reconhecidos, a gramática, o comportamento das fases do compilador e exemplos de uso.

## 1. Visão Geral da Linguagem

- Registradores: `a`, `b`, `c`, `d`
- Literais numéricos:
  - Decimal: sequência de dígitos, ex: `10`, `100`
  - Hexadecimal: prefixo `0x` seguido de dígitos hex, ex: `0xFF`
- Comentários: linha iniciada por `;` até o fim da linha
- Labels: identificadores seguidos por `:` no início de uma linha (ex: `loop:`)
- Separadores/símbolos: `,` `:` `[` `]` `+` `-` `*` `/`

## 2. Tokens

O lexer produz tokens com tipos definidos em `src/lexico/token.py`. Principais tipos:

- `REG` — registradores (`a`, `b`, `c`, `d`)
- `NUM` — número decimal
- `HEX` — número hexadecimal (`0x...`)
- Mnemônicos: `MOV`, `ADD`, `SUB`, `MUL`, `DIV`, `CMP`, `JMP`, `JE`, `JNE`, `JG`, `JL`, `LOAD`, `STORE`, `HLT`
- Símbolos: `VIRGULA`, `DOIS_PONTOS`, `PONTO_VIRGULA`, `ABRE_COL`, `FECHA_COL`, `OP_SOMA`, `OP_SUB`, `OP_MULT`, `OP_DIV`
- `ID` — identificadores/labels
- `EOF` — fim do arquivo
- `INVALIDO` — token inválido

O funcionamento do lexer está em `src/lexico/lexer.py`. Ele:

- Ignora espaços e tabs
- Conta quebras de linha para manter `linha`/`coluna`
- Lê comentários a partir de `;` até o fim da linha (não gera token)
- Detecta números hexadecimais que começam com `0x`
- Diferencia registradores, palavras reservadas (mnemônicos) e identificadores

## 3. Gramática (resumida)

Em BNF simplificada:

```
programa   ::= { linha }
linha      ::= [label ":"] [instrução] [comentario]
label      ::= IDENT
instrução  ::= mnemônico argumentos
mnemônico  ::= "mov" | "add" | "sub" | "mul" | "div" | "cmp" | "jmp" | "je" | "jne" | "jg" | "jl" | "load" | "store" | "hlt"
argumentos ::= argumento { "," argumento }
argumento  ::= registrador | número | endereço | identificador
registrador ::= "a" | "b" | "c" | "d"
número     ::= NUM | HEX
endereço   ::= "[" expressão "]"
expressão  ::= termo { ("+"|"-"|"*"|"/") termo }
```

Observação: O parser atual implementado em `src/sintatico/parser.py` segue essa estrutura básica e produz uma AST usada nas etapas seguintes.

## 4. Análise Semântica

A fase semântica (`src/semantico/analisador.py`) é responsável por:

- Verificar existência de labels referenciados
- Validar formatos de operandos (ex.: `mov a, 10` aceita registro e número)
- Verificar limites e tipos de valores quando aplicável

Erros semânticos devem ser reportados com linha/coluna.

## 5. Geração de Código

A etapa de geração (`src/gerador/gerador_codigo.py`) traduz a AST para um formato de máquina/bytecode próprio do projeto. O formato exato está documentado no módulo de gerador.

## 6. Exemplos

Exemplo simples (`exemplos/teste.asm`):

```
; Programa de exemplo
main:
    mov a, 10
    mov b, 0xFF
loop:
    add a, b
    cmp a, 100
    jl loop
    hlt
```

## 7. Testes

- `tests/lexico.py` — script simples que demonstra o lexer e imprime tokens.

Para adicionar testes automatizados, sugerimos usar `pytest` e criar uma pasta `tests/unit/` com casos unitários para cada componente.

## 8. Como estender

- Adicionar novas instruções: incluir no `TokenType` e em `PALAVRAS_RESERVADAS` (`src/lexico/token.py`) e atualizar o parser e gerador.
- Suportar expressões mais complexas: estender a gramática e o parser em `src/sintatico/parser.py`.

## 9. Referências internas

- Lexer: `src/lexico/lexer.py`
- Tokens: `src/lexico/token.py`
- Parser: `src/sintatico/parser.py`
- Semântico: `src/semantico/analisador.py`
- Gerador: `src/gerador/gerador_codigo.py`

---

Se quiser, posso gerar diagramas (AFD para o lexer, BNF formal, ou um diagrama das fases do compilador) e também preparar um guia de contribuição mais detalhado com padrões de codificação e instruções para rodar testes em CI.
