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
