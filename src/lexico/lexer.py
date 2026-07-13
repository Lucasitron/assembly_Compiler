class Lexer:
    def __init__(self, codigo_fonte):
        self.codigo = codigo_fonte
        self.pos = 0
        self.linha = 1
        self.coluna = 1
        self.tokens = []
    
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
            elif char == '0' and self.peek() == 'x':
                self.ler_hex()
            
            # Números decimais
            elif char.isdigit():
                self.ler_numero()
            
            # Identificadores e palavras reservadas
            elif char.isalpha():
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
    
    def peek(self):
        """Retorna o próximo caractere sem avançar"""
        if self.pos + 1 < len(self.codigo):
            return self.codigo[self.pos + 1]
        return None
    
    def ler_comentario(self):
        """Lê um comentário até o fim da linha"""
        # Já estamos no ';'
        self.avancar()  # Pular o ;
        
        while self.pos < len(self.codigo) and self.codigo[self.pos] != '\n':
            self.avancar()
        # Não criamos token para comentários
        
    def ler_hex(self):
        """Lê um número hexadecimal (0x...)"""
        col_inicio = self.coluna
        valor = ''
        
        # Ler '0x'
        valor += self.codigo[self.pos]  # 0
        self.avancar()
        valor += self.codigo[self.pos]  # x
        self.avancar()
        
        # Ler dígitos hexadecimais
        while self.pos < len(self.codigo) and self.codigo[self.pos] in '0123456789abcdefABCDEF':
            valor += self.codigo[self.pos]
            self.avancar()
        
        if len(valor) <= 2:  # Só tem '0x'
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
        
        while self.pos < len(self.codigo) and self.codigo[self.pos].isalnum():
            valor += self.codigo[self.pos]
            self.avancar()
        
        # Verificar se é registrador (a, b, c, d)
        if valor in 'abcd' and len(valor) == 1:
            self.tokens.append(Token(TokenType.REG, valor, self.linha, col_inicio))
        # Verificar se é palavra reservada
        elif valor in PALAVRAS_RESERVADAS:
            self.tokens.append(Token(PALAVRAS_RESERVADAS[valor], valor, self.linha, col_inicio))
        # Senão é um label
        else:
            self.tokens.append(Token(TokenType.ID, valor, self.linha, col_inicio))
    
    def ler_simbolo(self):
        """Lê símbolos especiais"""
        char = self.codigo[self.pos]
        
        tabela_simbolos = {
            ',': TokenType.VIRGULA,
            ':': TokenType.DOIS_PONTOS,
            ';': TokenType.PONTO_VIRGULA,
            '[': TokenType.ABRE_COL,
            ']': TokenType.FECHA_COL,
            '+': TokenType.OP_SOMA,
            '-': TokenType.OP_SUB,
            '*': TokenType.OP_MULT,
            '/': TokenType.OP_DIV,
        }
        
        if char in tabela_simbolos:
            self.tokens.append(Token(tabela_simbolos[char], char, self.linha, self.coluna))
            self.avancar()
        else:
            # Caractere inválido
            self.tokens.append(Token(TokenType.INVALIDO, char, self.linha, self.coluna))
            self.avancar()