class NoAST:
    """Nó base da árvore sintática abstrata"""
    pass

class Programa(NoAST):
    def __init__(self, linhas):
        self.linhas = linhas
    
    def __str__(self):
        return f"Programa[\n  " + "\n  ".join(str(l) for l in self.linhas) + "\n]"

class LinhaLabel(NoAST):
    def __init__(self, nome, linha, coluna):
        self.nome = nome
        self.linha = linha
        self.coluna = coluna
    
    def __str__(self):
        return f"Label({self.nome})"

class LinhaInstrucao(NoAST):
    def __init__(self, mnemonico, operandos, linha, coluna):
        self.mnemonico = mnemonico
        self.operandos = operandos
        self.linha = linha
        self.coluna = coluna
    
    def __str__(self):
        if self.operandos:
            return f"Instrucao({self.mnemonico}, [{', '.join(str(op) for op in self.operandos)}])"
        return f"Instrucao({self.mnemonico})"

class Operando(NoAST):
    def __init__(self, tipo, valor, linha, coluna):
        self.tipo = tipo  # 'reg', 'num', 'hex', 'id', 'mem'
        self.valor = valor
        self.linha = linha
        self.coluna = coluna
    
    def __str__(self):
        if self.tipo == 'mem':
            return f"Mem[{self.valor}]"
        return f"{self.tipo.capitalize()}({self.valor})"

class OperandoMemoria(Operando):
    def __init__(self, endereco, linha, coluna):
        super().__init__('mem', endereco, linha, coluna)
        self.endereco = endereco
    
    def __str__(self):
        if isinstance(self.endereco, Operando):
            return f"Mem[{self.endereco}]"
        return f"Mem({self.endereco})"