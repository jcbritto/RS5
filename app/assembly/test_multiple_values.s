/*!
 * Teste abrangente da instrução ADD_PLUGIN com múltiplos valores
 * Baseado na instrução que funciona: 0x0020818B (ADD_PLUGIN x3, x1, x2)
 */

.section .init
.align 4

.globl _start
_start:
    # ==========================================
    # CONFIGURAÇÃO DOS VALORES DE TESTE
    # ==========================================
    
    # Teste 1: 5 + 7 = 12 (funcionando)
    li x1, 5
    li x2, 7
    
    # Teste 2: 10 + 20 = 30  
    li x4, 10
    li x5, 20
    
    # Teste 3: 0 + 42 = 42
    li x6, 0  
    li x7, 42
    
    # Teste 4: 100 + 200 = 300
    li x8, 100
    li x9, 200
    
    # ==========================================
    # EXECUÇÃO DOS TESTES
    # ==========================================
    
    # Teste 1: ADD_PLUGIN x3, x1, x2 (5 + 7 = 12)
    .word 0x0020818B  # Instrução verificada funcionando
    
    # Store resultado 1 
    li x28, 0x80001000
    sw x3, 0(x28)        # Deve ser 12 = 0x0000000C
    
    # Teste 2: ADD_PLUGIN x10, x4, x5 (10 + 20 = 30)
    # Baseado em 0x0020818B, mudando:
    # rs1: x1(00001) -> x4(00100) 
    # rs2: x2(00010) -> x5(00101)
    # rd:  x3(00011) -> x10(01010)
    .word 0x0052050B  # Calculado corretamente
    
    # Store resultado 2
    sw x10, 4(x28)       # Deve ser 30 = 0x0000001E
    
    # Teste 3: ADD_PLUGIN x11, x6, x7 (0 + 42 = 42) 
    # rs1: x6(00110), rs2: x7(00111), rd: x11(01011)
    .word 0x0073058B  # Calculado corretamente
    
    # Store resultado 3
    sw x11, 8(x28)       # Deve ser 42 = 0x0000002A
    
    # Teste 4: ADD_PLUGIN x12, x8, x9 (100 + 200 = 300)
    # rs1: x8(01000), rs2: x9(01001), rd: x12(01100)
    .word 0x0094060B  # Calculado corretamente
    
    # Store resultado 4  
    sw x12, 12(x28)      # Deve ser 300 = 0x0000012C
    
    # ==========================================
    # MARCADOR DE CONCLUSÃO
    # ==========================================
    li x29, 0xDEADBEEF   # Marcador de sucesso
    sw x29, 16(x28)
    
end_loop:
    j end_loop