import sys
import os

# Garantir que o diretório raiz do projeto esteja no sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from __init__ import Lexer

def testar_lexer():
    # Programa de teste
    codigo = """
; Programa de exemplo
main:
    mov a, 10
    mov b, 0xFF
loop:
    add a, b
    cmp a, 100
    jl loop
    hlt
"""
    
    print("=== CÓDIGO FONTE ===")
    print(codigo)
    print("=== TOKENS ===")
    
    lexer = Lexer(codigo)
    tokens = lexer.tokenizar()
    
    for token in tokens:
        print(token)

if __name__ == "__main__":
    testar_lexer()