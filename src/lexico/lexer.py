from src.lexico.token import Token, TokenType

PALAVRAS_RESERVADAS = {
    'mov': TokenType.MOV,
    'add': TokenType.ADD,
    'sub': TokenType.SUB,
    'mul': TokenType.MUL,
    'div': TokenType.DIV,
    'cmp': TokenType.CMP,
    'jmp': TokenType.JMP,
    'je': TokenType.JE,
    'jne': TokenType.JNE,
    'jg': TokenType.JG,
    'jl': TokenType.JL,
    'jle': TokenType.JLE,      # ADICIONADO
    'jge': TokenType.JGE,      # ADICIONADO
    'load': TokenType.LOAD,
    'store': TokenType.STORE,
    'hlt': TokenType.HLT,
}

# O resto do arquivo permanece igual...
class Lexer:
    def __init__(self, codigo_fonte):
        self.codigo = codigo_fonte
        self.pos = 0
        self.linha = 1
        self.coluna = 1
        self.tokens = []
        self.erros = []
    
    def tokenizar(self):
        """Analisa todo o código fonte e retorna a lista de tokens"""
        while self.pos < len(self.codigo):
            char = self.codigo[self.pos]
            
            # Ignorar espaços em branco
            if char in ' \t':
                self.avancar()
            
            # Ignorar quebras de linha
            elif char == '\n':
                self.linha += 1
                self.coluna = 1
                self.avancar()
            
            # Comentários (; até o fim da linha)
            elif char == ';':
                self.ler_comentario()
            
            # Números hexadecimais (0x...)
            elif char == '0' and self.pos + 1 < len(self.codigo) and self.codigo[self.pos + 1] == 'x':
                self.ler_hex()
            
            # Números decimais
            elif char.isdigit():
                self.ler_numero()
            
            # Identificadores e palavras reservadas
            elif char.isalpha() or char == '_':
                self.ler_identificador()
            
            # Símbolos especiais
            else:
                self.ler_simbolo()
        
        # Adicionar token de fim de arquivo
        self.tokens.append(Token(TokenType.EOF, '', self.linha, self.coluna))
        return self.tokens
    
    def avancar(self):
        """Avança para o próximo caractere"""
        self.pos += 1
        self.coluna += 1
    
    def ler_comentario(self):
        """Lê um comentário até o fim da linha"""
        self.avancar()  # Pular o ;
        
        while self.pos < len(self.codigo) and self.codigo[self.pos] != '\n':
            self.avancar()
    
    def ler_hex(self):
        """Lê um número hexadecimal (0x...)"""
        col_inicio = self.coluna
        valor = ''
        
        # Ler '0'
        valor += self.codigo[self.pos]
        self.avancar()
        
        # Ler 'x'
        valor += self.codigo[self.pos]
        self.avancar()
        
        # Ler dígitos hexadecimais
        while self.pos < len(self.codigo) and self.codigo[self.pos].lower() in '0123456789abcdef':
            valor += self.codigo[self.pos]
            self.avancar()
        
        if len(valor) <= 2:  # Só tem '0x'
            self.erros.append(f"Erro léxico na linha {self.linha}, coluna {col_inicio}: Hexadecimal inválido '{valor}'")
            self.tokens.append(Token(TokenType.INVALIDO, valor, self.linha, col_inicio))
        else:
            self.tokens.append(Token(TokenType.HEX, valor, self.linha, col_inicio))
    
    def ler_numero(self):
        """Lê um número decimal"""
        col_inicio = self.coluna
        valor = ''
        
        while self.pos < len(self.codigo) and self.codigo[self.pos].isdigit():
            valor += self.codigo[self.pos]
            self.avancar()
        
        self.tokens.append(Token(TokenType.NUM, valor, self.linha, col_inicio))
    
    def ler_identificador(self):
        """Lê um identificador ou palavra reservada"""
        col_inicio = self.coluna
        valor = ''
        
        while self.pos < len(self.codigo) and (self.codigo[self.pos].isalnum() or self.codigo[self.pos] == '_'):
            valor += self.codigo[self.pos]
            self.avancar()
        
        # Verificar se é registrador (a, b, c, d)
        if valor in ['a', 'b', 'c', 'd'] and len(valor) == 1:
            self.tokens.append(Token(TokenType.REG, valor, self.linha, col_inicio))
        # Verificar se é palavra reservada
        elif valor.lower() in PALAVRAS_RESERVADAS:
            self.tokens.append(Token(PALAVRAS_RESERVADAS[valor.lower()], valor.lower(), self.linha, col_inicio))
        # Senão é um label
        else:
            self.tokens.append(Token(TokenType.ID, valor, self.linha, col_inicio))
    
    def ler_simbolo(self):
        """Lê símbolos especiais"""
        char = self.codigo[self.pos]
        col_inicio = self.coluna
        
        tabela_simbolos = {
            ',': TokenType.VIRGULA,
            ':': TokenType.DOIS_PONTOS,
            ';': TokenType.PONTO_VIRGULA,
            '[': TokenType.ABRE_COL,
            ']': TokenType.FECHA_COL,
        }
        
        if char in tabela_simbolos:
            self.tokens.append(Token(tabela_simbolos[char], char, self.linha, col_inicio))
            self.avancar()
        else:
            # Caractere inválido
            self.erros.append(f"Erro léxico na linha {self.linha}, coluna {col_inicio}: Caractere inválido '{char}'")
            self.tokens.append(Token(TokenType.INVALIDO, char, self.linha, col_inicio))
            self.avancar()