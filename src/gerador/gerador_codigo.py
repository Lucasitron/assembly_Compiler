from src.sintatico.ast import *
from src.gerador.opcodes import Opcode, TAMANHO_INSTRUCAO, REG_CODES

class GeradorCodigo:
    def __init__(self, verbose=False):
        self.codigo_maquina = []     # Lista de bytes do código gerado
        self.tabela_labels = {}      # Nome do label -> endereço
        self.pendencias = []         # Labels não resolvidos (endereço, label, linha)
        self.contador_endereco = 0   # Endereço atual de geração
        self.verbose = verbose
        self.erros = []
        self.avisos = []
    
    def log(self, mensagem):
        if self.verbose:
            print(f"[Gerador] {mensagem}")
    
    def erro(self, mensagem, linha=0, coluna=0):
        self.erros.append(f"Erro na geração de código (linha {linha}, col {coluna}): {mensagem}")
    
    def aviso(self, mensagem, linha=0, coluna=0):
        self.avisos.append(f"Aviso na geração (linha {linha}, col {coluna}): {mensagem}")
    
    def gerar(self, ast):
        """Gera código de máquina a partir da AST"""
        self.log("Iniciando geração de código...")
        
        if not isinstance(ast, Programa):
            self.erro("AST inválida para geração de código")
            return None
        
        # Primeira passada: calcular endereços dos labels
        self._primeira_passada(ast)
        
        # Segunda passada: gerar código
        self._segunda_passada(ast)
        
        # Resolver pendências
        self._resolver_pendencias()
        
        if self.erros:
            return None
        
        return self.codigo_maquina
    
    def _primeira_passada(self, programa):
        """Calcula endereços de todas as instruções e labels"""
        self.log("Primeira passada: calculando endereços...")
        
        endereco_atual = 0
        
        for linha in programa.linhas:
            if isinstance(linha, LinhaLabel):
                # Registra o endereço do label
                if linha.nome in self.tabela_labels:
                    self.erro(f"Label '{linha.nome}' duplicado", linha.linha, linha.coluna)
                self.tabela_labels[linha.nome] = endereco_atual
                self.log(f"  Label '{linha.nome}' -> endereço 0x{endereco_atual:04X}")
            
            elif isinstance(linha, LinhaInstrucao):
                # Calcula tamanho da instrução
                tamanho = self._calcular_tamanho(linha)
                endereco_atual += tamanho
    
    def _calcular_tamanho(self, instrucao):
        """Calcula o tamanho em bytes de uma instrução"""
        mnem = instrucao.mnemonico
        ops = instrucao.operandos
        
        if mnem == 'hlt':
            return TAMANHO_INSTRUCAO[Opcode.HLT]
        
        elif mnem == 'mov':
            if len(ops) >= 2 and ops[1].tipo == 'reg':
                return TAMANHO_INSTRUCAO[Opcode.MOV_REG_REG]
            else:
                return TAMANHO_INSTRUCAO[Opcode.MOV_REG_IMD]
        
        elif mnem in ['add', 'sub', 'mul', 'div']:
            return TAMANHO_INSTRUCAO[Opcode.ADD_REG_REG]
        
        elif mnem == 'cmp':
            if len(ops) >= 2 and ops[1].tipo == 'reg':
                return TAMANHO_INSTRUCAO[Opcode.CMP_REG_REG]
            else:
                return TAMANHO_INSTRUCAO[Opcode.CMP_REG_IMD]
        
        elif mnem in ['jmp', 'je', 'jne', 'jg', 'jl', 'jle', 'jge']:
            return TAMANHO_INSTRUCAO[Opcode.JMP]
        
        elif mnem == 'load':
            return TAMANHO_INSTRUCAO[Opcode.LOAD]
        
        elif mnem == 'store':
            return TAMANHO_INSTRUCAO[Opcode.STORE]
        
        return 0
    
    def _segunda_passada(self, programa):
        """Gera o código de máquina instrução por instrução"""
        self.log("Segunda passada: gerando código...")
        
        self.contador_endereco = 0
        
        for linha in programa.linhas:
            if isinstance(linha, LinhaLabel):
                # Labels já foram processados na primeira passada
                continue
            
            elif isinstance(linha, LinhaInstrucao):
                bytes_gerados = self._gerar_instrucao(linha)
                if bytes_gerados:
                    self.codigo_maquina.extend(bytes_gerados)
                    self.contador_endereco += len(bytes_gerados)
    
    def _gerar_instrucao(self, instrucao):
        """Gera os bytes para uma instrução específica"""
        mnem = instrucao.mnemonico
        ops = instrucao.operandos
        linha = instrucao.linha
        
        try:
            if mnem == 'hlt':
                return self._gerar_hlt()
            
            elif mnem == 'mov':
                return self._gerar_mov(ops, linha)
            
            elif mnem in ['add', 'sub', 'mul', 'div']:
                return self._gerar_aritmetica(mnem, ops, linha)
            
            elif mnem == 'cmp':
                return self._gerar_cmp(ops, linha)
            
            elif mnem in ['jmp', 'je', 'jne', 'jg', 'jl', 'jle', 'jge']:
                return self._gerar_jump(mnem, ops, linha)
            
            elif mnem == 'load':
                return self._gerar_load(ops, linha)
            
            elif mnem == 'store':
                return self._gerar_store(ops, linha)
            
            else:
                self.erro(f"Instrução não suportada: {mnem}", linha)
                return None
        
        except Exception as e:
            self.erro(f"Erro ao gerar {mnem}: {str(e)}", linha)
            return None
    
    def _gerar_hlt(self):
        """HLT -> 0xFF"""
        self.log("  Gerando HLT")
        return [Opcode.HLT.value]
    
    def _gerar_mov(self, ops, linha):
        """MOV reg, valor"""
        if len(ops) < 2:
            self.erro("MOV requer 2 operandos", linha)
            return None
        
        reg_dest = REG_CODES.get(ops[0].valor)
        if reg_dest is None:
            self.erro(f"Registrador inválido: {ops[0].valor}", linha)
            return None
        
        if ops[1].tipo == 'reg':
            # mov reg, reg
            reg_orig = REG_CODES.get(ops[1].valor)
            if reg_orig is None:
                self.erro(f"Registrador inválido: {ops[1].valor}", linha)
                return None
            self.log(f"  MOV_REG_REG {ops[0].valor}, {ops[1].valor}")
            return [Opcode.MOV_REG_REG.value, reg_dest, reg_orig]
        else:
            # mov reg, imediato
            valor = self._parse_valor(ops[1])
            if valor > 255:
                self.aviso(f"Valor {valor} truncado para 8 bits", linha)
                valor = valor & 0xFF
            self.log(f"  MOV_REG_IMD {ops[0].valor}, {valor}")
            return [Opcode.MOV_REG_IMD.value, reg_dest, valor & 0xFF]
    
    def _gerar_aritmetica(self, mnem, ops, linha):
        """ADD/SUB/MUL/DIV reg, reg"""
        if len(ops) < 2:
            self.erro(f"{mnem.upper()} requer 2 operandos", linha)
            return None
        
        reg_dest = REG_CODES.get(ops[0].valor)
        reg_orig = REG_CODES.get(ops[1].valor)
        
        if reg_dest is None or reg_orig is None:
            self.erro("Registrador inválido", linha)
            return None
        
        opcodes = {
            'add': Opcode.ADD_REG_REG,
            'sub': Opcode.SUB_REG_REG,
            'mul': Opcode.MUL_REG_REG,
            'div': Opcode.DIV_REG_REG,
        }
        
        opcode = opcodes.get(mnem)
        self.log(f"  {mnem.upper()} {ops[0].valor}, {ops[1].valor}")
        return [opcode.value, reg_dest, reg_orig]
    
    def _gerar_cmp(self, ops, linha):
        """CMP reg, valor"""
        if len(ops) < 2:
            self.erro("CMP requer 2 operandos", linha)
            return None
        
        reg = REG_CODES.get(ops[0].valor)
        if reg is None:
            self.erro(f"Registrador inválido: {ops[0].valor}", linha)
            return None
        
        if ops[1].tipo == 'reg':
            # cmp reg, reg
            reg2 = REG_CODES.get(ops[1].valor)
            self.log(f"  CMP_REG_REG {ops[0].valor}, {ops[1].valor}")
            return [Opcode.CMP_REG_REG.value, reg, reg2]
        else:
            # cmp reg, imediato
            valor = self._parse_valor(ops[1])
            if valor > 255:
                valor = valor & 0xFF
            self.log(f"  CMP_REG_IMD {ops[0].valor}, {valor}")
            return [Opcode.CMP_REG_IMD.value, reg, valor & 0xFF]
    
    def _gerar_jump(self, mnem, ops, linha):
        """JMP/JE/JNE/JG/JL/JLE/JGE label"""
        if len(ops) < 1:
            self.erro(f"{mnem.upper()} requer 1 operando", linha)
            return None
        
        label = ops[0].valor
        
        opcodes = {
            'jmp': Opcode.JMP,
            'je': Opcode.JE,
            'jne': Opcode.JNE,
            'jg': Opcode.JG,
            'jl': Opcode.JL,
            'jle': Opcode.JLE,
            'jge': Opcode.JGE,
        }
        
        opcode = opcodes.get(mnem)
        
        if label in self.tabela_labels:
            # Label já resolvido
            endereco = self.tabela_labels[label]
            self.log(f"  {mnem.upper()} {label} -> 0x{endereco:04X}")
            return [opcode.value, (endereco >> 8) & 0xFF, endereco & 0xFF]
        else:
            # Label ainda não resolvido (forward reference)
            self.log(f"  {mnem.upper()} {label} -> [pendente]")
            # Reserva espaço e registra pendência
            endereco_atual = len(self.codigo_maquina)
            self.pendencias.append((endereco_atual + 1, label, linha))
            return [opcode.value, 0x00, 0x00]  # Placeholder
    
    def _gerar_load(self, ops, linha):
        """LOAD reg, [end]"""
        if len(ops) < 2:
            self.erro("LOAD requer 2 operandos", linha)
            return None
        
        reg = REG_CODES.get(ops[0].valor)
        if reg is None:
            self.erro(f"Registrador inválido: {ops[0].valor}", linha)
            return None
        
        # Endereço de memória
        if isinstance(ops[1], OperandoMemoria):
            endereco = self._parse_valor(ops[1].endereco)
        else:
            endereco = self._parse_valor(ops[1])
        
        if endereco > 255:
            endereco = endereco & 0xFF
        
        self.log(f"  LOAD {ops[0].valor}, [0x{endereco:02X}]")
        return [Opcode.LOAD.value, reg, endereco & 0xFF]
    
    def _gerar_store(self, ops, linha):
        """STORE [end], reg"""
        if len(ops) < 2:
            self.erro("STORE requer 2 operandos", linha)
            return None
        
        # Endereço de memória
        if isinstance(ops[0], OperandoMemoria):
            endereco = self._parse_valor(ops[0].endereco)
        else:
            endereco = self._parse_valor(ops[0])
        
        if endereco > 255:
            endereco = endereco & 0xFF
        
        # Registrador fonte
        if ops[1].tipo != 'reg':
            self.erro(f"STORE requer registrador como fonte", linha)
            return None
        
        reg = REG_CODES.get(ops[1].valor)
        if reg is None:
            self.erro(f"Registrador inválido: {ops[1].valor}", linha)
            return None
        
        self.log(f"  STORE [0x{endereco:02X}], {ops[1].valor}")
        return [Opcode.STORE.value, endereco & 0xFF, reg]
    
    def _parse_valor(self, operando):
        """Converte um operando para valor numérico"""
        if operando.tipo == 'num':
            return int(operando.valor)
        elif operando.tipo == 'hex':
            return int(operando.valor, 16)
        elif operando.tipo == 'reg':
            return REG_CODES.get(operando.valor, 0)
        elif operando.tipo == 'id':
            # Referência a label - retorna 0 temporariamente
            return 0
        else:
            return 0
    
    def _resolver_pendencias(self):
        """Resolve referências a labels que ficaram pendentes"""
        self.log("Resolvendo pendências...")
        
        for endereco, label, linha in self.pendencias:
            if label in self.tabela_labels:
                endereco_label = self.tabela_labels[label]
                # Atualiza os bytes no código gerado
                self.codigo_maquina[endereco] = (endereco_label >> 8) & 0xFF
                self.codigo_maquina[endereco + 1] = endereco_label & 0xFF
                self.log(f"  Resolvido: {label} -> 0x{endereco_label:04X}")
            else:
                self.erro(f"Label '{label}' não definido", linha)
    
    def gerar_hexdump(self):
        """Gera representação hexadecimal do código"""
        if not self.codigo_maquina:
            return ""
        
        resultado = []
        resultado.append("Endereço | Bytes                          | ASCII")
        resultado.append("-" * 60)
        
        for i in range(0, len(self.codigo_maquina), 16):
            chunk = self.codigo_maquina[i:i+16]
            hex_str = ' '.join(f'{b:02X}' for b in chunk)
            ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
            resultado.append(f"0x{i:04X}  | {hex_str:<47s} | {ascii_str}")
        
        resultado.append(f"\nTamanho total: {len(self.codigo_maquina)} bytes")
        return '\n'.join(resultado)
    
    def gerar_arquivo_binario(self, nome_arquivo):
        """Salva o código gerado em arquivo binário"""
        try:
            with open(nome_arquivo, 'wb') as f:
                f.write(bytes(self.codigo_maquina))
            return True
        except Exception as e:
            self.erro(f"Erro ao salvar arquivo: {str(e)}")
            return False
    
    def gerar_arquivo_hex(self, nome_arquivo):
        """Salva o código gerado em formato Intel HEX"""
        try:
            with open(nome_arquivo, 'w') as f:
                f.write(self.gerar_hexdump())
            return True
        except Exception as e:
            self.erro(f"Erro ao salvar arquivo: {str(e)}")
            return False
    
    def tem_erros(self):
        return len(self.erros) > 0
    
    def mostrar_resultados(self):
        print("\n" + "=" * 60)
        print("RESULTADOS DA GERAÇÃO DE CÓDIGO")
        print("=" * 60)
        
        if self.avisos:
            print(f"\n📌 Avisos ({len(self.avisos)}):")
            for aviso in self.avisos:
                print(f"  ⚠️  {aviso}")
        
        if self.erros:
            print(f"\n❌ Erros ({len(self.erros)}):")
            for erro in self.erros:
                print(f"  🚫 {erro}")
            return
        
        if not self.erros and not self.avisos:
            print("\n✅ Código gerado com sucesso!")
        
        print(f"\n📊 Labels resolvidos: {len(self.tabela_labels)}")
        print(f"📊 Pendências resolvidas: {len(self.pendencias)}")
        
        print("\n📝 Hexdump do código gerado:")
        print(self.gerar_hexdump())
