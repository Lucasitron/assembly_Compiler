from src.lexico.token import TokenType
from src.sintatico.ast import *

class Parser:
    def __init__(self, tokens, verbose=False):
        # Filtra tokens de comentário (PONTO_VIRGULA)
        self.tokens = [t for t in tokens if t.tipo != TokenType.PONTO_VIRGULA]
        self.pos = 0
        self.token_atual = self.tokens[0] if self.tokens else None
        self.erros = []
        self.verbose = verbose
    
    def log(self, mensagem):
        if self.verbose:
            print(f"[Parser] {mensagem}")
    
    def avancar(self):
        """Consome o token atual e avança para o próximo"""
        if self.pos < len(self.tokens) - 1:
            self.pos += 1
            self.token_atual = self.tokens[self.pos]
        else:
            self.token_atual = None
    
    def erro(self, mensagem):
        """Registra um erro de sintaxe"""
        if self.token_atual:
            linha = self.token_atual.linha
            coluna = self.token_atual.coluna
            self.erros.append(f"Erro sintático na linha {linha}, coluna {coluna}: {mensagem}")
        else:
            self.erros.append(f"Erro sintático: {mensagem}")
    
    def verificar(self, tipo_esperado):
        """Verifica se o token atual é do tipo esperado e avança"""
        if self.token_atual and self.token_atual.tipo == tipo_esperado:
            token = self.token_atual
            self.avancar()
            return token
        else:
            if self.token_atual:
                self.erro(f"Esperado {tipo_esperado.name}, encontrado {self.token_atual.tipo.name} ('{self.token_atual.valor}')")
            else:
                self.erro(f"Esperado {tipo_esperado.name}, mas não há mais tokens")
            return None
    
    def programa(self):
        """<programa> → <linhas>"""
        self.log("Iniciando análise do programa")
        linhas = self.linhas()
        
        # Verificar se consumiu todos os tokens (exceto EOF)
        if self.token_atual and self.token_atual.tipo != TokenType.EOF:
            self.erro(f"Tokens inesperados após o fim do programa: {self.token_atual.tipo.name}")
        
        return Programa(linhas)
    
    def linhas(self):
        """<linhas> → <linha> <linhas> | ε"""
        linhas = []
        
        while self.token_atual and self.token_atual.tipo != TokenType.EOF:
            linha = self.linha()
            if linha:
                linhas.append(linha)
            else:
                # Se não conseguiu processar a linha, tenta avançar para recuperação de erro
                if self.token_atual and self.token_atual.tipo != TokenType.EOF:
                    # Tenta sincronizar: avança até encontrar algo que pareça início de linha
                    self.sincronizar()
        
        return linhas
    
    def sincronizar(self):
        """Tenta recuperar de erro avançando até um token seguro"""
        tokens_seguros = [
            TokenType.ID,  # possível label
            TokenType.MOV, TokenType.ADD, TokenType.SUB, TokenType.MUL, TokenType.DIV,
            TokenType.CMP, TokenType.JMP, TokenType.JE, TokenType.JNE, TokenType.JG,
            TokenType.JL, TokenType.JLE, TokenType.JGE, TokenType.LOAD, TokenType.STORE, TokenType.HLT
        ]
        
        while self.token_atual and self.token_atual.tipo != TokenType.EOF:
            if self.token_atual.tipo in tokens_seguros:
                break
            self.avancar()
    
    def linha(self):
        """<linha> → <label> | <instrucao>"""
        if not self.token_atual or self.token_atual.tipo == TokenType.EOF:
            return None
        
        # Label: ID seguido de DOIS_PONTOS
        if self.token_atual.tipo == TokenType.ID:
            # Verifica se o próximo token é DOIS_PONTOS
            if self.pos + 1 < len(self.tokens) and self.tokens[self.pos + 1].tipo == TokenType.DOIS_PONTOS:
                return self.label()
            else:
                # ID sozinho não é válido como instrução
                self.erro(f"Identificador '{self.token_atual.valor}' inesperado. Esperava-se ':' para label ou uma instrução.")
                return None
        
        # Instrução: MNEMONIC ...
        elif self.token_atual.tipo in [
            TokenType.MOV, TokenType.ADD, TokenType.SUB, TokenType.MUL, TokenType.DIV,
            TokenType.CMP, TokenType.JMP, TokenType.JE, TokenType.JNE, TokenType.JG,
            TokenType.JL, TokenType.JLE, TokenType.JGE, TokenType.LOAD, TokenType.STORE, TokenType.HLT
        ]:
            return self.instrucao()
        
        # Token inesperado
        else:
            self.erro(f"Token inesperado: {self.token_atual.tipo.name} ('{self.token_atual.valor}')")
            return None
    
    def label(self):
        """<label> → ID DOIS_PONTOS"""
        self.log(f"Processando label: {self.token_atual.valor}")
        
        id_token = self.verificar(TokenType.ID)
        if not id_token:
            return None
        
        if not self.verificar(TokenType.DOIS_PONTOS):
            return None
        
        return LinhaLabel(id_token.valor, id_token.linha, id_token.coluna)
    
    def instrucao(self):
        """<instrucao> → MNEMONIC <operandos>"""
        mnemonico_token = self.token_atual
        mnemonico = mnemonico_token.valor
        linha = mnemonico_token.linha
        coluna = mnemonico_token.coluna
        self.avancar()
        
        self.log(f"Processando instrução: {mnemonico}")
        
        operandos = self.operandos(mnemonico)
        
        return LinhaInstrucao(mnemonico, operandos, linha, coluna)
    
    def operandos(self, mnemonico):
        """Determina os operandos baseado no mnemônico"""
        # Instruções sem operandos
        if mnemonico == 'hlt':
            return self.operando_zero()
        
        # Instruções com 1 operando (jumps)
        elif mnemonico in ['jmp', 'je', 'jne', 'jg', 'jl', 'jle', 'jge']:
            return self.operando_um()
        
        # Instruções com 2 operandos
        elif mnemonico in ['mov', 'add', 'sub', 'mul', 'div', 'cmp', 'load']:
            return self.operando_dois(mnemonico)
        
        # store tem formato especial: store [mem], reg
        elif mnemonico == 'store':
            return self.operando_store()
        
        return []
    
    def operando_zero(self):
        """<zero_op> → ε"""
        return []
    
    def operando_um(self):
        """<um_op> → ID"""
        if self.token_atual and self.token_atual.tipo == TokenType.ID:
            id_token = self.token_atual
            self.avancar()
            return [Operando('id', id_token.valor, id_token.linha, id_token.coluna)]
        else:
            if self.token_atual:
                self.erro(f"Esperado identificador (label), encontrado {self.token_atual.tipo.name}")
            return []
    
    def operando_dois(self, mnemonico):
        """Processa instruções com dois operandos (mov, add, sub, mul, div, cmp, load)"""
        operandos = []
        
        # load tem formato especial: load reg, [mem]
        if mnemonico == 'load':
            # Primeiro operando: registrador
            op1 = self.operando_simples()
            if not op1:
                return operandos
            operandos.append(op1)
            
            # Vírgula
            if not self.verificar(TokenType.VIRGULA):
                return operandos
            
            # Segundo operando: [mem]
            op2 = self.operando_memoria()
            if op2:
                operandos.append(op2)
        else:
            # mov, add, sub, mul, div, cmp: operando, operando
            op1 = self.operando_simples()
            if not op1:
                return operandos
            operandos.append(op1)
            
            # Vírgula
            if not self.verificar(TokenType.VIRGULA):
                return operandos
            
            op2 = self.operando_simples()
            if op2:
                operandos.append(op2)
        
        return operandos
    
    def operando_store(self):
        """Processa store [mem], reg"""
        operandos = []
        
        # Primeiro operando: [mem]
        op1 = self.operando_memoria()
        if not op1:
            return operandos
        operandos.append(op1)
        
        # Vírgula
        if not self.verificar(TokenType.VIRGULA):
            return operandos
        
        # Segundo operando: registrador
        op2 = self.operando_simples()
        if op2:
            operandos.append(op2)
        
        return operandos
    
    def operando_simples(self):
        """<valor> → REG | NUM | HEX | ID"""
        if not self.token_atual:
            return None
        
        token = self.token_atual
        
        if token.tipo == TokenType.REG:
            self.avancar()
            return Operando('reg', token.valor, token.linha, token.coluna)
        
        elif token.tipo == TokenType.NUM:
            self.avancar()
            return Operando('num', token.valor, token.linha, token.coluna)
        
        elif token.tipo == TokenType.HEX:
            self.avancar()
            return Operando('hex', token.valor, token.linha, token.coluna)
        
        elif token.tipo == TokenType.ID:
            self.avancar()
            return Operando('id', token.valor, token.linha, token.coluna)
        
        else:
            self.erro(f"Esperado operando (REG, NUM, HEX, ID), encontrado {token.tipo.name}")
            return None
    
    def operando_memoria(self):
        """<mem> → ABRE_COL <valor> FECHA_COL"""
        if not self.verificar(TokenType.ABRE_COL):
            return None
        
        # Pega o valor dentro dos colchetes
        endereco = self.operando_simples()
        
        if not self.verificar(TokenType.FECHA_COL):
            return None
        
        if endereco:
            return OperandoMemoria(endereco, endereco.linha, endereco.coluna)
        return None
    
    def tem_erros(self):
        """Retorna True se houver erros de sintaxe"""
        return len(self.erros) > 0