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
