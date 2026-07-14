import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo

def compilar_e_salvar(codigo, nome_arquivo):
    """Compila código e salva resultado binário"""
    lexer = Lexer(codigo)
    tokens = lexer.tokenizar()
    if lexer.erros:
        return False
    
    parser = Parser(tokens)
    ast = parser.programa()
    if parser.erros:
        return False
    
    semantico = AnalisadorSemantico()
    if not semantico.analisar(ast):
        return False
    
    gerador = GeradorCodigo()
    codigo_bin = gerador.gerar(ast)
    if gerador.erros:
        return False
    
    # Salvar binário
    caminho_bin = f"tests/saidas/{nome_arquivo}.bin"
    gerador.gerar_arquivo_binario(caminho_bin)
    
    # Salvar hexdump
    caminho_hex = f"tests/saidas/{nome_arquivo}.hex"
    gerador.gerar_arquivo_hex(caminho_hex)
    
    return True

def main():
    print("=" * 60)
    print("TESTES DE INTEGRAÇÃO - GERAÇÃO DE EXECUTÁVEIS")
    print("=" * 60)
    
    testes = {
        "01_hlt": "hlt",
        "02_mov_simples": "mov a, 42\nhlt",
        "03_mov_regs": "mov a, 10\nmov b, a\nhlt",
        "04_add": "mov a, 10\nmov b, 20\nadd a, b\nhlt",
        "05_loop": "main:\n    mov a, 5\nloop:\n    sub a, 1\n    cmp a, 0\n    jne loop\n    hlt",
        "06_condicional": "main:\n    mov a, 10\n    mov b, 5\n    cmp a, b\n    jg maior\n    mov c, 0\n    jmp fim\nmaior:\n    mov c, 1\nfim:\n    hlt",
        "07_memoria": "mov a, 0xFF\nstore [0x10], a\nload b, [0x10]\nhlt",
        "08_saltos": "inicio:\n    jmp meio\n    hlt\nmeio:\n    jmp fim\n    hlt\nfim:\n    hlt",
    }
    
    for nome, codigo in testes.items():
        resultado = compilar_e_salvar(codigo, nome)
        status = "✅" if resultado else "❌"
        print(f"  {status} {nome}")
    
    print(f"\n📄 Arquivos gerados em: tests/saidas/")
    print("  Arquivos .bin (binário) e .hex (hexdump)")

if __name__ == "__main__":
    main()
