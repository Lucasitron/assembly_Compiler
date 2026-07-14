#!/bin/bash
echo "=========================================="
echo "TESTANDO TODOS OS EXEMPLOS"
echo "=========================================="

for arquivo in exemplos/*.asm; do
    echo ""
    echo "📄 Testando: $arquivo"
    echo "----------------------------------------"
    python main.py "$arquivo" 2>&1 | grep -E "(✅|❌|sucesso|falhou|bytes)"
done

echo ""
echo "=========================================="
echo "SIMULANDO PROGRAMAS"
echo "=========================================="

for arquivo in exemplos/teste.asm exemplos/fatorial.asm exemplos/maior_numero.asm exemplos/teste_completo.asm; do
    echo ""
    echo "🔬 Simulando: $arquivo"
    echo "----------------------------------------"
    python simulador.py "$arquivo" 2>&1 | grep -A 10 "ESTADO DA CPU"
done
