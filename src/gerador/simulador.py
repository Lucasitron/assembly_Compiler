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
