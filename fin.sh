# ============================================
# GERADOR DE CÓDIGO DE MÁQUINA
# ============================================

# 1. Definição dos Opcodes
cat > src/gerador/__init__.py << 'EOF'
from .opcodes import Opcode, TAMANHO_INSTRUCAO
from .gerador_codigo import GeradorCodigo

__all__ = ['GeradorCodigo', 'Opcode', 'TAMANHO_INSTRUCAO']
EOF

cat > src/gerador/opcodes.py << 'EOF'
from enum import Enum

class Opcode(Enum):
    """Conjunto de instruções de máquina da CPU Didática"""
    # Instruções de movimento
    MOV_REG_REG = 0x01    # mov reg, reg
    MOV_REG_IMD = 0x02    # mov reg, imediato
    
    # Instruções aritméticas
    ADD_REG_REG = 0x03    # add reg, reg
    SUB_REG_REG = 0x04    # sub reg, reg
    MUL_REG_REG = 0x05    # mul reg, reg
    DIV_REG_REG = 0x06    # div reg, reg
    
    # Comparação
    CMP_REG_REG = 0x07    # cmp reg, reg
    CMP_REG_IMD = 0x08    # cmp reg, imediato
    
    # Saltos
    JMP = 0x09            # jmp label
    JE  = 0x0A            # je label
    JNE = 0x0B            # jne label
    JG  = 0x0C            # jg label
    JL  = 0x0D            # jl label
    JLE = 0x0E            # jle label
    JGE = 0x0F            # jge label
    
    # Acesso à memória
    LOAD  = 0x10          # load reg, [end]
    STORE = 0x11          # store [end], reg
    
    # Controle
    HLT = 0xFF            # halt
    
    # Dados
    DATA = 0x00           # dado bruto (para inicialização)

# Tamanhos em bytes
TAMANHO_INSTRUCAO = {
    Opcode.MOV_REG_REG: 3,   # opcode + reg_dest + reg_orig
    Opcode.MOV_REG_IMD: 3,   # opcode + reg_dest + valor
    Opcode.ADD_REG_REG: 3,   # opcode + reg_dest + reg_orig
    Opcode.SUB_REG_REG: 3,
    Opcode.MUL_REG_REG: 3,
    Opcode.DIV_REG_REG: 3,
    Opcode.CMP_REG_REG: 3,
    Opcode.CMP_REG_IMD: 3,
    Opcode.JMP: 3,           # opcode + endereço (2 bytes)
    Opcode.JE:  3,
    Opcode.JNE: 3,
    Opcode.JG:  3,
    Opcode.JL:  3,
    Opcode.JLE: 3,
    Opcode.JGE: 3,
    Opcode.LOAD:  3,         # opcode + reg + endereço
    Opcode.STORE: 3,         # opcode + endereço + reg
    Opcode.HLT: 1,           # apenas opcode
    Opcode.DATA: 1,          # opcode + dado
}

# Codificação de registradores
REG_CODES = {
    'a': 0x00,
    'b': 0x01,
    'c': 0x02,
    'd': 0x03
}
EOF

cat > src/gerador/gerador_codigo.py << 'EOF'
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
EOF

# ============================================
# ATUALIZAR MAIN.PY COM GERADOR DE CÓDIGO
# ============================================

cat > main.py << 'EOF'
import sys
import os
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo

def compilar(arquivo_entrada, verbose=False, saida_bin=None, saida_hex=None):
    """Compila um arquivo assembly didático"""
    try:
        with open(arquivo_entrada, 'r') as f:
            codigo_fonte = f.read()
    except FileNotFoundError:
        print(f"Erro: Arquivo '{arquivo_entrada}' não encontrado.")
        return None
    
    print("=" * 60)
    print("COMPILADOR ASSEMBLY DIDÁTICO")
    print("=" * 60)
    print(f"Arquivo: {arquivo_entrada}")
    print(f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Fase 1: Análise Léxica
    print("\n[1/4] ANÁLISE LÉXICA")
    print("-" * 40)
    lexer = Lexer(codigo_fonte)
    tokens = lexer.tokenizar()
    
    if lexer.erros:
        print("❌ ERROS LÉXICOS ENCONTRADOS:")
        for erro in lexer.erros:
            print(f"  🚫 {erro}")
        return None
    else:
        print(f"✅ Análise léxica concluída - {len(tokens)-1} tokens encontrados")
    
    if verbose:
        print("\nTokens:")
        for token in tokens:
            if token.tipo.name != 'EOF':
                print(f"  {token}")
    
    # Fase 2: Análise Sintática
    print("\n[2/4] ANÁLISE SINTÁTICA")
    print("-" * 40)
    parser = Parser(tokens, verbose=verbose)
    ast = parser.programa()
    
    if parser.tem_erros():
        print("❌ ERROS SINTÁTICOS ENCONTRADOS:")
        for erro in parser.erros:
            print(f"  🚫 {erro}")
        return None
    else:
        print("✅ Análise sintática concluída - AST gerada com sucesso")
    
    if verbose:
        print("\nÁrvore Sintática:")
        print(ast)
    
    # Fase 3: Análise Semântica
    print("\n[3/4] ANÁLISE SEMÂNTICA")
    print("-" * 40)
    semantico = AnalisadorSemantico(verbose=verbose)
    
    if not semantico.analisar(ast):
        print("❌ ERROS SEMÂNTICOS ENCONTRADOS:")
        semantico.mostrar_resultados()
        return None
    else:
        print("✅ Análise semântica concluída - Sem erros")
    
    if verbose:
        semantico.mostrar_resultados()
    
    # Fase 4: Geração de Código
    print("\n[4/4] GERAÇÃO DE CÓDIGO DE MÁQUINA")
    print("-" * 40)
    gerador = GeradorCodigo(verbose=verbose)
    codigo = gerador.gerar(ast)
    
    if gerador.tem_erros():
        print("❌ ERROS NA GERAÇÃO DE CÓDIGO:")
        gerador.mostrar_resultados()
        return None
    
    print(f"✅ Código gerado com sucesso - {len(codigo)} bytes")
    
    # Mostrar resultados
    gerador.mostrar_resultados()
    
    # Salvar arquivos de saída
    nome_base = os.path.splitext(arquivo_entrada)[0]
    
    if saida_bin is None:
        saida_bin = f"{nome_base}.bin"
    if saida_hex is None:
        saida_hex = f"{nome_base}.hex"
    
    if gerador.gerar_arquivo_binario(saida_bin):
        print(f"\n💾 Código binário salvo em: {saida_bin}")
    
    if gerador.gerar_arquivo_hex(saida_hex):
        print(f"💾 Hexdump salvo em: {saida_hex}")
    
    print("\n" + "=" * 60)
    print("✅ COMPILAÇÃO CONCLUÍDA COM SUCESSO!")
    print("=" * 60)
    
    return codigo

def main():
    if len(sys.argv) < 2:
        print("=" * 60)
        print("COMPILADOR ASSEMBLY DIDÁTICO")
        print("=" * 60)
        print("\nUso: python main.py <arquivo.asm> [opções]")
        print("\nOpções:")
        print("  -v, --verbose    Modo detalhado")
        print("  -o <arquivo>     Arquivo de saída binário")
        print("  --hex <arquivo>  Arquivo de saída hexadecimal")
        print("\nExemplos:")
        print("  python main.py exemplos/teste.asm")
        print("  python main.py exemplos/teste.asm -v")
        print("  python main.py exemplos/teste.asm -o saida.bin --hex saida.hex")
        sys.exit(1)
    
    arquivo = sys.argv[1]
    verbose = '-v' in sys.argv or '--verbose' in sys.argv
    
    # Processar opções de saída
    saida_bin = None
    saida_hex = None
    
    if '-o' in sys.argv:
        idx = sys.argv.index('-o')
        if idx + 1 < len(sys.argv):
            saida_bin = sys.argv[idx + 1]
    
    if '--hex' in sys.argv:
        idx = sys.argv.index('--hex')
        if idx + 1 < len(sys.argv):
            saida_hex = sys.argv[idx + 1]
    
    codigo = compilar(arquivo, verbose, saida_bin, saida_hex)
    
    if codigo is None:
        print("\n❌ Compilação falhou!")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# ============================================
# TESTES COMPLETOS DO COMPILADOR
# ============================================

# Criar diretório de saída de testes
mkdir -p tests/saidas

cat > tests/compilador_completo.py << 'EOF'
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo

class TesteCompilador:
    def __init__(self):
        self.resultados = []
        self.arquivo_saida = "tests/saidas/resultado_testes.txt"
    
    def executar_todos(self):
        """Executa todos os testes e salva resultado em arquivo"""
        with open(self.arquivo_saida, 'w', encoding='utf-8') as f:
            f.write("=" * 70 + "\n")
            f.write("RESULTADOS DOS TESTES DO COMPILADOR ASSEMBLY DIDÁTICO\n")
            f.write("=" * 70 + "\n\n")
            
            # Testes básicos
            self._teste_basico(f)
            self._teste_mov(f)
            self._teste_aritmetica(f)
            self._teste_comparacao_saltos(f)
            self._teste_memoria(f)
            self._teste_programa_completo(f)
            
            # Resumo
            self._resumo(f)
        
        print(f"\n📄 Resultados salvos em: {self.arquivo_saida}")
    
    def _compilar_codigo(self, codigo, descricao):
        """Compila um código e retorna resultados"""
        lexer = Lexer(codigo)
        tokens = lexer.tokenizar()
        
        if lexer.erros:
            return {'sucesso': False, 'fase': 'léxica', 'erros': lexer.erros}
        
        parser = Parser(tokens)
        ast = parser.programa()
        
        if parser.erros:
            return {'sucesso': False, 'fase': 'sintática', 'erros': parser.erros}
        
        semantico = AnalisadorSemantico()
        if not semantico.analisar(ast):
            return {'sucesso': False, 'fase': 'semântica', 'erros': semantico.erros}
        
        gerador = GeradorCodigo()
        codigo_gerado = gerador.gerar(ast)
        
        if gerador.erros:
            return {'sucesso': False, 'fase': 'geração', 'erros': gerador.erros}
        
        return {
            'sucesso': True,
            'codigo': codigo_gerado,
            'bytes': len(codigo_gerado),
            'labels': len(gerador.tabela_labels),
            'hexdump': gerador.gerar_hexdump()
        }
    
    def _teste_basico(self, f):
        f.write("TESTE 1: Instruções Básicas\n")
        f.write("-" * 70 + "\n")
        
        codigo = "hlt"
        resultado = self._compilar_codigo(codigo, "HLT")
        self._registrar_teste(f, "HLT sozinho", resultado, 1)
        
        codigo = "main:\n    hlt"
        resultado = self._compilar_codigo(codigo, "Label + HLT")
        self._registrar_teste(f, "Label + HLT", resultado, 1)
        f.write("\n")
    
    def _teste_mov(self, f):
        f.write("TESTE 2: Instruções MOV\n")
        f.write("-" * 70 + "\n")
        
        codigo = "mov a, 10\nhlt"
        resultado = self._compilar_codigo(codigo, "MOV reg, imediato")
        self._registrar_teste(f, "MOV reg, imediato", resultado, 4)
        
        codigo = "mov a, b\nhlt"
        resultado = self._compilar_codigo(codigo, "MOV reg, reg")
        self._registrar_teste(f, "MOV reg, reg", resultado, 4)
        
        codigo = "mov a, 0xFF\nhlt"
        resultado = self._compilar_codigo(codigo, "MOV reg, hex")
        self._registrar_teste(f, "MOV com hexadecimal", resultado, 4)
        f.write("\n")
    
    def _teste_aritmetica(self, f):
        f.write("TESTE 3: Instruções Aritméticas\n")
        f.write("-" * 70 + "\n")
        
        instrucoes = ['add', 'sub', 'mul', 'div']
        for inst in instrucoes:
            codigo = f"mov a, 10\nmov b, 5\n{inst} a, b\nhlt"
            resultado = self._compilar_codigo(codigo, f"{inst.upper()} reg, reg")
            self._registrar_teste(f, f"{inst.upper()} registradores", resultado, 10)
        f.write("\n")
    
    def _teste_comparacao_saltos(self, f):
        f.write("TESTE 4: Comparações e Saltos\n")
        f.write("-" * 70 + "\n")
        
        codigo = "cmp a, 10\nhlt"
        resultado = self._compilar_codigo(codigo, "CMP reg, imediato")
        self._registrar_teste(f, "CMP reg, imediato", resultado, 4)
        
        codigo = "main:\n    cmp a, b\n    je igual\n    hlt\nigual:\n    hlt"
        resultado = self._compilar_codigo(codigo, "CMP + JE")
        self._registrar_teste(f, "CMP + JE com labels", resultado, 11)
        
        saltos = ['jmp', 'je', 'jne', 'jg', 'jl', 'jle', 'jge']
        for salto in saltos:
            codigo = f"loop:\n    {salto} loop\n    hlt"
            resultado = self._compilar_codigo(codigo, f"Salto {salto.upper()}")
            self._registrar_teste(f, f"Salto {salto.upper()}", resultado, 4)
        f.write("\n")
    
    def _teste_memoria(self, f):
        f.write("TESTE 5: Acesso à Memória\n")
        f.write("-" * 70 + "\n")
        
        codigo = "mov a, 42\nstore [0xFF], a\nhlt"
        resultado = self._compilar_codigo(codigo, "STORE")
        self._registrar_teste(f, "STORE na memória", resultado, 7)
        
        codigo = "store [0xFF], a\nload b, [0xFF]\nhlt"
        resultado = self._compilar_codigo(codigo, "LOAD/STORE")
        self._registrar_teste(f, "LOAD da memória", resultado, 7)
        f.write("\n")
    
    def _teste_programa_completo(self, f):
        f.write("TESTE 6: Programa Completo\n")
        f.write("-" * 70 + "\n")
        
        codigo = """main:
    mov a, 0
    mov b, 10
loop:
    add a, b
    sub b, 1
    cmp b, 0
    jne loop
    hlt"""
        
        resultado = self._compilar_codigo(codigo, "Loop completo")
        self._registrar_teste(f, "Programa com loop", resultado, 19)
        
        codigo = """main:
    mov a, 10
    mov b, 20
    cmp a, b
    jg maior
    mov c, 0
    jmp fim
maior:
    mov c, 1
fim:
    hlt"""
        
        resultado = self._compilar_codigo(codigo, "Condicional completo")
        self._registrar_teste(f, "Programa com condicional", resultado, 22)
        f.write("\n")
    
    def _registrar_teste(self, f, nome, resultado, bytes_esperados=None):
        status = "✅ PASSOU" if resultado['sucesso'] else "❌ FALHOU"
        f.write(f"\n  {status} - {nome}\n")
        
        if resultado['sucesso']:
            f.write(f"    Bytes gerados: {resultado['bytes']}\n")
            f.write(f"    Labels: {resultado['labels']}\n")
            
            if bytes_esperados and resultado['bytes'] != bytes_esperados:
                f.write(f"    ⚠️  Atenção: esperado {bytes_esperados} bytes\n")
            
            f.write(f"    Hexdump:\n")
            for linha in resultado['hexdump'].split('\n')[-4:]:
                f.write(f"      {linha}\n")
        else:
            f.write(f"    Fase do erro: {resultado['fase']}\n")
            for erro in resultado['erros']:
                f.write(f"    🚫 {erro}\n")
        
        self.resultados.append((nome, resultado['sucesso']))
    
    def _resumo(self, f):
        f.write("\n" + "=" * 70 + "\n")
        f.write("RESUMO FINAL\n")
        f.write("=" * 70 + "\n\n")
        
        total = len(self.resultados)
        sucessos = sum(1 for _, r in self.resultados if r)
        falhas = total - sucessos
        
        f.write(f"Total de testes: {total}\n")
        f.write(f"Sucessos: {sucessos}\n")
        f.write(f"Falhas: {falhas}\n")
        f.write(f"Taxa de sucesso: {(sucessos/total)*100:.1f}%\n\n")
        
        f.write("Detalhamento:\n")
        for nome, sucesso in self.resultados:
            status = "✅" if sucesso else "❌"
            f.write(f"  {status} {nome}\n")

if __name__ == "__main__":
    print("=" * 60)
    print("EXECUTANDO TESTES DO COMPILADOR COMPLETO")
    print("=" * 60)
    
    teste = TesteCompilador()
    teste.executar_todos()
EOF

# ============================================
# TESTES DE INTEGRAÇÃO
# ============================================

cat > tests/integracao.py << 'EOF'
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo

def compilar_e_salvar(codigo, nome_arquivo):
    """Compila código e salva resultado binário"""
    lexer = Lexer(codigo)
    tokens = lexer.tokenizar()
    if lexer.erros:
        return False
    
    parser = Parser(tokens)
    ast = parser.programa()
    if parser.erros:
        return False
    
    semantico = AnalisadorSemantico()
    if not semantico.analisar(ast):
        return False
    
    gerador = GeradorCodigo()
    codigo_bin = gerador.gerar(ast)
    if gerador.erros:
        return False
    
    # Salvar binário
    caminho_bin = f"tests/saidas/{nome_arquivo}.bin"
    gerador.gerar_arquivo_binario(caminho_bin)
    
    # Salvar hexdump
    caminho_hex = f"tests/saidas/{nome_arquivo}.hex"
    gerador.gerar_arquivo_hex(caminho_hex)
    
    return True

def main():
    print("=" * 60)
    print("TESTES DE INTEGRAÇÃO - GERAÇÃO DE EXECUTÁVEIS")
    print("=" * 60)
    
    testes = {
        "01_hlt": "hlt",
        "02_mov_simples": "mov a, 42\nhlt",
        "03_mov_regs": "mov a, 10\nmov b, a\nhlt",
        "04_add": "mov a, 10\nmov b, 20\nadd a, b\nhlt",
        "05_loop": "main:\n    mov a, 5\nloop:\n    sub a, 1\n    cmp a, 0\n    jne loop\n    hlt",
        "06_condicional": "main:\n    mov a, 10\n    mov b, 5\n    cmp a, b\n    jg maior\n    mov c, 0\n    jmp fim\nmaior:\n    mov c, 1\nfim:\n    hlt",
        "07_memoria": "mov a, 0xFF\nstore [0x10], a\nload b, [0x10]\nhlt",
        "08_saltos": "inicio:\n    jmp meio\n    hlt\nmeio:\n    jmp fim\n    hlt\nfim:\n    hlt",
    }
    
    for nome, codigo in testes.items():
        resultado = compilar_e_salvar(codigo, nome)
        status = "✅" if resultado else "❌"
        print(f"  {status} {nome}")
    
    print(f"\n📄 Arquivos gerados em: tests/saidas/")
    print("  Arquivos .bin (binário) e .hex (hexdump)")

if __name__ == "__main__":
    main()
EOF

# ============================================
# SIMULADOR SIMPLES DA CPU
# ============================================

cat > src/gerador/simulador.py << 'EOF'
from src.gerador.opcodes import Opcode, REG_CODES

class CPU:
    """Simulador simples da CPU Didática"""
    
    def __init__(self, memoria_tamanho=256):
        self.registradores = {'a': 0, 'b': 0, 'c': 0, 'd': 0}
        self.memoria = [0] * memoria_tamanho
        self.pc = 0  # Program Counter
        self.flags = {'zero': False, 'carry': False, 'negative': False}
        self.rodando = False
        self.codigo = []
    
    def carregar_programa(self, codigo_bytes):
        """Carrega um programa na memória"""
        self.codigo = list(codigo_bytes)
        self.pc = 0
    
    def executar(self, max_instrucoes=1000, debug=False):
        """Executa o programa carregado"""
        self.rodando = True
        instrucoes_executadas = 0
        
        while self.rodando and instrucoes_executadas < max_instrucoes:
            if self.pc >= len(self.codigo):
                print(f"⚠️  PC fora dos limites: 0x{self.pc:04X}")
                break
            
            opcode = self.codigo[self.pc]
            
            if debug:
                self._debug_state(opcode)
            
            try:
                if opcode == Opcode.HLT.value:
                    self._executar_hlt()
                    break
                
                elif opcode == Opcode.MOV_REG_REG.value:
                    self._executar_mov_reg_reg()
                
                elif opcode == Opcode.MOV_REG_IMD.value:
                    self._executar_mov_reg_imd()
                
                elif opcode == Opcode.ADD_REG_REG.value:
                    self._executar_add()
                
                elif opcode == Opcode.SUB_REG_REG.value:
                    self._executar_sub()
                
                elif opcode == Opcode.MUL_REG_REG.value:
                    self._executar_mul()
                
                elif opcode == Opcode.DIV_REG_REG.value:
                    self._executar_div()
                
                elif opcode == Opcode.CMP_REG_REG.value:
                    self._executar_cmp_reg_reg()
                
                elif opcode == Opcode.CMP_REG_IMD.value:
                    self._executar_cmp_reg_imd()
                
                elif opcode in [Opcode.JMP.value, Opcode.JE.value, Opcode.JNE.value,
                               Opcode.JG.value, Opcode.JL.value, Opcode.JLE.value, Opcode.JGE.value]:
                    self._executar_jump(opcode)
                
                elif opcode == Opcode.LOAD.value:
                    self._executar_load()
                
                elif opcode == Opcode.STORE.value:
                    self._executar_store()
                
                else:
                    print(f"⚠️  Opcode desconhecido: 0x{opcode:02X} no endereço 0x{self.pc:04X}")
                    break
                
                instrucoes_executadas += 1
            
            except IndexError:
                print(f"⚠️  Erro: código truncado no endereço 0x{self.pc:04X}")
                break
        
        return instrucoes_executadas
    
    def _debug_state(self, opcode):
        """Mostra estado atual para debug"""
        regs = ' '.join(f'{r}={self.registradores[r]:3d}' for r in ['a', 'b', 'c', 'd'])
        flags = f"Z={int(self.flags['zero'])} C={int(self.flags['carry'])} N={int(self.flags['negative'])}"
        print(f"PC=0x{self.pc:04X} OP=0x{opcode:02X} | {regs} | {flags}")
    
    def _ler_reg(self, codigo):
        """Converte código para nome do registrador"""
        for nome, code in REG_CODES.items():
            if code == codigo:
                return nome
        return None
    
    def _executar_hlt(self):
        self.rodando = False
        self.pc += 1
    
    def _executar_mov_reg_reg(self):
        reg_dest = self._ler_reg(self.codigo[self.pc + 1])
        reg_orig = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg_dest and reg_orig:
            self.registradores[reg_dest] = self.registradores[reg_orig] & 0xFF
        
        self.pc += 3
    
    def _executar_mov_reg_imd(self):
        reg_dest = self._ler_reg(self.codigo[self.pc + 1])
        valor = self.codigo[self.pc + 2]
        
        if reg_dest:
            self.registradores[reg_dest] = valor & 0xFF
        
        self.pc += 3
    
    def _executar_add(self):
        reg_dest = self._ler_reg(self.codigo[self.pc + 1])
        reg_orig = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg_dest and reg_orig:
            resultado = self.registradores[reg_dest] + self.registradores[reg_orig]
            self.flags['carry'] = resultado > 255
            self.registradores[reg_dest] = resultado & 0xFF
        
        self.pc += 3
    
    def _executar_sub(self):
        reg_dest = self._ler_reg(self.codigo[self.pc + 1])
        reg_orig = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg_dest and reg_orig:
            resultado = self.registradores[reg_dest] - self.registradores[reg_orig]
            self.flags['negative'] = resultado < 0
            self.registradores[reg_dest] = resultado & 0xFF
        
        self.pc += 3
    
    def _executar_mul(self):
        reg_dest = self._ler_reg(self.codigo[self.pc + 1])
        reg_orig = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg_dest and reg_orig:
            resultado = self.registradores[reg_dest] * self.registradores[reg_orig]
            self.flags['carry'] = resultado > 255
            self.registradores[reg_dest] = resultado & 0xFF
        
        self.pc += 3
    
    def _executar_div(self):
        reg_dest = self._ler_reg(self.codigo[self.pc + 1])
        reg_orig = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg_dest and reg_orig:
            divisor = self.registradores[reg_orig]
            if divisor != 0:
                self.registradores[reg_dest] = (self.registradores[reg_dest] // divisor) & 0xFF
            else:
                print("⚠️  Divisão por zero!")
        
        self.pc += 3
    
    def _executar_cmp_reg_reg(self):
        reg1 = self._ler_reg(self.codigo[self.pc + 1])
        reg2 = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg1 and reg2:
            resultado = self.registradores[reg1] - self.registradores[reg2]
            self._atualizar_flags(resultado)
        
        self.pc += 3
    
    def _executar_cmp_reg_imd(self):
        reg = self._ler_reg(self.codigo[self.pc + 1])
        valor = self.codigo[self.pc + 2]
        
        if reg:
            resultado = self.registradores[reg] - valor
            self._atualizar_flags(resultado)
        
        self.pc += 3
    
    def _atualizar_flags(self, resultado):
        self.flags['zero'] = resultado == 0
        self.flags['negative'] = resultado < 0
        self.flags['carry'] = resultado > 255 or resultado < -255
    
    def _executar_jump(self, opcode):
        endereco = (self.codigo[self.pc + 1] << 8) | self.codigo[self.pc + 2]
        
        saltar = False
        
        if opcode == Opcode.JMP.value:
            saltar = True
        elif opcode == Opcode.JE.value:
            saltar = self.flags['zero']
        elif opcode == Opcode.JNE.value:
            saltar = not self.flags['zero']
        elif opcode == Opcode.JG.value:
            saltar = not self.flags['zero'] and not self.flags['negative']
        elif opcode == Opcode.JL.value:
            saltar = self.flags['negative']
        elif opcode == Opcode.JLE.value:
            saltar = self.flags['zero'] or self.flags['negative']
        elif opcode == Opcode.JGE.value:
            saltar = not self.flags['negative'] or self.flags['zero']
        
        if saltar:
            self.pc = endereco
        else:
            self.pc += 3
    
    def _executar_load(self):
        reg = self._ler_reg(self.codigo[self.pc + 1])
        endereco = self.codigo[self.pc + 2]
        
        if reg and endereco < len(self.memoria):
            self.registradores[reg] = self.memoria[endereco] & 0xFF
        
        self.pc += 3
    
    def _executar_store(self):
        endereco = self.codigo[self.pc + 1]
        reg = self._ler_reg(self.codigo[self.pc + 2])
        
        if reg and endereco < len(self.memoria):
            self.memoria[endereco] = self.registradores[reg] & 0xFF
        
        self.pc += 3
    
    def mostrar_estado(self):
        print("\n" + "=" * 50)
        print("ESTADO DA CPU")
        print("=" * 50)
        print(f"PC: 0x{self.pc:04X}")
        print(f"Registradores:")
        for reg in ['a', 'b', 'c', 'd']:
            print(f"  {reg}: {self.registradores[reg]:3d} (0x{self.registradores[reg]:02X})")
        print(f"Flags: Z={int(self.flags['zero'])} C={int(self.flags['carry'])} N={int(self.flags['negative'])}")
        print(f"Memória (não-zero):")
        for i, val in enumerate(self.memoria):
            if val != 0:
                print(f"  [0x{i:02X}]: {val:3d} (0x{val:02X})")
EOF

# ============================================
# ATUALIZAR MAIN PARA SUPORTAR SIMULAÇÃO
# ============================================

cat > simulador.py << 'EOF'
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.lexico.lexer import Lexer
from src.sintatico.parser import Parser
from src.semantico.analisador_semantico import AnalisadorSemantico
from src.gerador.gerador_codigo import GeradorCodigo
from src.gerador.simulador import CPU

def compilar_e_simular(arquivo_asm, debug=False):
    """Compila e executa um programa assembly no simulador"""
    try:
        with open(arquivo_asm, 'r') as f:
            codigo_fonte = f.read()
    except FileNotFoundError:
        print(f"Erro: Arquivo '{arquivo_asm}' não encontrado.")
        return
    
    print("=" * 60)
    print("COMPILADOR + SIMULADOR ASSEMBLY DIDÁTICO")
    print("=" * 60)
    
    # Compilar
    lexer = Lexer(codigo_fonte)
    tokens = lexer.tokenizar()
    if lexer.erros:
        print("Erros léxicos!"); return
    
    parser = Parser(tokens)
    ast = parser.programa()
    if parser.erros:
        print("Erros sintáticos!"); return
    
    semantico = AnalisadorSemantico()
    if not semantico.analisar(ast):
        print("Erros semânticos!"); return
    
    gerador = GeradorCodigo()
    codigo = gerador.gerar(ast)
    if gerador.erros:
        print("Erros na geração!"); return
    
    print(f"✅ Compilado: {len(codigo)} bytes gerados")
    
    # Simular
    print("\n" + "=" * 60)
    print("EXECUTANDO NO SIMULADOR")
    print("=" * 60)
    
    cpu = CPU()
    cpu.carregar_programa(codigo)
    
    instrucoes = cpu.executar(debug=debug)
    
    print(f"\n✅ Execução concluída: {instrucoes} instruções executadas")
    cpu.mostrar_estado()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python simulador.py <arquivo.asm> [-d]")
        print("  -d: modo debug (mostra cada instrução)")
        sys.exit(1)
    
    arquivo = sys.argv[1]
    debug = '-d' in sys.argv
    
    compilar_e_simular(arquivo, debug)
EOF

# ============================================
# CRIAR EXEMPLOS ADICIONAIS
# ============================================

cat > exemplos/soma_1_a_10.asm << 'EOF'
; Programa: Soma de 1 a 10
; Resultado: a = 55 (0x37)
main:
    mov a, 0        ; Acumulador = 0
    mov b, 1        ; Contador = 1
loop:
    add a, b        ; Acumulador += Contador
    add b, 1        ; Contador++
    cmp b, 10       ; Contador <= 10?
    jle loop        ; Se sim, continua
    hlt
EOF

cat > exemplos/fatorial.asm << 'EOF'
; Programa: Fatorial de 5
; Resultado: a = 120 (0x78)
main:
    mov a, 1        ; Resultado = 1
    mov b, 5        ; Contador = 5
loop:
    mul a, b        ; Resultado *= Contador
    sub b, 1        ; Contador--
    cmp b, 1        ; Contador > 1?
    jg loop         ; Se sim, continua
    hlt
EOF

cat > exemplos/maior_numero.asm << 'EOF'
; Programa: Encontra o maior entre dois números
main:
    mov a, 30       ; Primeiro número
    mov b, 50       ; Segundo número
    cmp a, b        ; Compara a com b
    jg a_maior      ; Se a > b
    mov c, b        ; Senão, maior = b
    jmp fim
a_maior:
    mov c, a        ; maior = a
fim:
    hlt
EOF

cat > exemplos/soma_memoria.asm << 'EOF'
; Programa: Teste de load/store
main:
    mov a, 10
    mov b, 20
    store [0x10], a    ; Mem[0x10] = 10
    store [0x11], b    ; Mem[0x11] = 20
    load c, [0x10]     ; c = Mem[0x10]
    load d, [0x11]     ; d = Mem[0x11]
    add c, d           ; c = c + d
    hlt
EOF

# ============================================
# ATUALIZAR README
# ============================================

cat > README.md << 'EOF'
# Compilador Assembly Didático

Compilador completo para uma linguagem Assembly Didática, desenvolvido para fins educacionais.

## 📋 Características

- **Linguagem fonte**: Assembly Didático com suporte a:
  - 4 registradores: a, b, c, d
  - Instruções aritméticas: add, sub, mul, div
  - Movimentação: mov
  - Comparação: cmp
  - Saltos condicionais: je, jne, jg, jl, jle, jge
  - Salto incondicional: jmp
  - Acesso à memória: load, store
  - Parada: hlt
  - Labels e comentários (;)

- **Fases do compilador**:
  1. Análise Léxica (tokenização)
  2. Análise Sintática (parser + AST)
  3. Análise Semântica (verificação de tipos)
  4. Geração de Código de Máquina

## 🚀 Uso

### Compilar um programa
```bash
