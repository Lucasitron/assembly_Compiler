from src.sintatico.ast import *
from src.semantico.tabela_simbolos import TabelaSimbolos

class AnalisadorSemantico:
    def __init__(self, verbose=False):
        self.tabela = TabelaSimbolos()
        self.erros = []
        self.avisos = []
        self.verbose = verbose
        self.registradores_validos = {'a', 'b', 'c', 'd'}
        self.contador_instrucoes = 0
    
    def log(self, mensagem):
        if self.verbose:
            print(f"[Semântico] {mensagem}")
    
    def erro(self, mensagem, linha, coluna):
        self.erros.append(f"Erro semântico na linha {linha}, coluna {coluna}: {mensagem}")
    
    def aviso(self, mensagem, linha, coluna):
        self.avisos.append(f"Aviso na linha {linha}, coluna {coluna}: {mensagem}")
    
    def analisar(self, ast):
        """Analisa a árvore sintática semanticamente"""
        self.log("Iniciando análise semântica")
        
        if not isinstance(ast, Programa):
            self.erro("AST inválida: esperado Programa", 0, 0)
            return False
        
        # Primeira passada: coletar todos os labels
        self._coletar_labels(ast)
        
        # Segunda passada: analisar instruções e verificar referências
        self._analisar_instrucoes(ast)
        
        # Verificações finais
        self._verificacoes_finais()
        
        return not self.tem_erros()
    
    def _coletar_labels(self, programa):
        """Primeira passada: registra todos os labels na tabela de símbolos"""
        self.log("Coletando labels...")
        
        for linha in programa.linhas:
            if isinstance(linha, LinhaLabel):
                if not self.tabela.adicionar(linha.nome, 'label', linha.linha, linha.coluna):
                    self.erro(f"Label '{linha.nome}' já definido anteriormente", linha.linha, linha.coluna)
    
    def _analisar_instrucoes(self, programa):
        """Segunda passada: analisa semanticamente cada instrução"""
        self.log("Analisando instruções...")
        
        label_atual = None
        linhas = programa.linhas
        
        for i, linha in enumerate(linhas):
            if isinstance(linha, LinhaLabel):
                label_atual = linha.nome
            
            elif isinstance(linha, LinhaInstrucao):
                self.contador_instrucoes += 1
                self._analisar_instrucao(linha, label_atual, i, linhas)
    
    def _analisar_instrucao(self, instrucao, label_atual, indice, todas_linhas):
        """Analisa semanticamente uma instrução específica"""
        mnem = instrucao.mnemonico
        ops = instrucao.operandos
        linha = instrucao.linha
        coluna = instrucao.coluna
        
        # Verificar instruções por tipo
        if mnem == 'hlt':
            self._verificar_hlt(instrucao, indice, todas_linhas)
        
        elif mnem in ['mov', 'cmp']:
            self._verificar_mov_cmp(instrucao)
        
        elif mnem in ['add', 'sub', 'mul', 'div']:
            self._verificar_aritmetica(instrucao)
        
        elif mnem in ['jmp', 'je', 'jne', 'jg', 'jl', 'jle', 'jge']:
            self._verificar_jump(instrucao, indice, todas_linhas)
        
        elif mnem == 'load':
            self._verificar_load(instrucao)
        
        elif mnem == 'store':
            self._verificar_store(instrucao)
    
    def _verificar_hlt(self, instrucao, indice, todas_linhas):
        """Verifica se hlt é a última instrução"""
        # Verificar se é a primeira e única instrução
        if self.contador_instrucoes == 1 and indice == len(todas_linhas) - 1:
            self.aviso("Programa contém apenas HLT", instrucao.linha, instrucao.coluna)
        
        # Verificar se há instruções após hlt
        for i in range(indice + 1, len(todas_linhas)):
            if isinstance(todas_linhas[i], LinhaInstrucao):
                self.aviso("Instruções após HLT nunca serão executadas", 
                          todas_linhas[i].linha, todas_linhas[i].coluna)
                break
    
    def _verificar_mov_cmp(self, instrucao):
        """mov reg, valor / cmp reg, valor"""
        ops = instrucao.operandos
        linha = instrucao.linha
        coluna = instrucao.coluna
        
        if len(ops) != 2:
            self.erro(f"Instrução {instrucao.mnemonico} requer 2 operandos", linha, coluna)
            return
        
        # Primeiro operando deve ser registrador
        if ops[0].tipo != 'reg':
            self.erro(f"Primeiro operando de {instrucao.mnemonico} deve ser registrador, encontrado {ops[0].tipo}", 
                     ops[0].linha, ops[0].coluna)
        
        # Segundo operando pode ser reg, num, hex
        if ops[1].tipo not in ['reg', 'num', 'hex']:
            self.erro(f"Segundo operando de {instrucao.mnemonico} deve ser registrador ou número, encontrado {ops[1].tipo}", 
                     ops[1].linha, ops[1].coluna)
    
    def _verificar_aritmetica(self, instrucao):
        """add/sub/mul/div reg, reg"""
        ops = instrucao.operandos
        linha = instrucao.linha
        coluna = instrucao.coluna
        
        if len(ops) != 2:
            self.erro(f"Instrução {instrucao.mnemonico} requer 2 operandos", linha, coluna)
            return
        
        # Ambos devem ser registradores
        for i, op in enumerate(ops):
            if op.tipo != 'reg':
                self.erro(f"Operando {i+1} de {instrucao.mnemonico} deve ser registrador, encontrado {op.tipo}", 
                         op.linha, op.coluna)
    
    def _verificar_jump(self, instrucao, indice, todas_linhas):
        """jmp/je/jne/jg/jl/jle/jge label"""
        ops = instrucao.operandos
        linha = instrucao.linha
        coluna = instrucao.coluna
        
        if len(ops) != 1:
            self.erro(f"Instrução {instrucao.mnemonico} requer 1 operando (label)", linha, coluna)
            return
        
        op = ops[0]
        if op.tipo != 'id':
            self.erro(f"Operando de {instrucao.mnemonico} deve ser um label, encontrado {op.tipo}", 
                     op.linha, op.coluna)
            return
        
        # Registrar referência ao label
        if not self.tabela.existe(op.valor):
            self.erro(f"Label '{op.valor}' não definido", op.linha, op.coluna)
        else:
            self.tabela.adicionar_referencia(op.valor, op.linha, op.coluna)
        
        # Aviso: jump para label logo abaixo (código morto)
        for i in range(indice + 1, len(todas_linhas)):
            if isinstance(todas_linhas[i], LinhaLabel) and todas_linhas[i].nome == op.valor:
                # Verificar se há instruções entre o jump e o label
                tem_instrucoes_entre = False
                for j in range(indice + 1, i):
                    if isinstance(todas_linhas[j], LinhaInstrucao):
                        tem_instrucoes_entre = True
                        break
                
                if tem_instrucoes_entre:
                    self.aviso(f"Jump para label '{op.valor}' ignora instruções intermediárias", 
                              op.linha, op.coluna)
                break
    
    def _verificar_load(self, instrucao):
        """load reg, [mem]"""
        ops = instrucao.operandos
        linha = instrucao.linha
        coluna = instrucao.coluna
        
        if len(ops) != 2:
            self.erro("Instrução load requer 2 operandos", linha, coluna)
            return
        
        # Primeiro operando deve ser registrador
        if ops[0].tipo != 'reg':
            self.erro(f"Primeiro operando de load deve ser registrador, encontrado {ops[0].tipo}", 
                     ops[0].linha, ops[0].coluna)
        
        # Segundo operando deve ser memória
        if ops[1].tipo != 'mem':
            self.erro(f"Segundo operando de load deve ser [endereço], encontrado {ops[1].tipo}", 
                     ops[1].linha, ops[1].coluna)
    
    def _verificar_store(self, instrucao):
        """store [mem], reg"""
        ops = instrucao.operandos
        linha = instrucao.linha
        coluna = instrucao.coluna
        
        if len(ops) != 2:
            self.erro("Instrução store requer 2 operandos", linha, coluna)
            return
        
        # Primeiro operando deve ser memória
        if ops[0].tipo != 'mem':
            self.erro(f"Primeiro operando de store deve ser [endereço], encontrado {ops[0].tipo}", 
                     ops[0].linha, ops[0].coluna)
        
        # Segundo operando deve ser registrador
        if ops[1].tipo != 'reg':
            self.erro(f"Segundo operando de store deve ser registrador, encontrado {ops[1].tipo}", 
                     ops[1].linha, ops[1].coluna)
    
    def _verificacoes_finais(self):
        """Verificações após análise completa"""
        # Verificar labels não referenciados (exceto 'main')
        nao_referenciados = self.tabela.verificar_labels_nao_referenciados()
        for simbolo in nao_referenciados:
            if simbolo.nome != 'main':  # main é ponto de entrada, não precisa ser referenciado
                self.aviso(f"Label '{simbolo.nome}' definido mas nunca referenciado", 
                          simbolo.linha, simbolo.coluna)
    
    def tem_erros(self):
        return len(self.erros) > 0
    
    def tem_avisos(self):
        return len(self.avisos) > 0
    
    def mostrar_resultados(self):
        print("\n" + "=" * 60)
        print("RESULTADOS DA ANÁLISE SEMÂNTICA")
        print("=" * 60)
        
        if self.avisos:
            print(f"\n📌 Avisos ({len(self.avisos)}):")
            for aviso in self.avisos:
                print(f"  ⚠️  {aviso}")
        
        if self.erros:
            print(f"\n❌ Erros ({len(self.erros)}):")
            for erro in self.erros:
                print(f"  🚫 {erro}")
        
        if not self.erros and not self.avisos:
            print("\n✅ Nenhum erro ou aviso encontrado!")
        elif not self.erros:
            print("\n✅ Nenhum erro encontrado (apenas avisos)!")
        
        print("\n" + str(self.tabela))
        print(f"\nTotal de instruções analisadas: {self.contador_instrucoes}")
