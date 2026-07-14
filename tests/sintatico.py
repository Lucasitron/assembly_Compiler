import sys
import os

# Garantir que o diretório raiz do projeto esteja no sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from __init__ import Lexer
from __init__ import Parser


def testar_codigo(codigo, descricao):
    print(f"\n{'='*60}")
    print(f"Teste: {descricao}")
    print(f"{'='*60}")
    print("Código fonte:")
    print(codigo)
    
    # Léxico
    lexer = Lexer(codigo)
    tokens = lexer.tokenizar()
    
    if lexer.erros:
        print("❌ Erros léxicos:")
        for e in lexer.erros:
            print(f"  {e}")
        return False
    
    # Sintático
    parser = Parser(tokens)
    ast = parser.programa()
    
    if parser.erros:
        print("❌ Erros sintáticos:")
        for e in parser.erros:
            print(f"  {e}")
        return False
    
    print("✅ Teste passou!")
    print(f"AST: {ast}")
    return True

def main():
    testes = [
        ("hlt", "Instrução única sem operandos"),
        ("main:\n    hlt", "Label + instrução"),
        ("mov a, 10", "Movimento registrador-número"),
        ("mov a, b", "Movimento registrador-registrador"),
        ("add a, b", "Adição de registradores"),
        ("cmp a, 0xFF", "Comparação com hexadecimal"),
        ("jmp loop", "Jump para label"),
        ("load b, [a]", "Load da memória"),
        ("store [0xFF], a", "Store na memória"),
    ]
    
    for codigo, descricao in testes:
        testar_codigo(codigo, descricao)

if __name__ == "__main__":
    main()