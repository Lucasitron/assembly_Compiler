class Simbolo:
    def __init__(self, nome, tipo, linha, coluna, valor=None):
        self.nome = nome
        self.tipo = tipo  # 'label', 'constante'
        self.linha = linha
        self.coluna = coluna
        self.valor = valor
        self.referencias = []  # linhas onde é referenciado
    
    def adicionar_referencia(self, linha, coluna):
        self.referencias.append((linha, coluna))
    
    def __str__(self):
        return f"Simbolo({self.tipo}: {self.nome}, linha={self.linha})"

class TabelaSimbolos:
    def __init__(self):
        self.simbolos = {}
    
    def adicionar(self, nome, tipo, linha, coluna, valor=None):
        if nome in self.simbolos:
            return False  # Símbolo já existe
        self.simbolos[nome] = Simbolo(nome, tipo, linha, coluna, valor)
        return True
    
    def obter(self, nome):
        return self.simbolos.get(nome)
    
    def existe(self, nome):
        return nome in self.simbolos
    
    def adicionar_referencia(self, nome, linha, coluna):
        if nome in self.simbolos:
            self.simbolos[nome].adicionar_referencia(linha, coluna)
            return True
        return False
    
    def verificar_labels_nao_referenciados(self):
        nao_referenciados = []
        for nome, simbolo in self.simbolos.items():
            if simbolo.tipo == 'label' and len(simbolo.referencias) == 0:
                nao_referenciados.append(simbolo)
        return nao_referenciados
    
    def verificar_labels_nao_definidos(self):
        # Será preenchido durante a análise
        pass
    
    def __str__(self):
        result = "Tabela de Símbolos:\n"
        result += "-" * 50 + "\n"
        for nome, simbolo in self.simbolos.items():
            result += f"{simbolo}\n"
            if simbolo.referencias:
                result += f"  Referenciado em: {simbolo.referencias}\n"
        return result
