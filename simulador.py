import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo
from src.gerador.simulador import CPU

def compilar_e_simular(arquivo_asm, debug=False):
    """Compila e executa um programa assembly no simulador"""
    try:
        with open(arquivo_asm, 'r') as f:
            codigo_fonte = f.read()
    except FileNotFoundError:
        print(f"Erro: Arquivo '{arquivo_asm}' não encontrado.")
        return
    
    print("=" * 60)
    print("COMPILADOR + SIMULADOR ASSEMBLY DIDÁTICO")
    print("=" * 60)
    
    # Compilar
    lexer = Lexer(codigo_fonte)
    tokens = lexer.tokenizar()
    if lexer.erros:
        print("Erros léxicos!"); return
    
    parser = Parser(tokens)
    ast = parser.programa()
    if parser.erros:
        print("Erros sintáticos!"); return
    
    semantico = AnalisadorSemantico()
    if not semantico.analisar(ast):
        print("Erros semânticos!"); return
    
    gerador = GeradorCodigo()
    codigo = gerador.gerar(ast)
    if gerador.erros:
        print("Erros na geração!"); return
    
    print(f"✅ Compilado: {len(codigo)} bytes gerados")
    
    # Simular
    print("\n" + "=" * 60)
    print("EXECUTANDO NO SIMULADOR")
    print("=" * 60)
    
    cpu = CPU()
    cpu.carregar_programa(codigo)
    
    instrucoes = cpu.executar(debug=debug)
    
    print(f"\n✅ Execução concluída: {instrucoes} instruções executadas")
    cpu.mostrar_estado()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python simulador.py <arquivo.asm> [-d]")
        print("  -d: modo debug (mostra cada instrução)")
        sys.exit(1)
    
    arquivo = sys.argv[1]
    debug = '-d' in sys.argv
    
    compilar_e_simular(arquivo, debug)
