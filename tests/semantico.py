import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico

def testar_semantica(codigo, descricao, deve_passar=True, erro_esperado_na_sintaxe=False):
    print(f"\n{'='*60}")
    print(f"Teste: {descricao}")
    print(f"{'='*60}")
    print("Código:")
    print(codigo)
    
    # Léxico
    lexer = Lexer(codigo)
    tokens = lexer.tokenizar()
    
    if lexer.erros:
        print("❌ Erros léxicos!")
        return False
    
    # Sintático
    parser = Parser(tokens)
    ast = parser.programa()
    
    if parser.erros:
        if erro_esperado_na_sintaxe:
            print("✅ Teste passou (erro sintático detectado como esperado)!")
            return True
        else:
            print("❌ Erros sintáticos inesperados!")
            for e in parser.erros:
                print(f"  {e}")
            return False
    
    # Semântico
    semantico = AnalisadorSemantico()
    resultado = semantico.analisar(ast)
    
    if deve_passar and resultado:
        print("✅ Teste passou (como esperado)!")
        semantico.mostrar_resultados()
        return True
    elif not deve_passar and not resultado:
        print("✅ Teste passou (erro semântico detectado como esperado)!")
        semantico.mostrar_resultados()
        return True
    elif deve_passar and not resultado:
        print("❌ Teste falhou (esperava sucesso)!")
        semantico.mostrar_resultados()
        return False
    else:
        print("❌ Teste falhou (esperava erro semântico)!")
        semantico.mostrar_resultados()
        return False

def main():
    print("=" * 60)
    print("TESTES DO ANALISADOR SEMÂNTICO")
    print("=" * 60)
    
    testes = [
        # Testes que devem passar na semântica
        ("hlt", "Programa mínimo (só HLT)", True),
        ("main:\n    hlt", "Label + HLT", True),
        ("mov a, 10\n    hlt", "MOV registrador-número", True),
        ("mov a, b\n    hlt", "MOV registrador-registrador", True),
        ("add a, b\n    hlt", "ADD registradores", True),
        ("cmp a, 10\n    hlt", "CMP registrador-número", True),
        ("main:\n    jmp main\n    hlt", "JMP para label existente", True),
        ("load a, [b]\n    hlt", "LOAD da memória", True),
        ("store [0xFF], a\n    hlt", "STORE na memória", True),
        ("main:\n    mov a, 10\nfim:\n    hlt", "Programa com múltiplos labels", True),
        
        # Testes que devem falhar na semântica
        ("mov 10, a\n    hlt", "MOV com destino inválido", False),
        ("add a, 10\n    hlt", "ADD com número", False),
        ("jmp label_inexistente\n    hlt", "JMP para label não definido", False),
        ("main:\nmain:\n    hlt", "Label duplicado", False),
        ("load 10, [a]\n    hlt", "LOAD com destino inválido", False),
        ("store [0xFF], 10\n    hlt", "STORE com fonte inválida", False),
        
        # Teste que deve falhar na sintaxe (não chega na semântica)
        ("store a, [0xFF]\n    hlt", "STORE com operandos invertidos (erro sintático)", False, True),
    ]
    
    resultados = []
    for teste in testes:
        if len(teste) == 4:
            codigo, descricao, deve_passar, erro_sintaxe = teste
        else:
            codigo, descricao, deve_passar = teste
            erro_sintaxe = False
        
        resultado = testar_semantica(codigo, descricao, deve_passar, erro_sintaxe)
        resultados.append((descricao, resultado))
    
    print("\n" + "=" * 60)
    print("RESUMO DOS TESTES")
    print("=" * 60)
    for descricao, resultado in resultados:
        status = "✅" if resultado else "❌"
        print(f"{status} {descricao}")
    
    total = len(resultados)
    sucessos = sum(1 for _, r in resultados if r)
    print(f"\nTotal: {sucessos}/{total} testes passaram")
    
    if sucessos == total:
        print("\n🎉 Todos os testes passaram!")
    else:
        print(f"\n⚠️  {total - sucessos} teste(s) falharam")

if __name__ == "__main__":
    main()
