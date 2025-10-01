/*!
 * Teste Extensivo ADD_PLUGIN - 8 Valores Diferentes
 * Testa a instrução personalizada ADD_PLUGIN com diferentes combinações
 * Operação: resultado = operando1 + operando2 + 5
 */

.section .text
.global _start

_start:
    # Teste 1: Valores pequenos positivos (5 + 7 = 17)
    li x1, 5         
    li x2, 7         
    .word 0x0020818B    # ADD_PLUGIN x3, x1, x2
    # Esperado: 5 + 7 + 5 = 17 (0x11)
    
    # Teste 2: Zeros (0 + 0 = 5)
    li x4, 0
    li x5, 0
    .word 0x00520A0B    # ADD_PLUGIN x20, x4, x5  
    # Esperado: 0 + 0 + 5 = 5 (0x05)
    
    # Teste 3: Um operando zero (10 + 0 = 15)
    li x6, 10
    li x7, 0
    .word 0x00738A8B    # ADD_PLUGIN x21, x6, x7
    # Esperado: 10 + 0 + 5 = 15 (0x0F)
    
    # Teste 4: Valores grandes (100 + 200 = 305)
    li x8, 100
    li x9, 200
    .word 0x00948B0B    # ADD_PLUGIN x22, x8, x9
    # Esperado: 100 + 200 + 5 = 305 (0x131)
    
    # Teste 5: Valores iguais (50 + 50 = 105)
    li x10, 50
    li x11, 50
    .word 0x00b50B8B    # ADD_PLUGIN x23, x10, x11
    # Esperado: 50 + 50 + 5 = 105 (0x69)
    
    # Teste 6: Valor negativo + positivo (-10 + 20 = 15)
    li x12, -10
    li x13, 20
    .word 0x00d60C0B    # ADD_PLUGIN x24, x12, x13
    # Esperado: -10 + 20 + 5 = 15 (0x0F)
    
    # Teste 7: Dois valores negativos (-5 + -3 = -3)
    li x14, -5
    li x15, -3
    .word 0x00f70C8B    # ADD_PLUGIN x25, x14, x15
    # Esperado: -5 + -3 + 5 = -3 (0xFFFFFFFD)
    
    # Teste 8: Valor máximo e mínimo representável em pequena escala
    li x16, 1000
    li x17, 2000
    .word 0x01180D0B    # ADD_PLUGIN x26, x16, x17
    # Esperado: 1000 + 2000 + 5 = 3005 (0xBBD)
    
    # Escrever todos os resultados na memória para verificação
    lui x28, 0x80001    # Base address 0x80001000
    
    # Resultado 1: x3 = 17
    sw x3, 0(x28)       # 0x80001000
    
    # Resultado 2: x20 = 5  
    sw x20, 4(x28)      # 0x80001004
    
    # Resultado 3: x21 = 15
    sw x21, 8(x28)      # 0x80001008
    
    # Resultado 4: x22 = 305
    sw x22, 12(x28)     # 0x8000100C
    
    # Resultado 5: x23 = 105
    sw x23, 16(x28)     # 0x80001010
    
    # Resultado 6: x24 = 15
    sw x24, 20(x28)     # 0x80001014
    
    # Resultado 7: x25 = -3
    sw x25, 24(x28)     # 0x80001018
    
    # Resultado 8: x26 = 3005
    sw x26, 28(x28)     # 0x8000101C
    
    # Escrever valores esperados para comparação
    li x29, 17
    sw x29, 32(x28)     # 0x80001020 - Esperado 1
    
    li x29, 5
    sw x29, 36(x28)     # 0x80001024 - Esperado 2
    
    li x29, 15  
    sw x29, 40(x28)     # 0x80001028 - Esperado 3
    
    li x29, 305
    sw x29, 44(x28)     # 0x8000102C - Esperado 4
    
    li x29, 105
    sw x29, 48(x28)     # 0x80001030 - Esperado 5
    
    li x29, 15
    sw x29, 52(x28)     # 0x80001034 - Esperado 6
    
    li x29, -3
    sw x29, 56(x28)     # 0x80001038 - Esperado 7
    
    li x29, 3005
    sw x29, 60(x28)     # 0x8000103C - Esperado 8
    
    # Marcador de fim dos testes
    li x30, 0xDEADBEEF
    sw x30, 64(x28)     # 0x80001040
    
end_loop:
    j end_loop          # Loop infinito