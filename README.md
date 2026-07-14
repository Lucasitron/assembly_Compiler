# Compilador Assembly Didático

Compilador completo para uma linguagem Assembly Didática, desenvolvido para fins educacionais.

## 📋 Características

- **Linguagem fonte**: Assembly Didático com suporte a:
  - 4 registradores: a, b, c, d
  - Instruções aritméticas: add, sub, mul, div
  - Movimentação: mov
  - Comparação: cmp
  - Saltos condicionais: je, jne, jg, jl, jle, jge
  - Salto incondicional: jmp
  - Acesso à memória: load, store
  - Parada: hlt
  - Labels e comentários (;)

- **Fases do compilador**:
  1. Análise Léxica (tokenização)
  2. Análise Sintática (parser + AST)
  3. Análise Semântica (verificação de tipos)
  4. Geração de Código de Máquina

## 🚀 Uso

### Compilar um programa
```bash
python main.py exemplos/teste.asm

