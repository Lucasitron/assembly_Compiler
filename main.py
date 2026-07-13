from src.lexico.lexer import Lexer

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