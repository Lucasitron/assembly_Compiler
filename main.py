import sys
import os

# Adiciona o diretório raiz ao path para permitir imports relativos
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser

def compilar(arquivo_entrada, verbose=False):
    """Compila um arquivo assembly didático"""
    try:
        with open(arquivo_entrada, 'r') as f:
            codigo_fonte = f.read()
    except FileNotFoundError:
        print(f"Erro: Arquivo '{arquivo_entrada}' não encontrado.")
        return None
    
    print("=" * 60)
    print("COMPILADOR ASSEMBLY DIDÁTICO")
    print("=" * 60)
    
    # Fase 1: Análise Léxica
    print("\n[1] ANÁLISE LÉXICA")
    print("-" * 40)
    lexer = Lexer(codigo_fonte)
    tokens = lexer.tokenizar()
    
    if lexer.erros:
        print("ERROS LÉXICOS ENCONTRADOS:")
        for erro in lexer.erros:
            print(f"  ❌ {erro}")
        return None
    else:
        print("✅ Análise léxica concluída sem erros")
    
    if verbose:
        print("\nTokens encontrados:")
        for token in tokens:
            if token.tipo.name != 'EOF':
                print(f"  {token}")
    
    # Fase 2: Análise Sintática
    print("\n[2] ANÁLISE SINTÁTICA")
    print("-" * 40)
    parser = Parser(tokens, verbose=verbose)
    ast = parser.programa()
    
    if parser.tem_erros():
        print("ERROS SINTÁTICOS ENCONTRADOS:")
        for erro in parser.erros:
            print(f"  ❌ {erro}")
        return None
    else:
        print("✅ Análise sintática concluída sem erros")
    
    if verbose:
        print("\nÁrvore Sintática:")
        print(ast)
    
    print("\n✅ Compilação concluída com sucesso!")
    return ast

def main():
    if len(sys.argv) < 2:
        print("Uso: python main.py <arquivo.asm> [-v]")
        print("  -v: modo verbose (mostra detalhes)")
        sys.exit(1)
    
    arquivo = sys.argv[1]
    verbose = '-v' in sys.argv
    
    ast = compilar(arquivo, verbose)
    
    if ast is None:
        sys.exit(1)

if __name__ == "__main__":
    main()