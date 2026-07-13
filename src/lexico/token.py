from enum import Enum, auto

class TokenType(Enum):
    # Registradores
    REG = auto()        # a, b, c, d
    
    # Valores numéricos
    NUM = auto()        # 10, 25, 100
    HEX = auto()        # 0xFF, 0x1A
    
    # Mnemônicos (instruções)
    MOV = auto()
    ADD = auto()
    SUB = auto()
    MUL = auto()
    DIV = auto()
    CMP = auto()
    JMP = auto()
    JE = auto()
    JNE = auto()
    JG = auto()
    JL = auto()
    LOAD = auto()
    STORE = auto()
    HLT = auto()
    
    # Símbolos
    VIRGULA = auto()    # ,
    DOIS_PONTOS = auto() # :
    PONTO_VIRGULA = auto() # ;
    ABRE_COL = auto()   # [
    FECHA_COL = auto()  # ]
    OP_SOMA = auto()    # +
    OP_SUB = auto()     # -
    OP_MULT = auto()    # *
    OP_DIV = auto()     # /
    
    # Identificadores
    ID = auto()         # labels: loop, fim, main
    
    # Especiais
    EOF = auto()        # Fim do arquivo
    INVALIDO = auto()   # Token inválido

class Token:
    def __init__(self, tipo, valor, linha, coluna):
        self.tipo = tipo
        self.valor = valor
        self.linha = linha
        self.coluna = coluna
    
    def __str__(self):
        return f"Token({self.tipo.name:12} | '{self.valor:8}' | linha={self.linha:2}, col={self.coluna:2})"