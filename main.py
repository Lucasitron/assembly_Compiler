import sys
import os
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo

def compilar(arquivo_entrada, verbose=False, saida_bin=None, saida_hex=None):
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
    print(f"Arquivo: {arquivo_entrada}")
    print(f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Fase 1: Análise Léxica
    print("\n[1/4] ANÁLISE LÉXICA")
    print("-" * 40)
    lexer = Lexer(codigo_fonte)
    tokens = lexer.tokenizar()
    
    if lexer.erros:
        print("❌ ERROS LÉXICOS ENCONTRADOS:")
        for erro in lexer.erros:
            print(f"  🚫 {erro}")
        return None
    else:
        print(f"✅ Análise léxica concluída - {len(tokens)-1} tokens encontrados")
    
    if verbose:
        print("\nTokens:")
        for token in tokens:
            if token.tipo.name != 'EOF':
                print(f"  {token}")
    
    # Fase 2: Análise Sintática
    print("\n[2/4] ANÁLISE SINTÁTICA")
    print("-" * 40)
    parser = Parser(tokens, verbose=verbose)
    ast = parser.programa()
    
    if parser.tem_erros():
        print("❌ ERROS SINTÁTICOS ENCONTRADOS:")
        for erro in parser.erros:
            print(f"  🚫 {erro}")
        return None
    else:
        print("✅ Análise sintática concluída - AST gerada com sucesso")
    
    if verbose:
        print("\nÁrvore Sintática:")
        print(ast)
    
    # Fase 3: Análise Semântica
    print("\n[3/4] ANÁLISE SEMÂNTICA")
    print("-" * 40)
    semantico = AnalisadorSemantico(verbose=verbose)
    
    if not semantico.analisar(ast):
        print("❌ ERROS SEMÂNTICOS ENCONTRADOS:")
        semantico.mostrar_resultados()
        return None
    else:
        print("✅ Análise semântica concluída - Sem erros")
    
    if verbose:
        semantico.mostrar_resultados()
    
    # Fase 4: Geração de Código
    print("\n[4/4] GERAÇÃO DE CÓDIGO DE MÁQUINA")
    print("-" * 40)
    gerador = GeradorCodigo(verbose=verbose)
    codigo = gerador.gerar(ast)
    
    if gerador.tem_erros():
        print("❌ ERROS NA GERAÇÃO DE CÓDIGO:")
        gerador.mostrar_resultados()
        return None
    
    print(f"✅ Código gerado com sucesso - {len(codigo)} bytes")
    
    # Mostrar resultados
    gerador.mostrar_resultados()
    
    # Salvar arquivos de saída
    nome_base = os.path.splitext(arquivo_entrada)[0]
    
    if saida_bin is None:
        saida_bin = f"{nome_base}.bin"
    if saida_hex is None:
        saida_hex = f"{nome_base}.hex"
    
    if gerador.gerar_arquivo_binario(saida_bin):
        print(f"\n💾 Código binário salvo em: {saida_bin}")
    
    if gerador.gerar_arquivo_hex(saida_hex):
        print(f"💾 Hexdump salvo em: {saida_hex}")
    
    print("\n" + "=" * 60)
    print("✅ COMPILAÇÃO CONCLUÍDA COM SUCESSO!")
    print("=" * 60)
    
    return codigo

def main():
    if len(sys.argv) < 2:
        print("=" * 60)
        print("COMPILADOR ASSEMBLY DIDÁTICO")
        print("=" * 60)
        print("\nUso: python main.py <arquivo.asm> [opções]")
        print("\nOpções:")
        print("  -v, --verbose    Modo detalhado")
        print("  -o <arquivo>     Arquivo de saída binário")
        print("  --hex <arquivo>  Arquivo de saída hexadecimal")
        print("\nExemplos:")
        print("  python main.py exemplos/teste.asm")
        print("  python main.py exemplos/teste.asm -v")
        print("  python main.py exemplos/teste.asm -o saida.bin --hex saida.hex")
        sys.exit(1)
    
    arquivo = sys.argv[1]
    verbose = '-v' in sys.argv or '--verbose' in sys.argv
    
    # Processar opções de saída
    saida_bin = None
    saida_hex = None
    
    if '-o' in sys.argv:
        idx = sys.argv.index('-o')
        if idx + 1 < len(sys.argv):
            saida_bin = sys.argv[idx + 1]
    
    if '--hex' in sys.argv:
        idx = sys.argv.index('--hex')
        if idx + 1 < len(sys.argv):
            saida_hex = sys.argv[idx + 1]
    
    codigo = compilar(arquivo, verbose, saida_bin, saida_hex)
    
    if codigo is None:
        print("\n❌ Compilação falhou!")
        sys.exit(1)

if __name__ == "__main__":
    main()
